const {test} = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs/promises');
const os = require('node:os');
const path = require('node:path');
const {spawnSync} = require('node:child_process');
const {sha256} = require('./source.cjs');

test('detects semantic changes and ignores JSON formatting', async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), 'poke-compare-'));
  try {
    const old = path.join(root, 'old');
    const fresh = path.join(root, 'fresh');
    await fs.mkdir(old);
    await fs.mkdir(fresh);
    const original = Buffer.from('{"id":1,"name":"old"}');
    await fs.writeFile(path.join(old, 'pokemon_1_.json'), original);
    const baseline = path.join(root, 'manifest.json');
    await fs.writeFile(baseline, JSON.stringify({sourceHashes:[
      {kind:'pokemon',source_id:1,sha256:sha256(original)}]}));
    const report = path.join(root, 'report.json');
    const run = () => spawnSync(process.execPath,
      [path.join(__dirname, 'compare_snapshots.cjs'), baseline,
        old, fresh, report], {encoding:'utf8'});
    await fs.writeFile(path.join(fresh, 'pokemon_1_.json'),
      '{ "name": "old", "id": 1 }');
    assert.equal(run().status, 0);
    assert.equal(JSON.parse(await fs.readFile(report)).changed, false);
    await fs.writeFile(path.join(fresh, 'pokemon_1_.json'),
      '{"id":1,"name":"new"}');
    assert.equal(run().status, 0);
    const result = JSON.parse(await fs.readFile(report));
    assert.equal(result.changed, true);
    assert.deepEqual(result.changes.pokemon.changed, [1]);
    await fs.writeFile(path.join(old, 'pokemon_1_.json'), 'corrupt');
    assert.notEqual(run().status, 0);
  } finally {
    await fs.rm(root, {recursive:true, force:true});
  }
});
