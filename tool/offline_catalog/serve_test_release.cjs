const fs = require('node:fs');
const path = require('node:path');
const http = require('node:http');

const root = path.resolve(process.argv[2] || 'build/offline-test-release');
const port = Number(process.argv[3] || 8765);
const allowed = new Set([
  'update-manifest.json', 'update-manifest.sig', 'catalog.sqlite.gz',
]);

http.createServer((request, response) => {
  const name = request.url.slice(1);
  if (request.method !== 'GET' || !allowed.has(name)) {
    response.writeHead(404).end();
    return;
  }
  const file = path.join(root, name);
  if (!fs.existsSync(file)) {
    response.writeHead(404).end();
    return;
  }
  response.setHeader('Content-Type', name.endsWith('.json')
    ? 'application/json' : 'application/octet-stream');
  fs.createReadStream(file).pipe(response);
}).listen(port, '127.0.0.1', () => {
  console.log(`Test catalog listening on 127.0.0.1:${port}`);
});
