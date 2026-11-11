const fs = require('node:fs/promises');
const path = require('node:path');
const {sha256} = require('./source.cjs');

const api = process.env.POKEAPI_BASE_URL || 'https://pokeapi.co/api/v2/';
const kinds = ['pokemon', 'pokemon-species', 'move', 'ability',
  'evolution-chain', 'version-group', 'generation', 'type', 'machine'];
const baseline = process.argv[2] ||
  'build/offline-catalog/catalog-2026-11-05-final/manifest.json';
const output = process.argv[3] || 'build/offline-catalog/upstream-check.json';

async function get(url) {
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      const response = await fetch(url, {signal: AbortSignal.timeout(30000)});
      if (!response.ok) throw new Error(`${response.status} ${url}`);
      return Buffer.from(await response.arrayBuffer());
    } catch (error) {
      if (attempt === 2) throw error;
      await new Promise(resolve => setTimeout(resolve, 1000 * 2 ** attempt));
    }
  }
}

async function entries(kind) {
  const urls = [];
  let next = `${api}${kind}/?limit=500`;
  while (next) {
    const page = JSON.parse(await get(next));
    urls.push(...page.results.map(item => item.url));
    next = page.next;
  }
  return urls;
}

async function compare(kind, urls, old) {
  const changes = {added: [], changed: [], removed: []};
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
      else if (old.get(id) !== digest) changes.changed.push(id);
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
      Object.values(group).some(ids => ids.length > 0))};
  await fs.mkdir(path.dirname(output), {recursive: true});
  await fs.writeFile(output, `${JSON.stringify(report, null, 2)}\n`);
  console.log(`Report: ${output}`);
}

main().catch(error => { console.error(error); process.exitCode = 1; });
