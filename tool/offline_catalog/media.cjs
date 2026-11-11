const fs = require('node:fs/promises');
const path = require('node:path');
const {root, sha256} = require('./source.cjs');

function cryExtension(bytes, url) {
  if (bytes.subarray(0, 4).toString() === 'OggS') return '.ogg';
  if (bytes.subarray(0, 3).toString() === 'ID3' ||
      (bytes[0] === 0xff && bytes[1] >= 0xe0)) return '.mp3';
  throw new Error(`Unknown cry format: ${url}`);
}

async function packageMedia(db, output) {
  const entries = JSON.parse(await fs.readFile(path.join(root,'media-manifest.json')));
  const insert = db.prepare('INSERT OR IGNORE INTO media VALUES (?,?,?,?,?)');
  const byUrl = new Map();
  const byOwner = new Map();
  const files = new Map();
  const absent = [];
  for (const entry of entries) {
    if (!entry.bytes) { absent.push({kind:entry.kind,url:entry.url}); continue; }
    const source = entry.kind === 'cry'
      ? path.join(root,entry.file)
      : path.join(root,'webp/q85',entry.hash+'.webp');
    const bytes = await fs.readFile(source);
    const digest = sha256(bytes);
    const extension = entry.kind === 'cry'
      ? cryExtension(bytes, entry.url) : '.webp';
    const relative = `media/${digest}${extension}`;
    if (!files.has(relative)) {
      const target = path.join(output,relative);
      await fs.mkdir(path.dirname(target),{recursive:true});
      await fs.copyFile(source,target);
      files.set(relative,{path:relative,sha256:digest,bytes:bytes.length});
    }
    insert.run(digest,entry.kind,relative,digest,bytes.length);
    byUrl.set(entry.url,digest);
    for (const owner of entry.owners) byOwner.set(`${entry.kind}/${owner}`,digest);
  }
  return {byUrl,byOwner,files:[...files.values()].sort((a,b)=>a.path.localeCompare(b.path)),absent};
}

module.exports={packageMedia};
