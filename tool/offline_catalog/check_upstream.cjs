const fs = require('node:fs/promises');
const path = require('node:path');
const {sha256} = require('./source.cjs');
const {semanticHash} = require('./semantic_hash.cjs');
const {api, get, entries} = require('./upstream_http.cjs');

const kinds = ['pokemon', 'pokemon-species', 'move', 'ability',
  'evolution-chain', 'version-group', 'generation', 'type', 'machine'];
const baseline = process.argv[2] ||
  'build/offline-catalog/catalog-2026-11-05-final/manifest.json';
const output = process.argv[3] || 'build/offline-catalog/upstream-check.json';
const baselineJson = process.env.POKEAPI_BASELINE_JSON || 'build/offline-audit/json';

async function compare(kind, urls, old) {
  const changes = {added: [], changed: [], removed: [], reformatted: []};
  const seen = new Set();
  let cursor = 0;
  await Promise.all(Array.from({length: 4}, async () => {
    while (cursor < urls.length) {
      const url = urls[cursor++];
      const id = Number(url.match(/\/(\d+)\/$/)?.[1]);
      if (!Number.isInteger(id)) throw new Error(`Unknown resource URL: ${url}`);
      seen.add(id);
      const bytes = await get(url);
      const digest = sha256(bytes);
      if (!old.has(id)) changes.added.push(id);
      else if (old.get(id) !== digest) {
        const file = path.join(baselineJson, `${kind}_${id}_.json`);
        const prior = await fs.readFile(file);
        if (sha256(prior) !== old.get(id)) {
          throw new Error(`Baseline hash mismatch: ${file}`);
        }
        const group = semanticHash(prior) === semanticHash(bytes)
          ? changes.reformatted : changes.changed;
        group.push(id);
      }
      // Keep a complete fresh snapshot for a later catalog build.
      const file = path.join(path.dirname(output), 'upstream-snapshot',
        'json', `${kind}_${id}_.json`);
      await fs.mkdir(path.dirname(file), {recursive: true});
      await fs.writeFile(file, bytes);
    }
  }));
  changes.removed = [...old.keys()].filter(id => !seen.has(id));
  for (const key of Object.keys(changes)) changes[key].sort((a, b) => a - b);
  return changes;
}

async function main() {
  const manifest = JSON.parse(await fs.readFile(baseline));
  const previous = new Map(kinds.map(kind => [kind, new Map()]));
  for (const row of manifest.sourceHashes) {
    previous.get(row.kind)?.set(row.source_id, row.sha256);
  }
  const changes = {};
  for (const kind of kinds) {
    changes[kind] = await compare(kind, await entries(kind), previous.get(kind));
    console.log(`${kind}: ${JSON.stringify(Object.fromEntries(
      Object.entries(changes[kind]).map(([key, ids]) => [key, ids.length])))}`);
  }
  const report = {checkedAt: new Date().toISOString(), baseline,
    source: api,
    changes, changed: Object.values(changes).some(group =>
      ['added', 'changed', 'removed'].some(key => group[key].length > 0))};
  await fs.mkdir(path.dirname(output), {recursive: true});
  await fs.writeFile(output, `${JSON.stringify(report, null, 2)}\n`);
  console.log(`Report: ${output}`);
}

main().catch(error => { console.error(error); process.exitCode = 1; });
