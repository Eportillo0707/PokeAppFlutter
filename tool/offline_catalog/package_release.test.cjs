const {test} = require('node:test');
const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs/promises');
const os = require('node:os');
const path = require('node:path');
const {sha256} = require('./source.cjs');
const {packageRelease} = require('./package_release.cjs');

test('packages changed media and signs the update manifest', async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), 'poke-release-'));
  try {
    const catalogDir = path.join(root, 'catalog');
    await fs.mkdir(path.join(catalogDir, 'media'), {recursive: true});
    const database = Buffer.from('compressed test database');
    const media = Buffer.from('new artwork');
    const mediaPath = `media/${sha256(media)}.webp`;
    await fs.writeFile(path.join(catalogDir, 'catalog.sqlite.gz'), database);
    await fs.writeFile(path.join(catalogDir, mediaPath), media);
    const entry = (file, bytes) =>
      ({path: file, sha256: sha256(bytes), bytes: bytes.length});
    const current = {schemaVersion: 1, snapshotAt: '2026-11-11',
      files: [entry('catalog.sqlite.gz', database), entry(mediaPath, media)]};
    const baseline = {schemaVersion: 1, files: []};
    const report = {changed: true, changes: {pokemon: {added: [2]}}};
    const currentFile = path.join(catalogDir, 'manifest.json');
    const baselineFile = path.join(root, 'baseline.json');
    const reportFile = path.join(root, 'report.json');
    await fs.writeFile(currentFile, JSON.stringify(current));
    await fs.writeFile(baselineFile, JSON.stringify(baseline));
    await fs.writeFile(reportFile, JSON.stringify(report));
    const {privateKey, publicKey} = crypto.generateKeyPairSync('ed25519');
    const privateKeyFile = path.join(root, 'private.pem');
    await fs.writeFile(privateKeyFile,
      privateKey.export({type: 'pkcs8', format: 'pem'}));
    const outputDir = path.join(root, 'release');
    const args = {catalogDir, baselineFile, reportFile, outputDir,
      version: '2026.11.11', baseVersion: '2026.11.05', privateKeyFile};
    const result = await packageRelease(args);
    assert.equal(result.files, 2);
    const manifest = await fs.readFile(path.join(outputDir,
      'update-manifest.json'));
    const signature = Buffer.from((await fs.readFile(path.join(outputDir,
      'update-manifest.sig'), 'utf8')).trim(), 'base64');
    assert.ok(crypto.verify(null, manifest, publicKey, signature));
    assert.equal(JSON.parse(manifest).channel, 'offlinetest');
    assert.deepEqual(await fs.readFile(path.join(outputDir, mediaPath)), media);
    await assert.rejects(packageRelease(args), /exist/);
    await fs.writeFile(reportFile, JSON.stringify({changed: false}));
    await assert.rejects(packageRelease({...args,
      outputDir: path.join(root, 'unchanged')}), /No semantic changes/);
  } finally {
    await fs.rm(root, {recursive: true, force: true});
  }
});
