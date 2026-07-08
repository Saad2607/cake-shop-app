const Cake = require('../models/Cake');
const { imageUrlForCakeName } = require('../data/cakeImageCatalog');

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function formatInr(amount) {
  return new Intl.NumberFormat('en-IN', {
    style: 'currency',
    currency: 'INR',
    maximumFractionDigits: 0,
  }).format(amount);
}

function publicBaseUrl(req) {
  const envUrl = process.env.PUBLIC_APP_URL || process.env.RENDER_EXTERNAL_URL;
  if (envUrl) return envUrl.replace(/\/$/, '');
  return `${req.protocol}://${req.get('host')}`;
}

async function productSharePage(req, res) {
  try {
    const cake = await Cake.findById(req.params.id).lean();
    if (!cake) {
      return res.status(404).send('Product not found');
    }

    const base = publicBaseUrl(req);
    const pageUrl = `${base}/p/${cake._id}`;
    const imageUrl = imageUrlForCakeName(cake.name, cake.imageUrl);
    const appLink = `sweetdelights://cake/${cake._id}`;
    const price = formatInr(cake.basePrice);
    const name = escapeHtml(cake.name);
    const description = escapeHtml(cake.description);
    const image = imageUrl ? escapeHtml(imageUrl) : '';

    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.send(`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>${name} · ${price} · Sweet Delights</title>
  <meta name="description" content="${description} · Order fresh cakes on Sweet Delights."/>
  <meta property="og:site_name" content="Sweet Delights"/>
  <meta property="og:type" content="website"/>
  <meta property="og:title" content="${name} · ${price}"/>
  <meta property="og:description" content="${description}"/>
  <meta property="og:url" content="${pageUrl}"/>
  ${image ? `<meta property="og:image" content="${image}"/>
  <meta property="og:image:secure_url" content="${image}"/>
  <meta property="og:image:width" content="800"/>
  <meta property="og:image:height" content="600"/>` : ''}
  <meta name="twitter:card" content="summary_large_image"/>
  <meta name="twitter:title" content="${name} · ${price}"/>
  <meta name="twitter:description" content="${description}"/>
  ${image ? `<meta name="twitter:image" content="${image}"/>` : ''}
  <style>
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif;
      background: linear-gradient(180deg, #fff5f7 0%, #ffffff 40%);
      color: #2d2a32;
    }
    .wrap { max-width: 480px; margin: 0 auto; padding: 24px 20px 40px; }
    .brand { font-weight: 700; color: #c2185b; margin-bottom: 18px; }
    .card {
      background: #fff;
      border-radius: 20px;
      overflow: hidden;
      box-shadow: 0 12px 40px rgba(194, 24, 91, 0.08);
      border: 1px solid #f3d9e2;
    }
    .hero {
      width: 100%;
      aspect-ratio: 4 / 3;
      object-fit: cover;
      background: #fce4ec;
      display: block;
    }
    .hero-fallback {
      width: 100%;
      aspect-ratio: 4 / 3;
      display: grid;
      place-items: center;
      background: linear-gradient(135deg, #fff5f7, #f8d4dc);
      font-size: 64px;
    }
    .body { padding: 20px; }
    h1 { margin: 0 0 8px; font-size: 1.45rem; line-height: 1.25; }
    .price { font-size: 1.25rem; font-weight: 700; color: #c2185b; margin-bottom: 12px; }
    .desc { color: #5f5a66; line-height: 1.55; margin: 0 0 20px; }
    .btn {
      display: block;
      width: 100%;
      text-align: center;
      text-decoration: none;
      padding: 14px 16px;
      border-radius: 14px;
      font-weight: 600;
      margin-bottom: 10px;
    }
    .btn-primary { background: #c2185b; color: #fff; }
    .btn-secondary { background: #fff; color: #c2185b; border: 1px solid #f3d9e2; }
    .hint { font-size: 0.85rem; color: #8a8494; text-align: center; margin-top: 14px; }
  </style>
</head>
<body>
  <div class="wrap">
    <div class="brand">Sweet Delights</div>
    <div class="card">
      ${
        image
          ? `<img class="hero" src="${image}" alt="${name}"/>`
          : '<div class="hero-fallback">🎂</div>'
      }
      <div class="body">
        <h1>${name}</h1>
        <div class="price">${price}</div>
        <p class="desc">${description}</p>
        <a class="btn btn-primary" href="${appLink}">Open in Sweet Delights app</a>
        <a class="btn btn-secondary" href="${pageUrl}">View product page</a>
        <p class="hint">Fresh cakes handcrafted and delivered to your door.</p>
      </div>
    </div>
  </div>
</body>
</html>`);
  } catch (err) {
    console.error('Share page error:', err);
    res.status(500).send('Could not load product');
  }
}

module.exports = { productSharePage, publicBaseUrl };
