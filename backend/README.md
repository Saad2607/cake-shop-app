# Backend — Cake Shop API

Node.js REST API with MongoDB (Mongoose).

## Prerequisites

- Node.js 18+
- MongoDB (local or MongoDB Atlas)

## Setup

1. Start MongoDB locally, or create a MongoDB Atlas cluster
2. Copy `.env.example` to `.env`
3. Set `MONGODB_URI` in `.env`:

```env
# Local
MONGODB_URI=mongodb://localhost:27017/cake_shop

# Atlas
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/cake_shop
```

4. Run:

```bash
npm install
npm run seed
npm run dev
```

Server runs at `http://localhost:3000`

## Health Check

```
GET http://localhost:3000/health
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| PORT | Server port (default 3000) |
| MONGODB_URI | MongoDB connection string |
| JWT_SECRET | Secret for signing JWT tokens |
| JWT_EXPIRES_IN | Token expiry (default 7d) |

## Scripts

| Command | Description |
|---------|-------------|
| `npm start` | Production start |
| `npm run dev` | Development with nodemon |
| `npm run seed` | Seed MongoDB with demo data |

## Models

| Collection | File | Description |
|------------|------|-------------|
| users | `src/models/User.js` | Accounts |
| cakes | `src/models/Cake.js` | Product catalog |
| cartitems | `src/models/CartItem.js` | Shopping cart |
| orders | `src/models/Order.js` | Orders (items embedded) |
