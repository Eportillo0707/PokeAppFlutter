const fs = require('node:fs/promises');
const path = require('node:path');
const crypto = require('node:crypto');
const zlib = require('node:zlib');
const {DatabaseSync} = require('node:sqlite');
const {sha256} = require('./source.cjs');

async function main() {
  const output = path.resolve('build/offline-test-media-release');
  const source = path.resolve('build/offline-test-release/test-catalog.sqlite');
  await fs.mkdir(output, {recursive: false});
  const original = await fs.readFile('assets/offline_catalog/normal/1.webp');
  if (original.toString('ascii', 0, 4) !== 'RIFF' ||
      original.toString('ascii', 8, 12) !== 'WEBP') {
    throw new Error('Test source is not WebP');
  }
  const media = Buffer.concat([original, Buffer.from('JUNK\0\0\0\0')]);
  media.writeUInt32LE(media.length - 8, 4);
  const hash = sha256(media);
  const mediaAsset = `media-${hash}.webp`;
  await fs.writeFile(path.join(output, mediaAsset), media);
  const catalog = path.join(output, 'test-catalog.sqlite');
  await fs.copyFile(source, catalog);
  const db = new DatabaseSync(catalog);
  try {
    db.prepare('INSERT INTO media VALUES (?,?,?,?,?)')
      .run(hash, 'normal', `media/${hash}.webp`, hash, media.length);
    db.prepare('UPDATE pokemon SET normal_asset = ? WHERE id = 1').run(hash);
    db.prepare('INSERT OR REPLACE INTO catalog_meta VALUES (?, ?)')
      .run('offlinetest_marker', 'signed-media-usb-test');
    if (db.prepare('PRAGMA integrity_check').get().integrity_check !== 'ok') {
      throw new Error('Invalid test SQLite');
    }
  } finally { db.close(); }
  const compressed = zlib.gzipSync(await fs.readFile(catalog), {level: 9});
  await fs.writeFile(path.join(output, 'catalog.sqlite.gz'), compressed);
  const {privateKey, publicKey} = crypto.generateKeyPairSync('ed25519');
  const rawKey = publicKey.export({type:'spki',format:'der'}).subarray(-32);
  const manifest = {formatVersion:1, channel:'offlinetest',
    catalogVersion:'2026.11.13.2', baseCatalogVersion:'2026.11.11.1',
    minAppVersion:'1.1.0', schemaVersion:1, files:[
      {path:'catalog.sqlite.gz', asset:'catalog.sqlite.gz',
        bytes:compressed.length, sha256:sha256(compressed)},
      {path:`media/${hash}.webp`, asset:mediaAsset,
        bytes:media.length, sha256:hash},
    ]};
  const bytes = Buffer.from(JSON.stringify(manifest) + '\n');
  await fs.writeFile(path.join(output, 'update-manifest.json'), bytes);
  await fs.writeFile(path.join(output, 'update-manifest.sig'),
    crypto.sign(null, bytes, privateKey).toString('base64') + '\n');
  await fs.writeFile(path.join(output, 'public-key.base64'),
    rawKey.toString('base64') + '\n');
  console.log(JSON.stringify({output, version:manifest.catalogVersion,
    media:mediaAsset, publicKey:rawKey.toString('base64')}));
}

main().catch(error => {console.error(error); process.exitCode = 1;});
