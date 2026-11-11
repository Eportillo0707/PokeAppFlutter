const api = process.env.POKEAPI_BASE_URL || 'https://pokeapi.co/api/v2/';

async function get(url) {
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      const response = await fetch(url, {signal: AbortSignal.timeout(30000)});
      if (!response.ok) throw new Error(`${response.status} ${url}`);
      return Buffer.from(await response.arrayBuffer());
    } catch (error) {
      if (attempt === 2) throw error;
      await new Promise(resolve => setTimeout(resolve, 1000 * 2 ** attempt));
    }
  }
}

async function entries(kind) {
  const urls = [];
  let next = `${api}${kind}/?limit=500`;
  while (next) {
    const page = JSON.parse(await get(next));
    urls.push(...page.results.map(item => item.url));
    next = page.next;
  }
  return urls;
}

module.exports = {api, get, entries};
