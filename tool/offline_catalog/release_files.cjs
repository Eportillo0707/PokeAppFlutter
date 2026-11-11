const fs = require('node:fs/promises');
const path = require('node:path');
const {sha256} = require('./source.cjs');

function assetName(file) {
  return file === 'catalog.sqlite.gz' ? file : `media-${file.slice(6)}`;
}

async function checkedCopy(source, destination, entry) {
  const bytes = await fs.readFile(source);
  if (bytes.length !== entry.bytes || sha256(bytes) !== entry.sha256) {
    throw new Error(`Invalid source file: ${source}`);
  }
  await fs.mkdir(path.dirname(destination), {recursive: true});
  await fs.writeFile(destination, bytes, {flag: 'wx'});
}

module.exports = {assetName, checkedCopy};
