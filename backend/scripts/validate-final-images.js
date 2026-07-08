const { CAKE_IMAGE_IDS, IMG } = require('../src/data/cakeImageCatalog');

async function main() {
  let fail = 0;
  for (const [name, id] of Object.entries(CAKE_IMAGE_IDS)) {
    const url = IMG(id);
    const r = await fetch(url, { method: 'HEAD', redirect: 'follow' });
    if (r.status !== 200) {
      console.log('FAIL', r.status, name);
      fail++;
    } else {
      console.log('OK', name);
    }
  }
  process.exit(fail > 0 ? 1 : 0);
}

main();
