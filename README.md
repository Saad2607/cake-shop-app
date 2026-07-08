# Sweet Delights — Cake Online Shopping App

A full-stack mobile e-commerce application for ordering handcrafted cakes: **Flutter** frontend, **Node.js** REST API, and **MongoDB** database.

**App name:** Sweet Delights  
**Package:** `com.cakeshop.cake_shop`

---

## Project Overview

| Item | Details |
|------|---------|
| **Project Title** | Cake Online Shopping App (Sweet Delights) |
| **Frontend** | Flutter (Dart) — Android (iOS-ready structure) |
| **Backend** | Node.js + Express + Mongoose |
| **Database** | MongoDB |
| **Auth** | JWT (customer + admin roles) |
| **Version** | 3.0.0 |

---

## Features

### Customer app
- Browse cakes **without signing in** (guest mode)
- Home search, categories, trending carousel, promo offers (e.g. SWEET50 countdown)
- Cake detail: size, flavor, custom message, wishlist, **share with image + product link**
- Delivery ETA chip, multiple saved addresses (Home / Office / Other)
- Cart, UPI-style checkout, cash on delivery
- Order tracking with status steps and ETA
- Post-delivery **1–5 star reviews**
- Push-style **order notifications** (baking, ready, delivered)
- **Account → Settings**: notifications, edit profile, addresses, help & support
- Forgot password flow
- **Deep links** — open a shared cake in the app (`sweetdelights://cake/{id}`)

### Admin panel (in-app)
- Dashboard, cake CRUD with **image URL preview**
- Order management and status updates
- Customer list, new-order notifications

### Backend
- REST API under `/api`
- Public **product share pages** at `/p/:id` (link previews for WhatsApp, etc.)
- Name-matched cake images in seed data (verified Unsplash URLs)
- Deployable on **Render** with MongoDB Atlas

---

## Architecture

```
┌─────────────────┐     HTTP/REST      ┌─────────────────┐     Mongoose     ┌─────────────────┐
│  Flutter App    │ ◄────────────────► │  Node.js API    │ ◄──────────────► │    MongoDB      │
│  Sweet Delights │     JWT Auth       │  (Express)      │                  │   (NoSQL DB)    │
└────────┬────────┘                    └────────┬────────┘                  └─────────────────┘
         │                                      │
         │  Share link: https://host/p/{cakeId} │
         └──────────────────────────────────────┘
```

---

## Project Structure

```
SE Project/
├── README.md
├── PROJECT_CHECKLIST.md
├── docs/                              # SE documentation (SRS, SDD, user manual, …)
├── database/
│   └── mongodb_schema.md
├── backend/
│   ├── src/
│   │   ├── server.js                  # /health, /p/:id share pages, /api/*
│   │   ├── data/cakeImageCatalog.js   # Name-matched product images
│   │   ├── controllers/
│   │   ├── models/
│   │   └── routes/
│   └── scripts/seed.js
└── flutter-app/
    └── cake_shop/
        └── lib/
            ├── config/api_config.dart
            ├── widgets/app_logo.dart  # Brand logo
            ├── utils/cake_share.dart  # Share image + link
            └── screens/
```

---

## Quick Start

### 1. MongoDB

**Local:** Install [MongoDB Community](https://www.mongodb.com/try/download/community) and start the service.

**Cloud:** Free cluster at [MongoDB Atlas](https://www.mongodb.com/atlas) — copy the connection string.

### 2. Backend

```bash
cd backend
cp .env.example .env
# Set MONGODB_URI and JWT_SECRET

npm install
npm run seed          # Demo users, 24 cakes, image URLs
npm run dev           # http://localhost:3000
```

Verify: `GET http://localhost:3000/health`  
Share page example: `GET http://localhost:3000/p/{cakeId}`

### 3. Flutter app

```bash
cd flutter-app/cake_shop
flutter pub get
flutter run
```

**Release APK** (uses cloud API — set your Render URL):

```bash
flutter build apk --release \
  --dart-define=PRODUCTION_API_URL=https://YOUR-APP.onrender.com/api
```

Optional public share base (if different from API host):

```bash
--dart-define=PUBLIC_SHARE_URL=https://YOUR-APP.onrender.com
```

### 4. API URL (development)

In debug builds, use **Account → Server connection (dev)** or set mode in app:

| Environment | API base |
|-------------|----------|
| Cloud (production) | `api_config.dart` / `--dart-define=PRODUCTION_API_URL` |
| Android emulator | `http://10.0.2.2:3000/api` |
| Physical device (Wi‑Fi) | `http://YOUR_PC_IP:3000/api` |
| USB (`adb reverse`) | `http://127.0.0.1:3000/api` |

> **Sharing cakes:** Shared links use the **public/cloud URL** when configured. Local IPs (`192.168.x.x`) only work on the same Wi‑Fi.

---

## Deployment (Render + APK)

1. Push `backend/` to GitHub; create a **Web Service** on [Render](https://render.com).
2. Set env vars: `MONGODB_URI`, `JWT_SECRET`, `PUBLIC_APP_URL` (e.g. `https://your-app.onrender.com`).
3. Run `npm run seed` once (Shell or locally against Atlas).
4. Set `PRODUCTION_API_URL` in Flutter and build release APK.
5. Distribute APK; backend-only changes deploy via Git push (no new APK).

---

## API Endpoints (summary)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/health` | No | Health check |
| GET | `/p/:id` | No | Public product share page (HTML + Open Graph) |
| POST | `/api/auth/register` | No | Register |
| POST | `/api/auth/login` | No | Login → JWT |
| POST | `/api/auth/forgot-password` | No | Reset password |
| GET | `/api/auth/profile` | Yes | Profile |
| PUT | `/api/auth/profile` | Yes | Update profile |
| GET | `/api/cakes` | No | List cakes |
| GET | `/api/cakes/:id` | No | Cake detail |
| GET/POST | `/api/cart` | Yes | Cart |
| POST | `/api/orders` | Yes | Place order |
| GET | `/api/orders` | Yes | My orders |
| PATCH | `/api/orders/:id/review` | Yes | Rate delivered order |
| GET | `/api/admin/*` | Admin | Dashboard, orders, customers |

See `backend/README.md` for details.

---

## Demo Credentials

| Role | Email | Password |
|------|-------|----------|
| Customer | customer@test.com | test123 |
| Admin | admin@cakeshop.com | admin123 |

---

## Technology Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter 3, Provider, cached_network_image, share_plus, app_links |
| Backend | Node.js, Express, JWT, bcrypt |
| Database | MongoDB, Mongoose |
| Images | Curated Unsplash URLs per cake name |
| Notifications | flutter_local_notifications |

---

## Documentation

| Document | Path |
|----------|------|
| User manual | `docs/07_User_Manual.md` |
| SRS | `docs/02_SRS_Software_Requirements_Specification.md` |
| System design | `docs/03_System_Design_Document.md` |
| Test plan | `docs/06_Test_Plan_and_Test_Cases.md` |
| Project report | `docs/08_Project_Report.md` |
| Submission checklist | `PROJECT_CHECKLIST.md` |

---

## Branding

- **Display name:** Sweet Delights (launcher, splash, home header)
- **Logo:** Custom tiered-cake mark (`lib/widgets/app_logo.dart` + Android adaptive icon)
- **Theme:** Rose, cream, and gold bakery palette (`lib/theme/app_theme.dart`)

---

*Flutter + Node.js + MongoDB*
