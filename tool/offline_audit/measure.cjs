const fs = require('node:fs/promises');
const path = require('node:path');
const {execFile} = require('node:child_process');
const {promisify} = require('node:util');
const zlib = require('node:zlib');
const run = promisify(execFile);
const root = path.resolve('build/offline-audit');
const encoder = path.join(root,'tools/libwebp-1.6.0-windows-x64/bin/cwebp.exe');
async function main() {
  const manifest = JSON.parse(await fs.readFile(path.join(root,'media-manifest.json')));
  const images = [...new Map(manifest.filter(m=>m.bytes && m.kind!=='cry').map(m=>[m.hash,m])).values()];
  let next=0, done=0;
  const results=[];
  await Promise.all(Array.from({length:4},async()=>{
    while(next<images.length){
      const m=images[next++], row={hash:m.hash,kind:m.kind,original:m.bytes,file:m.file};
      for(const mode of ['lossless','q85']) {
        const file=path.join(root,'webp',mode,m.hash+'.webp');
        await fs.mkdir(path.dirname(file),{recursive:true});
        try { await fs.access(file); } catch {
          const args=mode==='lossless'?['-lossless','-exact','-m','4']:['-q','85','-alpha_q','100','-m','4'];
          await run(encoder,[...args,'-quiet',path.join(root,m.file),'-o',file]);
        }
        row[mode]=(await fs.stat(file)).size;
      }
      results.push(row);
      if(++done%200===0) console.log(`Converted ${done}/${images.length}`);
    }
  }));
  const totals={};
  for(const key of ['original','lossless','q85']) totals[key]=results.reduce((s,r)=>s+r[key],0);
  await fs.writeFile(path.join(root,'compression.json'),JSON.stringify({encoder:'libwebp 1.6.0',images:images.length,totals,results},null,2));
  // Measurement-only SQLite container; this is NOT the production schema.
  const {DatabaseSync}=require('node:sqlite');
  const dbpath=path.join(root,'raw-documents.sqlite');
  const db=new DatabaseSync(dbpath);
  db.exec('CREATE TABLE IF NOT EXISTS documents (key TEXT PRIMARY KEY, body TEXT NOT NULL); BEGIN');
  const insert=db.prepare('INSERT OR REPLACE INTO documents VALUES (?,?)');
  let count=0;
  for(const file of await fs.readdir(path.join(root,'json'))) {
    if(!/^[a-z-]+_\d+_\.json$/.test(file))continue;
    insert.run(file,JSON.stringify(JSON.parse(await fs.readFile(path.join(root,'json',file)))));count++;
  }
  db.exec('COMMIT; VACUUM');
  const integrity=db.prepare('PRAGMA integrity_check').get();db.close();
  const bytes=await fs.readFile(dbpath);
  const zipped=zlib.gzipSync(bytes);
  await fs.writeFile(dbpath+'.gz',zipped);
  const report={rows:count,rawSqliteBytes:bytes.length,gzipBytes:zipped.length,integrity};
  await fs.writeFile(path.join(root,'database-measurement.json'),JSON.stringify(report,null,2));
  console.log(JSON.stringify({images:images.length,totals,database:report},null,2));
}
main().catch(e=>{console.error(e);process.exitCode=1;});
