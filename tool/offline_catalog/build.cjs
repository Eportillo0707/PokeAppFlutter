const fs=require('node:fs/promises');
const path=require('node:path');
const crypto=require('node:crypto');
const zlib=require('node:zlib');
const {root,loadKind,streamKind,sha256}=require('./source.cjs');
const {createDatabase}=require('./schema.cjs');
const {packageMedia}=require('./media.cjs');
const {writeReferences}=require('./write_reference.cjs');
const {writeMoves}=require('./write_moves.cjs');
const {writePokemon}=require('./write_pokemon.cjs');

async function main(){
  const audit=JSON.parse(await fs.readFile(path.join(root,'summary.json')));
  if(audit.failures.length)throw new Error('Acquisition had network failures');
  const output=path.resolve(process.argv[2] || 'build/offline-catalog/catalog-2026-11-05-final');
  try{await fs.access(output);throw new Error(`Output already exists: ${output}`)}
  catch(error){if(error.code!=='ENOENT')throw error;}
  await fs.mkdir(output,{recursive:true});
  const db=createDatabase(path.join(output,'catalog.sqlite'));
  try{
    db.exec('BEGIN');
    const data={};
    for(const kind of ['generation','version-group','type','ability','pokemon-species','evolution-chain','move','machine']){
      data[kind]=await loadKind(kind);
    }
    const media=await packageMedia(db,output);
    writeReferences(db,data,media);
    writeMoves(db,data);
    const maps={
      types:new Map(data.type.map(r=>[r.data.name,r.data.id])),
      abilities:new Map(data.ability.map(r=>[r.data.name,r.data.id])),
      moves:new Map(data.move.map(r=>[r.data.name,r.data.id])),
      games:new Map(data['version-group'].map(r=>[r.data.name,r.data.id]))
    };
    const pokemon=await writePokemon(db,streamKind('pokemon'),maps,media);
    const meta=db.prepare('INSERT INTO catalog_meta VALUES (?,?)');
    meta.run('schema_version','1');
    meta.run('source_snapshot',audit.createdAt);
    meta.run('languages','en,es');
    db.exec('COMMIT');
    const integrity=db.prepare('PRAGMA integrity_check').get().integrity_check;
    const foreignKeys=db.prepare('PRAGMA foreign_key_check').all();
    if(integrity!=='ok'||foreignKeys.length)throw new Error(`Database integrity failed: ${integrity}, ${foreignKeys.length} foreign keys`);
    const counts=Object.fromEntries(['pokemon','species','moves','learnsets','games','machines','media','source_hashes']
      .map(table=>[table,db.prepare(`SELECT count(*) AS n FROM ${table}`).get().n]));
    if(counts.pokemon!==audit.counts.pokemon||counts.species!==audit.counts['pokemon-species']||
      counts.moves!==audit.counts.move||counts.source_hashes!==Object.values(audit.counts).reduce((a,b)=>a+b,0)){
      throw new Error(`Catalog counts do not match acquisition: ${JSON.stringify(counts)}`);
    }
    db.close();
    const catalog=await fs.readFile(path.join(output,'catalog.sqlite'));
    const compressed=zlib.gzipSync(catalog,{level:9});
    await fs.writeFile(path.join(output,'catalog.sqlite.gz'),compressed);
    const sourceHashes=[];
    const {DatabaseSync}=require('node:sqlite');
    const reader=new DatabaseSync(path.join(output,'catalog.sqlite'),{readOnly:true});
    for(const row of reader.prepare('SELECT kind,source_id,sha256 FROM source_hashes ORDER BY kind,source_id').iterate())sourceHashes.push(row);
    reader.close();
    const files=[...media.files,
      {path:'catalog.sqlite',sha256:sha256(catalog),bytes:catalog.length},
      {path:'catalog.sqlite.gz',sha256:sha256(compressed),bytes:compressed.length}]
      .sort((a,b)=>a.path.localeCompare(b.path));
    const manifest={formatVersion:1,schemaVersion:1,source:'PokéAPI v2 + PokeAPI/sprites',
      snapshotAt:audit.createdAt,languages:['en','es'],counts,
      fallbackArtwork:pokemon.fallbacks,upstreamAbsent:audit.absent,
      sourceHashes,files};
    const encoded=Buffer.from(JSON.stringify(manifest,null,2)+'\n');
    await fs.writeFile(path.join(output,'manifest.json'),encoded);
    await fs.writeFile(path.join(output,'manifest.sha256'),sha256(encoded)+'  manifest.json\n');
    console.log(JSON.stringify({output,counts,mediaFiles:media.files.length,
      sqliteBytes:catalog.length,gzipBytes:compressed.length,
      mediaBytes:media.files.reduce((s,f)=>s+f.bytes,0),
      fallbackArtwork:pokemon.fallbacks.length,manifestSha256:sha256(encoded)},null,2));
  }catch(error){try{db.exec('ROLLBACK')}catch{};try{db.close()}catch{};throw error;}
}
main().catch(error=>{console.error(error);process.exitCode=1;});
