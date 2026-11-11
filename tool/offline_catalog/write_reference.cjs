const {idFromUrl, clean, compact} = require('./source.cjs');
const stamp=(db,kind,record)=>db.prepare('INSERT INTO source_hashes VALUES (?,?,?)')
  .run(kind,record.data.id,record.hash);
const first=(entries,language)=>entries?.find(e=>e.language?.name===language);

function writeReferences(db,data,media){
  const generation=db.prepare('INSERT INTO generations VALUES (?,?)');
  for(const r of data.generation){generation.run(r.data.id,r.data.name);stamp(db,'generation',r);}
  const game=db.prepare('INSERT INTO games VALUES (?,?,?,?)');
  for(const r of data['version-group']){
    const d=r.data;game.run(d.id,d.name,d.order,idFromUrl(d.generation.url));
    stamp(db,'version-group',r);
  }
  const type=db.prepare('INSERT INTO types VALUES (?,?)');
  for(const r of data.type){type.run(r.data.id,r.data.name);stamp(db,'type',r);}
  const ability=db.prepare('INSERT INTO abilities VALUES (?,?)');
  const text=db.prepare('INSERT INTO ability_text VALUES (?,?,?,?,?)');
  for(const r of data.ability){
    const d=r.data;ability.run(d.id,d.name);
    for(const lang of ['en','es']){
      const flavor=first(d.flavor_text_entries,lang);
      const effect=first(d.effect_entries,lang);
      const description=clean(flavor?.flavor_text || effect?.short_effect || effect?.effect);
      const name=first(d.names,lang)?.name || d.name;
      text.run(d.id,lang,name,description,flavor?.version_group?.name || null);
    }
    stamp(db,'ability',r);
  }
  const species=db.prepare('INSERT INTO species VALUES (?,?,?,?,?,?,?)');
  const speciesText=db.prepare('INSERT INTO species_text VALUES (?,?,?,?)');
  for(const r of data['pokemon-species']){
    const d=r.data;
    species.run(d.id,d.name,idFromUrl(d.generation.url),
      idFromUrl(d.evolution_chain?.url)||null,null,Number(d.is_legendary),Number(d.is_mythical));
    for(const lang of ['en','es']){
      const value=first(d.flavor_text_entries,lang);
      if(value)speciesText.run(d.id,lang,clean(value.flavor_text),value.version?.name||null);
    }
    stamp(db,'pokemon-species',r);
  }
  const parent=db.prepare('UPDATE species SET evolves_from_id=? WHERE id=?');
  for(const r of data['pokemon-species']){
    const d=r.data;if(d.evolves_from_species)parent.run(idFromUrl(d.evolves_from_species.url),d.id);
  }
  const edge=db.prepare('INSERT INTO evolution_edges VALUES (?,?,?,?)');
  function walk(chainId,node,parentId){
    const current=idFromUrl(node.species.url);
    if(parentId)edge.run(chainId,parentId,current,JSON.stringify(compact(node.evolution_details||[])));
    for(const child of node.evolves_to||[])walk(chainId,child,current);
  }
  for(const r of data['evolution-chain']){
    walk(r.data.id,r.data.chain,null);stamp(db,'evolution-chain',r);
  }
  const item=db.prepare('INSERT OR IGNORE INTO evolution_items VALUES (?,?)');
  for(const [key,asset] of media.byOwner)if(key.startsWith('item/'))item.run(key.slice(5),asset);
}
module.exports={writeReferences,stamp};
