const fs = require('node:fs/promises');
const path = require('node:path');
const crypto = require('node:crypto');

const root = path.resolve('build/offline-audit');
const sourceDir = path.join(root, 'json');
const sha256 = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const idFromUrl = url => Number(url?.match(/\/(\d+)\/$/)?.[1]);
const clean = value => (value || '').replace(/\s+/g, ' ').trim();

async function loadKind(kind) {
  const files = (await fs.readdir(sourceDir))
    .filter(name => new RegExp(`^${kind}_\\d+_\\.json$`).test(name))
    .sort((a, b) => Number(a.match(/_(\d+)_/)[1]) - Number(b.match(/_(\d+)_/)[1]));
  const records = [];
  for (const file of files) {
    const bytes = await fs.readFile(path.join(sourceDir, file));
    records.push({data: JSON.parse(bytes), hash: sha256(bytes)});
  }
  return records;
}

async function* streamKind(kind) {
  const files = (await fs.readdir(sourceDir))
    .filter(name => new RegExp(`^${kind}_\\d+_\\.json$`).test(name))
    .sort((a, b) => Number(a.match(/_(\d+)_/)[1]) - Number(b.match(/_(\d+)_/)[1]));
  for (const file of files) {
    const bytes = await fs.readFile(path.join(sourceDir, file));
    yield {data: JSON.parse(bytes), hash: sha256(bytes)};
  }
}

function compact(value) {
  if (Array.isArray(value)) return value.map(compact);
  if (value && typeof value === 'object') {
    if (typeof value.name === 'string' && typeof value.url === 'string') {
      return value.name;
    }
    return Object.fromEntries(Object.entries(value)
      .filter(([key]) => key !== 'url')
      .map(([key, item]) => [key, compact(item)]));
  }
  return value;
}

module.exports = {root, loadKind, streamKind, sha256, idFromUrl, clean, compact};
