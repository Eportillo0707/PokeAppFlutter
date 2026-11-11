const {test} = require('node:test');
const assert = require('node:assert/strict');
const http = require('node:http');
const fs = require('node:fs/promises');
const os = require('node:os');
const path = require('node:path');
const {spawn} = require('node:child_process');
const {sha256} = require('./source.cjs');
const {semanticHash} = require('./semantic_hash.cjs');

test('semantic hash ignores JSON formatting and object key order', () => {
  const first = Buffer.from('{"b":{"y":2,"x":1},"a":[1,2]}');
  const equivalent = Buffer.from('{ "a": [1, 2], "b": {"x":1,"y":2} }');
  const changed = Buffer.from('{"b":{"y":3,"x":1},"a":[1,2]}');
  assert.equal(semanticHash(first), semanticHash(equivalent));
  assert.notEqual(semanticHash(first), semanticHash(changed));
});

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
    const source = path.join(directory, 'json');
    await fs.mkdir(source);
    const kinds = ['pokemon', 'pokemon-species', 'move', 'ability',
      'evolution-chain', 'version-group', 'generation', 'type', 'machine'];
    const old = [];
    for (const kind of kinds) {
      for (const [id, body] of [[1, '{ "id" : 1 }'],
        [2, '{"id":2,"name":"old"}'], [3, '{"id":3}']]) {
        await fs.writeFile(path.join(source, `${kind}_${id}_.json`), body);
        old.push({kind, source_id: id, sha256: sha256(Buffer.from(body))});
      }
    }
    const baseline = path.join(directory, 'manifest.json');
    const output = path.join(directory, 'report.json');
    await fs.writeFile(baseline, JSON.stringify({sourceHashes: old}));
    const child = spawn(process.execPath,
      [path.join(__dirname, 'check_upstream.cjs'), baseline, output], {
        env: {...process.env,
          POKEAPI_BASE_URL: `http://127.0.0.1:${server.address().port}/`,
          POKEAPI_BASELINE_JSON: source},
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
        {added: [4], changed: [2], removed: [3], reformatted: [1]});
    }
  } finally {
    server.close();
    await fs.rm(directory, {recursive: true, force: true});
  }
});
