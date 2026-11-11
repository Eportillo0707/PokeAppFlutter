const fs = require('node:fs/promises');
const path = require('node:path');
const root = path.resolve('build/offline-audit');
async function main(){
  const records=new Map();
  for(const file of await fs.readdir(path.join(root,'json'))){
    const m=file.match(/^([a-z-]+)_(\d+)_\.json$/);if(!m)continue;
    records.set(`${m[1]}/${m[2]}`,JSON.parse(await fs.readFile(path.join(root,'json',file))));
  }
  const kinds=new Set([...records.keys()].map(k=>k.split('/')[0]));
  const missing=new Set();
  function visit(value){
    if(!value || typeof value!=='object')return;
    if(value.url?.startsWith('https://pokeapi.co/api/v2/')){
      const bits=value.url.replace('https://pokeapi.co/api/v2/','').split('/');
      if(kinds.has(bits[0])&&!records.has(`${bits[0]}/${bits[1]}`))missing.add(value.url);
    }
    Object.values(value).forEach(visit);
  }
  [...records.values()].forEach(visit);
  const coverage={};
  for(const kind of ['pokemon-species','move','ability']){
    const entries=[...records].filter(([k])=>k.startsWith(kind+'/')).map(([,v])=>v);
    coverage[kind]={};
    for(const language of ['en','es']) {
      const absent=entries.filter(p=>![...(p.flavor_text_entries||[]),...(p.effect_entries||[])].some(t=>t.language.name===language));
      coverage[kind][language]={total:entries.length,withoutText:absent.length,examples:absent.slice(0,12).map(p=>p.name)};
    }
  }
  const result={records:records.size,missingReferences:[...missing],textCoverage:coverage};
  await fs.writeFile(path.join(root,'coverage.json'),JSON.stringify(result,null,2));
  console.log(JSON.stringify(result,null,2));
}
main().catch(e=>{console.error(e);process.exitCode=1;});
