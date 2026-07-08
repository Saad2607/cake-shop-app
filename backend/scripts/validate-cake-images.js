const CAKE_IMAGES = require('./seed').CAKE_IMAGES || {};

// Read URLs from seed by re-parsing - simpler to duplicate list
const IMG = (id) =>
  `https://images.unsplash.com/photo-${id}?w=800&q=80&auto=format&fit=crop`;

const urls = [
  IMG('1578985545062-69928b1d9587'),
  IMG('1535254973040-607b474cb50d'),
  IMG('1486427944299-d1955d23e34d'),
  IMG('1558636508-e0db3814bd1d'),
  IMG('1558961363-fa8fdf82db35'),
  IMG('1741429385363-82824923d3b0'),
  IMG('1723476349585-fd0d13cee438'),
  IMG('1761637604893-f049f46d2bcd'),
  IMG('1488477181946-6428a0291777'),
  IMG('1767044315790-bc0fe664fd0b'),
  IMG('1761249257288-012ee13bd0c9'),
  IMG('1599785209796-786432b228bc'),
  IMG('1612198188060-c7c2a3b66eae'),
  IMG('1519225421980-715cb0215aed'),
  IMG('1741887845552-005daf40e40d'),
  IMG('1603532648955-039310d9ed75'),
  IMG('1626082927389-6cd097cdc6ec'),
  IMG('1558618666-fcd25c85cd64'),
  IMG('1557925923-cd4648e211a0'),
  IMG('1571877227200-a0d98ea607e9'),
  IMG('1469533667357-006056eaf780'),
  IMG('1505252585461-04db1eb84625'),
  IMG('1555507036-ab1f4038808a'),
];

async function main() {
  let fail = 0;
  for (const url of urls) {
    const r = await fetch(url, { method: 'HEAD', redirect: 'follow' });
    if (r.status !== 200) {
      fail++;
      console.log('FAIL', r.status, url);
    }
  }
  console.log(fail === 0 ? 'All URLs OK' : `${fail} URLs failed`);
  process.exit(fail > 0 ? 1 : 0);
}

main();
