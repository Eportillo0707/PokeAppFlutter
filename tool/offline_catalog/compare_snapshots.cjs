const fs = require('node:fs/promises');
const path = require('node:path');
const {sha256} = require('./source.cjs');
const {semanticHash} = require('./semantic_hash.cjs');

async function main() {
  const baseline = process.argv[2];
  const oldJson = process.argv[3];
  const freshJson = process.argv[4];
  const output = process.argv[5];
  if (!baseline || !oldJson || !freshJson || !output) {
    throw new Error('Usage: compare_snapshots.cjs <manifest> '
      + '<baseline-json> <fresh-json> <report>');
  }
  const manifest = JSON.parse(await fs.readFile(baseline));
  const previous = new Map(manifest.sourceHashes.map(row =>
    [`${row.kind}_${row.source_id}_.json`, row.sha256]));
  const changes = {};
  const files = (await fs.readdir(freshJson)).filter(name =>
    /^[a-z-]+_\d+_\.json$/.test(name));
  for (const name of files) {
    const kind = name.match(/^(.+)_\d+_\.json$/)[1];
    const group = changes[kind] ??= {added:[], changed:[], removed:[],
      reformatted:[]};
    const id = Number(name.match(/_(\d+)_/)[1]);
    const bytes = await fs.readFile(path.join(freshJson, name));
    const oldHash = previous.get(name);
    if (oldHash == null) group.added.push(id);
    else if (oldHash !== sha256(bytes)) {
      const old = await fs.readFile(path.join(oldJson, name));
      if (sha256(old) !== oldHash) {
        throw new Error(`Baseline hash mismatch: ${name}`);
      }
      group[semanticHash(old) === semanticHash(bytes)
        ? 'reformatted' : 'changed'].push(id);
    }
    previous.delete(name);
  }
  for (const name of previous.keys()) {
    const kind = name.match(/^(.+)_\d+_\.json$/)[1];
    const group = changes[kind] ??= {added:[], changed:[], removed:[],
      reformatted:[]};
    group.removed.push(Number(name.match(/_(\d+)_/)[1]));
  }
  for (const group of Object.values(changes)) {
    for (const ids of Object.values(group)) ids.sort((a,b) => a-b);
  }
  const changed = Object.values(changes).some(group =>
    ['added','changed','removed'].some(key => group[key].length));
  await fs.mkdir(path.dirname(output), {recursive:true});
  await fs.writeFile(output, JSON.stringify({checkedAt:new Date().toISOString(),
    baseline, changed, changes}, null, 2) + '\n');
  console.log(JSON.stringify({changed, changes}));
}

main().catch(error => {console.error(error); process.exitCode = 1;});
