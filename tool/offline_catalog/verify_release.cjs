const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');

function verifyRelease(dir, expectedChannel = 'production') {
  const manifestBytes = fs.readFileSync(path.join(dir, 'update-manifest.json'));
  const manifest = JSON.parse(manifestBytes);
  if (manifest.channel !== expectedChannel ||
      manifest.baseCatalogVersion !== '2026.11.05') {
    throw new Error('Unexpected catalog channel or base version');
  }
  const rawKey = Buffer.from(fs.readFileSync(path.join(__dirname,
    'public-key.base64'), 'utf8').trim(), 'base64');
  if (rawKey.length !== 32) throw new Error('Invalid catalog public key');
  const key = crypto.createPublicKey({key: Buffer.concat([
    Buffer.from('302a300506032b6570032100', 'hex'), rawKey]),
  format: 'der', type: 'spki'});
  const signature = Buffer.from(fs.readFileSync(path.join(dir,
    'update-manifest.sig'), 'utf8').trim(), 'base64');
  if (signature.length !== 64 ||
      !crypto.verify(null, manifestBytes, key, signature)) {
    throw new Error('Invalid catalog signature');
  }
  const expected = new Set(['update-manifest.json', 'update-manifest.sig']);
  for (const entry of manifest.files) {
    if (!/^(catalog\.sqlite\.gz|media-[a-f0-9]{64}\.(webp|ogg|mp3))$/
        .test(entry.asset) || expected.has(entry.asset)) {
      throw new Error('Invalid catalog asset');
    }
    const file = fs.readFileSync(path.join(dir, entry.asset));
    if (file.length !== entry.bytes ||
        crypto.createHash('sha256').update(file).digest('hex') !== entry.sha256) {
      throw new Error(`Invalid asset: ${entry.asset}`);
    }
    expected.add(entry.asset);
  }
  const actual = fs.readdirSync(dir).sort();
  if (actual.length !== expected.size || actual.some(name => !expected.has(name))) {
    throw new Error('Unexpected or missing catalog assets');
  }
  return {version: manifest.catalogVersion, files: manifest.files.length};
}

if (require.main === module) {
  try {
    console.log(JSON.stringify(verifyRelease(process.argv[2])));
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}

module.exports = {verifyRelease};
