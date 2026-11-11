const fs = require('node:fs/promises');
const path = require('node:path');
const crypto = require('node:crypto');
const zlib = require('node:zlib');
const {DatabaseSync} = require('node:sqlite');
const {sha256} = require('./source.cjs');

async function main() {
  const output = path.resolve(process.argv[2] || 'build/offline-test-release');
  const source = path.resolve(process.argv[3] ||
    'build/offline-catalog/catalog-2026-11-05-final/catalog.sqlite');
  try { await fs.access(output); throw new Error('Test output already exists'); }
  catch (error) { if (error.code !== 'ENOENT') throw error; }
  await fs.mkdir(output, {recursive: true});
  const databaseFile = path.join(output, 'test-catalog.sqlite');
  await fs.copyFile(source, databaseFile);
  const database = new DatabaseSync(databaseFile);
  try {
    database.prepare('INSERT OR REPLACE INTO catalog_meta VALUES (?, ?)')
      .run('offlinetest_marker', 'signed-usb-test');
    const check = database.prepare('PRAGMA integrity_check').get();
    if (check.integrity_check !== 'ok') throw new Error('Invalid test SQLite');
  } finally { database.close(); }
  const compressed = zlib.gzipSync(await fs.readFile(databaseFile), {level: 9});
  await fs.writeFile(path.join(output, 'catalog.sqlite.gz'), compressed);
  const {privateKey, publicKey} = crypto.generateKeyPairSync('ed25519');
  const rawKey = publicKey.export({type: 'spki', format: 'der'}).subarray(-32);
  const manifest = {
    formatVersion: 1, channel: 'offlinetest', catalogVersion: '2026.11.11.1',
    baseCatalogVersion: '2026.11.05', minAppVersion: '1.1.0', schemaVersion: 1,
    files: [{path: 'catalog.sqlite.gz', asset: 'catalog.sqlite.gz',
      bytes: compressed.length, sha256: sha256(compressed)}],
  };
  const bytes = Buffer.from(JSON.stringify(manifest) + '\n');
  await fs.writeFile(path.join(output, 'update-manifest.json'), bytes);
  await fs.writeFile(path.join(output, 'update-manifest.sig'),
    crypto.sign(null, bytes, privateKey).toString('base64') + '\n');
  await fs.writeFile(path.join(output, 'public-key.base64'),
    rawKey.toString('base64') + '\n');
  console.log(JSON.stringify({output, version: manifest.catalogVersion,
    downloadBytes: compressed.length, publicKey: rawKey.toString('base64')}));
}

main().catch(error => { console.error(error); process.exitCode = 1; });
