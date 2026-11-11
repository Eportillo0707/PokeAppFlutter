const fs = require('node:fs');
const path = require('node:path');
const {DatabaseSync} = require('node:sqlite');

const source = process.argv[2] || 'build/offline-catalog/catalog-2026-11-05-final';
const target = 'assets/offline_catalog';
const db = new DatabaseSync(path.join(source, 'catalog.sqlite'), {readOnly: true});
const media = new Map(db.prepare('SELECT asset_id, relative_path FROM media').all()
  .map(row => [row.asset_id, row.relative_path]));

function copy(assetId, destination) {
  if (!assetId) return;
  const relative = media.get(assetId);
  if (!relative) throw new Error(`Missing media row: ${assetId}`);
  const from = path.join(source, relative);
  if (!fs.existsSync(from)) throw new Error(`Missing media file: ${from}`);
  const to = path.join(target, destination);
  fs.mkdirSync(path.dirname(to), {recursive: true});
  fs.copyFileSync(from, to);
}

fs.mkdirSync(target, {recursive: true});
fs.copyFileSync(path.join(source, 'catalog.sqlite.gz'), path.join(target, 'catalog.sqlite.gz'));
const mp3CryIds = [];
for (const row of db.prepare('SELECT id, normal_asset, shiny_asset, cry_asset FROM pokemon').all()) {
  copy(row.normal_asset, `normal/${row.id}.webp`);
  copy(row.shiny_asset || row.normal_asset, `shiny/${row.id}.webp`);
  const crySource = path.join(source, media.get(row.cry_asset));
  const header = fs.readFileSync(crySource).subarray(0, 4);
  const isOgg = header.toString() === 'OggS';
  const isMp3 = header.subarray(0, 3).toString() === 'ID3' ||
    (header[0] === 0xff && header[1] >= 0xe0);
  if (!isOgg && !isMp3) throw new Error(`Unknown cry format: ${row.id}`);
  const extension = isMp3 ? 'mp3' : 'ogg';
  copy(row.cry_asset, `cries/${row.id}.${extension}`);
  const stale = path.join(target, `cries/${row.id}.${isMp3 ? 'ogg' : 'mp3'}`);
  if (fs.existsSync(stale)) fs.unlinkSync(stale);
  if (isMp3) mp3CryIds.push(row.id);
}
fs.writeFileSync(path.join(target, 'cry_mp3_ids.json'), JSON.stringify(mp3CryIds));
for (const row of db.prepare('SELECT item_name, asset_id FROM evolution_items').all()) {
  copy(row.asset_id, `items/${row.item_name}.webp`);
}
console.log('Packaged offline catalog and media.');
