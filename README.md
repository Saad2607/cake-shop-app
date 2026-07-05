# Cake Online Shopping App


A full-stack mobile e-commerce application: **Flutter** frontend, **Node.js** REST API backend, and **MongoDB** database.

---

## Project Overview

| Item | Details |
|------|---------|
| **Project Title** | Cake Online Shopping App |
| **Frontend** | Flutter (Dart) — Android & iOS |
| **Backend** | Node.js + Express + Mongoose |
| **Database** | MongoDB |
| **Auth** | JWT (issued by Node.js API) |
| **Version** | 3.0.0 |

---

## Architecture

```
┌─────────────────┐     HTTP/REST      ┌─────────────────┐     Mongoose     ┌─────────────────┐
│  Flutter App    │ ◄────────────────► │  Node.js API    │ ◄──────────────► │    MongoDB      │
│  (Mobile UI)    │     JWT Auth       │  (Express)      │                  │   (NoSQL DB)    │
└─────────────────┘                    └─────────────────┘                  └─────────────────┘
```

---

## Project Structure

```
SE Project/
├── README.md
├── PROJECT_CHECKLIST.md
├── docs/                          # SE documentation
├── database/
│   └── mongodb_schema.md          # MongoDB collections design
├── backend/                       # Node.js REST API
│   ├── package.json
│   ├── .env.example
│   ├── src/
│   │   ├── server.js
│   │   ├── config/database.js
│   │   ├── models/                # Mongoose schemas
│   │   ├── controllers/
│   │   ├── routes/
│   │   └── middleware/
│   └── scripts/seed.js
└── flutter-app/
    └── cake_shop/                 # Flutter mobile app
```

---

## Quick Start

### 1. MongoDB Setup

**Option A — Local:** Install [MongoDB Community](https://www.mongodb.com/try/download/community) and start the service.

**Option B — Cloud:** Create free cluster at [MongoDB Atlas](https://www.mongodb.com/atlas) and copy connection string.

### 2. Backend Setup

```bash
cd backend
cp .env.example .env
# Edit .env — set MONGODB_URI and JWT_SECRET

npm install
npm run seed    # Seed demo users & cakes
npm run dev     # Start API on http://localhost:3000
```

### 3. Flutter App Setup

```bash
cd flutter-app/cake_shop
flutter pub get
flutter create . --project-name cake_shop --org com.cakeshop  # if needed
flutter run
```

### 4. API URL Configuration

Edit `flutter-app/cake_shop/lib/config/api_config.dart`:

| Environment | baseUrl |
|-------------|---------|
| Android Emulator | `http://10.0.2.2:3000/api` |
| iOS Simulator | `http://localhost:3000/api` |
| Physical Device | `http://YOUR_PC_IP:3000/api` |

---

## API Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/auth/register` | No | Register user |
| POST | `/api/auth/login` | No | Login, returns JWT |
| GET | `/api/auth/profile` | Yes | Get profile |
| PUT | `/api/auth/profile` | Yes | Update profile |
| GET | `/api/cakes` | No | List cakes |
| GET | `/api/cakes/:id` | No | Cake detail |
| GET | `/api/cart` | Yes | Get cart |
| POST | `/api/cart` | Yes | Add to cart |
| PUT | `/api/cart/:id` | Yes | Update quantity |
| DELETE | `/api/cart/:id` | Yes | Remove item |
| POST | `/api/orders` | Yes | Place order |
| GET | `/api/orders` | Yes | Order history |
| PATCH | `/api/orders/:id/cancel` | Yes | Cancel order |

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
| Frontend | Flutter 3, Provider, HTTP |
| Backend | Node.js, Express, JWT, bcrypt |
| Database | MongoDB, Mongoose ODM |
| Auth | JWT tokens |
| API | REST JSON |

---

## Documentation

See `docs/` folder for SRS, SDD, UML diagrams, test plan, user manual, and project report.

---

*Software Engineering Project — June 2026*
