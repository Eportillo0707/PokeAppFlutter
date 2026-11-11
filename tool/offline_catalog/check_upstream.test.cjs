const {test} = require('node:test');
const assert = require('node:assert/strict');
const http = require('node:http');
const fs = require('node:fs/promises');
const os = require('node:os');
const path = require('node:path');
const {spawn} = require('node:child_process');
const {sha256} = require('./source.cjs');

test('reports added, changed and removed resources', async () => {
  const directory = await fs.mkdtemp(path.join(os.tmpdir(), 'poke-check-'));
  const server = http.createServer((request, response) => {
    response.setHeader('content-type', 'application/json');
    const base = `http://127.0.0.1:${server.address().port}/`;
    if (request.url.endsWith('?limit=500')) {
      response.end(JSON.stringify({results: [1, 2, 4].map(id =>
        ({url: `${base}${request.url.split('/')[1]}/${id}/`})), next: null}));
    } else {
      response.end(JSON.stringify({id: Number(request.url.match(/\/(\d+)\/$/)[1])}));
    }
  });
  try {
    await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
    const kinds = ['pokemon', 'pokemon-species', 'move', 'ability',
      'evolution-chain', 'version-group', 'generation', 'type', 'machine'];
    const old = kinds.flatMap(kind => [
      {kind, source_id: 1, sha256: sha256(Buffer.from('{"id":1}'))},
      {kind, source_id: 2, sha256: 'old'},
      {kind, source_id: 3, sha256: 'removed'},
    ]);
    const baseline = path.join(directory, 'manifest.json');
    const output = path.join(directory, 'report.json');
    await fs.writeFile(baseline, JSON.stringify({sourceHashes: old}));
    const child = spawn(process.execPath,
      [path.join(__dirname, 'check_upstream.cjs'), baseline, output], {
        env: {...process.env,
          POKEAPI_BASE_URL: `http://127.0.0.1:${server.address().port}/`},
        stdio: ['ignore', 'ignore', 'pipe'],
      });
    let errors = '';
    child.stderr.on('data', bytes => { errors += bytes; });
    const code = await new Promise(resolve => child.on('exit', resolve));
    assert.equal(code, 0, errors);
    const report = JSON.parse(await fs.readFile(output));
    assert.equal(report.changed, true);
    for (const kind of kinds) {
      assert.deepEqual(report.changes[kind],
        {added: [4], changed: [2], removed: [3]});
    }
  } finally {
    server.close();
    await fs.rm(directory, {recursive: true, force: true});
  }
});
