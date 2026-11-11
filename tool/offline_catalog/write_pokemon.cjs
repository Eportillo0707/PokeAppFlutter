const {idFromUrl} = require('./source.cjs');
const {stamp} = require('./write_reference.cjs');

async function writePokemon(db,stream,maps,media){
  const pokemon=db.prepare('INSERT INTO pokemon VALUES (?,?,?,?,?,?,?,?,?,?,?)');
  const type=db.prepare('INSERT INTO pokemon_types VALUES (?,?,?)');
  const stat=db.prepare('INSERT INTO pokemon_stats VALUES (?,?,?)');
  const ability=db.prepare('INSERT INTO pokemon_abilities VALUES (?,?,?,?)');
  const learn=db.prepare('INSERT OR IGNORE INTO learnsets VALUES (?,?,?,?,?)');
  const defaults=new Map();
  const absent=[];
  let count=0,learning=0;
  for await(const r of stream){
    const d=r.data, speciesId=idFromUrl(d.species.url);
    const isDefault=!!d.is_default;
    const normal=media.byOwner.get(`normal/${d.name}`);
    const shiny=media.byOwner.get(`shiny/${d.name}`)||null;
    const cry=media.byOwner.get(`cry/${d.name}`)||null;
    if(normal&&isDefault)defaults.set(speciesId,normal);
    pokemon.run(d.id,d.name,speciesId,d.height,d.weight,d.base_experience,
      Number(isDefault),normal||null,shiny,cry,0);
    if(!normal)absent.push({id:d.id,name:d.name,speciesId});
    for(const slot of d.types)type.run(d.id,maps.types.get(slot.type.name),slot.slot);
    for(const row of d.stats)stat.run(d.id,row.stat.name,row.base_stat);
    for(const slot of d.abilities){
      ability.run(d.id,maps.abilities.get(slot.ability.name),slot.slot,Number(slot.is_hidden));
    }
    for(const row of d.moves)for(const item of row.version_group_details){
      learn.run(d.id,maps.moves.get(row.move.name),
        maps.games.get(item.version_group.name),item.move_learn_method.name,
        item.level_learned_at||0);learning++;
    }
    stamp(db,'pokemon',r);
    if(++count%250===0)console.log(`Indexed ${count} Pokémon`);
  }
  const fallback=db.prepare('UPDATE pokemon SET normal_asset=?,normal_fallback=1 WHERE id=?');
  for(const entry of absent){
    const asset=defaults.get(entry.speciesId);
    if(!asset)throw new Error(`No local artwork or species fallback: ${entry.name}`);
    fallback.run(asset,entry.id);
  }
  return {count,learning,fallbacks:absent};
}
module.exports={writePokemon};
