# Sweet Delights

Order handcrafted cakes from your phone — browse the menu, customize your cake, pay with UPI or cash on delivery, and track your order until it arrives.

Built with **Flutter**, **Node.js**, and **MongoDB**.

---

## What's included

**Customer app**
- Browse without signing in; sign in when you're ready to checkout
- Search, categories, promos, and delivery ETA on the home screen
- Cake details with size, flavor, custom message, wishlist, and share (photo + link)
- Saved addresses, cart, checkout, order tracking, and ratings after delivery
- Order notifications and account settings

**Admin app** (same install, admin login)
- Manage cakes, orders, and customers
- Update order status (customers get notified)
- Set product image URLs with live preview

**API**
- REST backend with JWT auth
- Public product pages at `/p/{cakeId}` for WhatsApp-style sharing

---

## Repo layout

```
├── backend/              API (Express + MongoDB)
├── flutter-app/cake_shop/   Android app (Flutter)
├── database/             Schema notes
├── docs/                 Extra guides
└── SETUP.md              Step-by-step local setup
```

---

## Run it locally

You need **Node 18+**, **MongoDB** (local or [Atlas](https://www.mongodb.com/atlas)), and **Flutter 3.2+**.

**1. API**

```bash
cd backend
cp .env.example .env
# Edit .env — MONGODB_URI, JWT_SECRET

npm install
npm run seed
npm run dev
```

API runs at `http://localhost:3000`. Check `http://localhost:3000/health`.

**2. App**

```bash
cd flutter-app/cake_shop
flutter pub get
flutter run
```

On a physical phone, point the app to your PC IP under **Account → Server connection (dev)**, or use the Android emulator default (`10.0.2.2`).

**Test logins**

| | Email | Password |
|---|--------|----------|
| Customer | customer@test.com | test123 |
| Admin | admin@cakeshop.com | admin123 |

More detail: [SETUP.md](SETUP.md) · [backend/README.md](backend/README.md) · [flutter-app/cake_shop/README.md](flutter-app/cake_shop/README.md)

---

## Production build

Deploy the API (e.g. [Render](https://render.com)) with MongoDB Atlas, set `PUBLIC_APP_URL`, run `npm run seed` once, then build the app:

```bash
flutter build apk --release \
  --dart-define=PRODUCTION_API_URL=https://your-api.onrender.com/api
```

Release builds use that URL automatically — no IP setup for people installing the APK.

Shared cake links look like `https://your-api.onrender.com/p/{cakeId}` and open a product page anyone can view.

---

## API overview

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check |
| GET | `/p/:id` | Shareable product page |
| POST | `/api/auth/login` | Sign in |
| GET | `/api/cakes` | Catalog |
| POST | `/api/orders` | Place order |
| … | `/api/admin/*` | Admin (JWT + admin role) |

---

<<<<<<< HEAD
## Stack

Flutter · Provider · Node.js · Express · Mongoose · JWT · MongoDB

---

## Docs

- [Setup guide](SETUP.md)
- [User guide](docs/07_User_Manual.md)
- [Database schema](database/mongodb_schema.md)

---

**Sweet Delights** — premium cakes, delivered fresh.
=======
*Flutter + Node.js + MongoDB*
>>>>>>> 9b9afefac0411dec0e0d8b09d6183ef407f3f03f
