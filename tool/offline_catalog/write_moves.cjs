const {idFromUrl,clean} = require('./source.cjs');
const {stamp} = require('./write_reference.cjs');

function writeMoves(db,data){
  const types=new Map(data.type.map(r=>[r.data.name,r.data.id]));
  const games=new Map(data['version-group'].map(r=>[r.data.name,r.data.id]));
  const insert=db.prepare('INSERT INTO moves VALUES (?,?,?,?,?,?,?,?)');
  const names=db.prepare('INSERT INTO move_names VALUES (?,?,?)');
  const text=db.prepare('INSERT OR IGNORE INTO move_descriptions VALUES (?,?,?,?,?)');
  const past=db.prepare('INSERT OR REPLACE INTO move_past_values VALUES (?,?,?,?,?,?)');
  for(const r of data.move){
    const d=r.data;
    insert.run(d.id,d.name,types.get(d.type.name),d.damage_class.name,
      d.power,d.accuracy,d.pp,idFromUrl(d.generation.url));
    for(const lang of ['en','es']){
      const name=d.names.find(n=>n.language.name===lang)?.name;
      if(name)names.run(d.id,lang,name);
    }
    for(const [index,item] of (d.flavor_text_entries||[]).entries()){
      const lang=item.language.name;
      if((lang==='en'||lang==='es')&&games.has(item.version_group.name)){
        text.run(d.id,games.get(item.version_group.name),lang,clean(item.flavor_text),index);
      }
    }
    for(const item of d.past_values||[]){
      const game=games.get(item.version_group.name);
      if(game)past.run(d.id,game,item.power,item.accuracy,item.pp,
        item.type?types.get(item.type.name):null);
    }
    stamp(db,'move',r);
  }
  const machines=db.prepare('INSERT INTO machines VALUES (?,?,?,?)');
  for(const r of data.machine){
    const d=r.data;
    machines.run(d.id,games.get(d.version_group.name),idFromUrl(d.move.url),d.item.name);
    stamp(db,'machine',r);
  }
}
module.exports={writeMoves};
