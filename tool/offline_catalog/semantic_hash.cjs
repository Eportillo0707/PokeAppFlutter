const {sha256} = require('./source.cjs');

function canonical(value) {
  if (Array.isArray(value)) return value.map(canonical);
  if (value !== null && typeof value === 'object') {
    return Object.fromEntries(Object.keys(value).sort()
      .map(key => [key, canonical(value[key])]));
  }
  return value;
}

function semanticHash(bytes) {
  return sha256(Buffer.from(JSON.stringify(canonical(JSON.parse(bytes)))));
}

module.exports = {semanticHash};
