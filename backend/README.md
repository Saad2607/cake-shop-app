# Sweet Delights API

Backend for the Sweet Delights cake ordering app. Handles auth, catalog, cart, orders, admin tools, and public product share pages.

## Requirements

- Node.js 18+
- MongoDB (local or Atlas)

## Get started

```bash
cp .env.example .env
npm install
npm run seed
npm run dev
```

The server listens on `http://localhost:3000`.

### Environment

```env
MONGODB_URI=mongodb://localhost:27017/cake_shop
JWT_SECRET=your-secret-key
PUBLIC_APP_URL=http://localhost:3000
```

On production, set `PUBLIC_APP_URL` to your live URL (e.g. `https://sweet-delights.onrender.com`) so shared cake links preview correctly in WhatsApp.

## Endpoints worth knowing

| URL | What it does |
|-----|----------------|
| `GET /health` | Quick health check |
| `GET /p/:cakeId` | Public product page when someone opens a shared link |
| `/api/*` | JSON REST API (auth, cakes, cart, orders, admin) |

Admin routes need a JWT with `role: ADMIN`.

## Scripts

| Command | What it does |
|---------|----------------|
| `npm run dev` | Start with auto-reload |
| `npm start` | Production start |
| `npm run seed` | Load demo users and 24 cakes |
| `node scripts/validate-final-images.js` | Check that all cake image URLs still work |

## Cake images

Product photos live in `src/data/cakeImageCatalog.js` — one image per cake name. After editing, run `npm run seed` again.

## Deploying on Render

1. Set root directory to `backend`
2. Build: `npm install` · Start: `npm start`
3. Add env vars: `MONGODB_URI`, `JWT_SECRET`, `PUBLIC_APP_URL`
4. Seed the database once: `npm run seed`

## Data model

| Collection | Purpose |
|----------|---------|
| users | Customer and admin accounts |
| cakes | Menu items |
| cartitems | Per-user cart |
| orders | Orders with line items and ratings |
