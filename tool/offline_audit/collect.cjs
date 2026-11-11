const fs = require('node:fs/promises');
const path = require('node:path');
const crypto = require('node:crypto');
const zlib = require('node:zlib');
const root = path.resolve('build/offline-audit');
const api = 'https://pokeapi.co/api/v2/';
const failures = [];
let completed = 0;
const hash = b => crypto.createHash('sha256').update(b).digest('hex');
async function download(url, file) {
  try { return await fs.readFile(file); } catch {}
  await fs.mkdir(path.dirname(file), {recursive: true});
  for (let attempt = 0; attempt < 4; attempt++) {
    try {
      const response = await fetch(url, {signal: AbortSignal.timeout(45000)});
      if (response.status === 404) return null;
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const bytes = Buffer.from(await response.arrayBuffer());
      await fs.writeFile(file + '.tmp', bytes);
      await fs.rename(file + '.tmp', file);
      return bytes;
    } catch (error) {
      if (attempt === 3) { failures.push({url, error: String(error)}); return null; }
      await new Promise(r => setTimeout(r, 1000 * 2 ** attempt));
    }
  }
}
async function pool(values, task) {
  let next = 0;
  await Promise.all(Array.from({length: 4}, async () => {
    while (next < values.length) {
      await task(values[next++]);
      if (++completed % 200 === 0) console.log(`Processed ${completed} resources`);
    }
  }));
}
async function json(url) {
  const key = url.replace(api, '').replace(/[^a-zA-Z0-9-]/g, '_');
  const bytes = await download(url, path.join(root, 'json', key + '.json'));
  if (!bytes) throw new Error(`Required JSON unavailable: ${url}`);
  return JSON.parse(bytes);
}
async function main() {
  const data = {};
  for (const kind of ['pokemon', 'pokemon-species', 'move', 'ability', 'evolution-chain', 'version-group', 'generation', 'type', 'machine']) {
    const entries = [];
    let url = api + kind + '?limit=500';
    while (url) { const page = await json(url); entries.push(...page.results); url = page.next; }
    data[kind] = [];
    await pool(entries, async entry => data[kind].push(await json(entry.url)));
    data[kind].sort((a,b) => a.id - b.id);
    console.log(`${kind}: ${data[kind].length}`);
  }
  const media = new Map();
  const absent = [];
  function add(url, kind, owner) {
    if (!url) { absent.push({kind, owner, reason:'null in source'}); return; }
    if (!media.has(url)) media.set(url, {url, kind, owners: []});
    media.get(url).owners.push(owner);
  }
  for (const p of data.pokemon) {
    add(`https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${p.id}.png`, 'normal', p.name);
    add(p.sprites?.other?.['official-artwork']?.front_shiny, 'shiny', p.name);
    add(p.cries?.latest || p.cries?.legacy, 'cry', p.name);
  }
  function chain(node) {
    for (const d of node.evolution_details || []) for (const key of ['item','held_item']) {
      if (d[key]) add(`https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/${d[key].name}.png`, 'item', d[key].name);
    }
    for (const child of node.evolves_to || []) chain(child);
  }
  data['evolution-chain'].forEach(c => chain(c.chain));
  await pool([...media.values()], async m => {
    const extension = new URL(m.url).pathname.split('.').pop();
    m.file = path.join('media', m.kind, hash(m.url) + '.' + extension);
    const bytes = await download(m.url, path.join(root, m.file));
    if (!bytes) { absent.push({url:m.url,kind:m.kind,reason:'unavailable; see failures for network errors'}); return; }
    m.bytes = bytes.length; m.hash = hash(bytes);
  });
  const counts = Object.fromEntries(Object.entries(data).map(([k,v]) => [k,v.length]));
  const sizes = {};
  for (const [kind, entries] of Object.entries(data)) {
    const bytes = Buffer.from(JSON.stringify(entries));
    sizes[kind] = {rawBytes: bytes.length, gzipBytes: zlib.gzipSync(bytes).length};
  }
  const mediaSizes = {};
  for (const kind of ['normal','shiny','cry','item']) {
    const entries = [...media.values()].filter(m=>m.kind===kind && m.bytes);
    const unique = new Map(entries.map(m=>[m.hash,m]));
    mediaSizes[kind] = {files:entries.length,bytes:entries.reduce((s,m)=>s+m.bytes,0),uniqueFiles:unique.size,uniqueBytes:[...unique.values()].reduce((s,m)=>s+m.bytes,0)};
  }
  const summary = {createdAt:new Date().toISOString(),counts,sizes,mediaSizes,
    learnsetRows:data.pokemon.reduce((s,p)=>s+p.moves.reduce((n,m)=>n+m.version_group_details.length,0),0),
    missingSpanishSpecies:data['pokemon-species'].filter(p=>!p.flavor_text_entries.some(t=>t.language.name==='es')).map(p=>p.name),
    absent,failures};
  await fs.writeFile(path.join(root,'media-manifest.json'),JSON.stringify([...media.values()],null,2));
  await fs.writeFile(path.join(root,'summary.json'),JSON.stringify(summary,null,2));
  console.log(JSON.stringify({counts,sizes,mediaSizes,absent:absent.length,failures:failures.length},null,2));
}
main().catch(e=>{console.error(e);process.exitCode=1;});
