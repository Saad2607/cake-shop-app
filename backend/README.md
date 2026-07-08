# Backend — Sweet Delights API

Node.js REST API with MongoDB (Mongoose).

## Prerequisites

- Node.js 18+
- MongoDB (local or MongoDB Atlas)

## Setup

1. Start MongoDB locally, or create a MongoDB Atlas cluster
2. Copy `.env.example` to `.env`
3. Configure `.env`:

```env
MONGODB_URI=mongodb://localhost:27017/cake_shop
JWT_SECRET=your-secret-key
PUBLIC_APP_URL=http://localhost:3000   # Used in share page OG tags (set to Render URL in prod)
```

4. Run:

```bash
npm install
npm run seed
npm run dev
```

Server: `http://localhost:3000`

## Health & share pages

| URL | Description |
|-----|-------------|
| `GET /health` | API health JSON |
| `GET /p/:cakeId` | Public product page for shared links (image, price, Open Graph meta) |

## Environment variables

| Variable | Description |
|----------|-------------|
| `PORT` | Server port (default `3000`) |
| `MONGODB_URI` | MongoDB connection string |
| `JWT_SECRET` | JWT signing secret |
| `JWT_EXPIRES_IN` | Token expiry (default `7d`) |
| `PUBLIC_APP_URL` | Public base URL for share links (e.g. `https://your-app.onrender.com`) |
| `RENDER_EXTERNAL_URL` | Auto-set on Render; used as fallback for share URLs |

## Scripts

| Command | Description |
|---------|-------------|
| `npm start` | Production start |
| `npm run dev` | Development with nodemon |
| `npm run seed` | Seed users + 24 cakes with name-matched image URLs |
| `node scripts/validate-final-images.js` | Verify all cake image URLs return HTTP 200 |

## API routes

All JSON API routes are under `/api`. See root `README.md` for the full endpoint list.

**Admin routes** require `Authorization: Bearer <token>` and `role: ADMIN`.

## Models

| Collection | File | Description |
|------------|------|-------------|
| users | `src/models/User.js` | Customer & admin accounts |
| cakes | `src/models/Cake.js` | Product catalog |
| cartitems | `src/models/CartItem.js` | Per-user cart |
| orders | `src/models/Order.js` | Orders (embedded items, rating) |

## Cake images

Image URLs are defined in `src/data/cakeImageCatalog.js` (one verified Unsplash photo per cake name).  
`npm run seed` applies them to MongoDB. Update the catalog and re-seed after changing images.

## Deploy on Render

1. Connect GitHub repo; root directory: `backend`
2. Build: `npm install` · Start: `npm start`
3. Add `MONGODB_URI`, `JWT_SECRET`, `PUBLIC_APP_URL`
4. Run `npm run seed` once against Atlas
