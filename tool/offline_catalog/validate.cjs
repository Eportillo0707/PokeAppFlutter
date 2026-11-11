const fs=require('node:fs/promises');
const path=require('node:path');
const {DatabaseSync}=require('node:sqlite');
const {sha256}=require('./source.cjs');
const output=path.resolve(process.argv[2] || 'build/offline-catalog/catalog-2026-11-05-final');
function assert(condition,message){if(!condition)throw new Error(message);}
async function main(){
  const bytes=await fs.readFile(path.join(output,'manifest.json'));
  const manifest=JSON.parse(bytes);
  const digest=(await fs.readFile(path.join(output,'manifest.sha256'),'utf8')).split(' ')[0];
  assert(sha256(bytes)===digest,'Manifest checksum mismatch');
  let total=0;
  for(const item of manifest.files){
    const file=await fs.readFile(path.join(output,item.path));
    assert(file.length===item.bytes&&sha256(file)===item.sha256,`Asset invalid: ${item.path}`);
    total+=file.length;
  }
  const db=new DatabaseSync(path.join(output,'catalog.sqlite'),{readOnly:true});
  assert(db.prepare('PRAGMA integrity_check').get().integrity_check==='ok','SQLite integrity');
  assert(db.prepare('PRAGMA foreign_key_check').all().length===0,'Foreign keys');
  for(const [table,count] of Object.entries(manifest.counts)){
    assert(db.prepare(`SELECT count(*) AS n FROM ${table}`).get().n===count,`Row count: ${table}`);
  }
  const missing=db.prepare(`SELECT count(*) AS n FROM pokemon p
    WHERE NOT EXISTS(SELECT 1 FROM media m WHERE m.asset_id=p.normal_asset)
    OR (p.shiny_asset IS NOT NULL AND NOT EXISTS(SELECT 1 FROM media m WHERE m.asset_id=p.shiny_asset))
    OR (p.cry_asset IS NOT NULL AND NOT EXISTS(SELECT 1 FROM media m WHERE m.asset_id=p.cry_asset))`).get().n;
  assert(missing===0,`Broken media references: ${missing}`);
  const sample=db.prepare(`SELECT p.name, sp.generation_id, t.name AS type
    FROM pokemon p JOIN species sp ON sp.id=p.species_id
    JOIN pokemon_types pt ON pt.pokemon_id=p.id
    JOIN types t ON t.id=pt.type_id WHERE p.name='charizard' ORDER BY pt.slot`).all();
  assert(sample.length===2&&sample[0].type==='fire'&&sample[1].type==='flying','Charizard lookup');
  const moves=db.prepare(`SELECT g.name, l.method, count(*) AS n FROM learnsets l
    JOIN games g ON g.id=l.game_id JOIN pokemon p ON p.id=l.pokemon_id
    WHERE p.name='charizard' GROUP BY g.name,l.method ORDER BY g.name,l.method`).all();
  assert(moves.length>0,'Move/game lookup');
  const search=db.prepare("SELECT count(*) AS n FROM pokemon WHERE name LIKE '%char%' ").get().n;
  assert(search>1,'Partial search');
  const spanish=db.prepare("SELECT description FROM species_text WHERE species_id=6 AND language='es'").get();
  assert(spanish?.description,'Spanish description');
  db.close();
  console.log(JSON.stringify({verifiedFiles:manifest.files.length,totalBytes:total,
    missingMedia:missing,examples:{charizardTypes:sample.map(x=>x.type),
      charizardGameMethods:moves.length,partialSearchMatches:search}},null,2));
}
main().catch(e=>{console.error(e);process.exitCode=1;});
