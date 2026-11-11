const fs = require('node:fs/promises');
const path = require('node:path');
const crypto = require('node:crypto');
const {sha256} = require('./source.cjs');

async function checkedCopy(source, destination, entry) {
  const bytes = await fs.readFile(source);
  if (bytes.length !== entry.bytes || sha256(bytes) !== entry.sha256) {
    throw new Error(`Invalid source file: ${source}`);
  }
  await fs.mkdir(path.dirname(destination), {recursive: true});
  await fs.writeFile(destination, bytes, {flag: 'wx'});
}

async function packageRelease({catalogDir, baselineFile, reportFile,
  outputDir, version, baseVersion, privateKeyFile}) {
  if (!/^\d{4}\.\d{2}\.\d{2}(?:\.\d+)?$/.test(version)) {
    throw new Error('Catalog version must be YYYY.MM.DD[.revision]');
  }
  if (!/^\d{4}\.\d{2}\.\d{2}(?:\.\d+)?$/.test(baseVersion)) {
    throw new Error('Base version must be YYYY.MM.DD[.revision]');
  }
  const report = JSON.parse(await fs.readFile(reportFile));
  if (report.changed !== true) throw new Error('No semantic changes to publish');
  const current = JSON.parse(await fs.readFile(
    path.join(catalogDir, 'manifest.json')));
  const baseline = JSON.parse(await fs.readFile(baselineFile));
  if (current.schemaVersion !== 1 || baseline.schemaVersion !== 1) {
    throw new Error('Unsupported SQLite schema');
  }
  const oldFiles = new Map(baseline.files.map(file => [file.path, file.sha256]));
  const files = current.files.filter(file =>
    file.path === 'catalog.sqlite.gz' ||
    (file.path.startsWith('media/') && oldFiles.get(file.path) !== file.sha256));
  for (const file of files) {
    if (file.path !== 'catalog.sqlite.gz' &&
        !/^media\/[a-f0-9]{64}\.(webp|ogg|mp3)$/.test(file.path)) {
      throw new Error(`Unsafe package path: ${file.path}`);
    }
  }
  if (!files.some(file => file.path === 'catalog.sqlite.gz')) {
    throw new Error('Missing compressed catalog');
  }
  const key = crypto.createPrivateKey(await fs.readFile(privateKeyFile));
  if (key.asymmetricKeyType !== 'ed25519') throw new Error('Expected Ed25519 key');
  const publicKey = crypto.createPublicKey(key).export({type: 'spki', format: 'der'});
  const keyId = sha256(publicKey).slice(0, 16);
  const manifest = {formatVersion: 1, channel: 'offlinetest',
    catalogVersion: version, baseCatalogVersion: baseVersion,
    minAppVersion: '1.1.0', schemaVersion: 1, keyId,
    sourceSnapshot: current.snapshotAt, changes: report.changes,
    files: files.map(({path: file, bytes, sha256: hash}) =>
      ({path: file, bytes, sha256: hash}))};
  await fs.mkdir(path.dirname(outputDir), {recursive: true});
  await fs.mkdir(outputDir, {recursive: false});
  for (const entry of files) {
    await checkedCopy(path.join(catalogDir, entry.path),
      path.join(outputDir, entry.path), entry);
  }
  const encoded = Buffer.from(`${JSON.stringify(manifest, null, 2)}\n`);
  const signature = crypto.sign(null, encoded, key).toString('base64');
  await fs.writeFile(path.join(outputDir, 'update-manifest.json'), encoded,
    {flag: 'wx'});
  await fs.writeFile(path.join(outputDir, 'update-manifest.sig'),
    `${signature}\n`, {flag: 'wx'});
  return {files: files.length, bytes: files.reduce((sum, f) => sum + f.bytes, 0),
    keyId};
}

if (require.main === module) {
  const [catalogDir, baselineFile, reportFile, outputDir, version, baseVersion] =
    process.argv.slice(2);
  const privateKeyFile = process.env.POKEAPP_SIGNING_KEY;
  if (!catalogDir || !baselineFile || !reportFile || !outputDir ||
      !version || !baseVersion || !privateKeyFile) {
    console.error('Usage: POKEAPP_SIGNING_KEY=<path> node package_release.cjs '
      + '<catalogDir> <baselineManifest> <report> <outputDir> '
      + '<version> <baseVersion>');
    process.exitCode = 1;
  } else {
    packageRelease({catalogDir, baselineFile, reportFile, outputDir,
      version, baseVersion, privateKeyFile})
      .then(result => console.log(JSON.stringify(result)))
      .catch(error => { console.error(error); process.exitCode = 1; });
  }
}

module.exports = {packageRelease};
