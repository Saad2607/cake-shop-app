# System Design Document (SDD)

## Sweet Delights — Cake Online Shopping App

**Document ID:** SDD-CAKE-001  
**Version:** 2.0  
**Date:** June 2026

---

## 1. Introduction

### 1.1 Purpose
This document explains **how** we designed the Sweet Delights system — architecture, modules, data flow, and main API endpoints.

### 1.2 Scope
Covers Flutter mobile app, Node.js backend, and MongoDB. Does not cover Play Store publishing process.

---

## 2. System Architecture

### 2.1 Three-tier architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                         │
│   Flutter Screens + Widgets + Provider (state management)     │
└────────────────────────────┬─────────────────────────────────┘
                             │ HTTP + JSON + JWT
┌────────────────────────────▼─────────────────────────────────┐
│                    APPLICATION LAYER                          │
│   Express.js Controllers + Middleware + Services            │
└────────────────────────────┬─────────────────────────────────┘
                             │ Mongoose ODM
┌────────────────────────────▼─────────────────────────────────┐
│                      DATA LAYER                               │
│   MongoDB (users, cakes, cartitems, orders, promos)         │
└──────────────────────────────────────────────────────────────┘
```

### 2.2 Why we chose this design
- **Flutter** — one codebase for Android, fast UI development  
- **REST API** — clear separation; multiple clients possible later  
- **MongoDB** — flexible schema for order items embedded in order document  
- **Provider** — simple state management (team already learning Flutter)  

---

## 3. Flutter App Design

### 3.1 Folder structure

```
lib/
├── main.dart                 # App entry, providers setup
├── config/                   # API URL config
├── models/                   # User, Cake, Order, CartItem, etc.
├── providers/                # Auth, Cart, Order, Cake, Admin...
├── services/                 # ApiService, NotificationService
├── screens/
│   ├── home/                 # MainScreen, HomeTab
│   ├── cart/                 # Cart, Checkout
│   ├── orders/               # Orders list, detail, confirmation
│   ├── profile/              # Profile, settings, wishlist
│   ├── admin/                # Admin tabs and forms
│   └── auth/                 # Login, register
├── widgets/                  # Reusable UI components
├── theme/                    # Colors, fonts
└── utils/                    # Helpers (pricing, auth guard, etc.)
```

### 3.2 Screen flow (Customer)

```
Splash → Onboarding (first time) → MainScreen
                                      │
                    ┌─────────────────┼─────────────────┐
                    ▼                 ▼                 ▼
                  Home              Cart            Orders
                    │                 │                 │
                    ▼                 ▼                 ▼
              CakeDetail          Checkout         OrderDetail
                    │                 │
                    └──── Cart ◄──────┘
```

### 3.3 Screen flow (Admin)

After login with `role = ADMIN`, `AppRouter` opens `AdminMainScreen`:

```
Overview → KPI cards, charts, recent orders
Orders   → Filter, search, update status
Menu     → Product list, add/edit cake
Offers   → Promo CRUD, analytics
Customers→ Customer list with order count
Account  → Profile, logout
```

### 3.4 State management (Provider)

| Provider | Responsibility |
|----------|----------------|
| AuthProvider | Login, register, user profile |
| CakeProvider | Catalog, search, category filter |
| CartProvider | Cart items from API |
| OrderProvider | Place order, list orders |
| PromoProvider | Applied discount code |
| PromoCatalogProvider | Home banner offers |
| AdminProvider | Dashboard, admin CRUD |
| NotificationProvider | Local notification state |
| WishlistProvider | Local wishlist |
| DeliveryAddressProvider | Local saved addresses |

---

## 4. Backend Design

### 4.1 Folder structure

```
backend/src/
├── server.js              # Express app start
├── config/database.js     # MongoDB connect
├── models/                # Mongoose schemas
├── controllers/           # Route logic
├── routes/api.js          # All API routes
├── middleware/auth.js       # JWT + admin check
├── services/promoService.js
└── utils/                 # Validators, pricing, errors
```

### 4.2 API endpoints (summary)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | /api/auth/register | No | Register |
| POST | /api/auth/login | No | Login, returns JWT |
| GET | /api/auth/profile | Yes | Get profile |
| PUT | /api/auth/profile | Yes | Update profile |
| GET | /api/cakes | No | List cakes |
| GET | /api/cakes/:id | No | Cake detail |
| POST | /api/cakes | Admin | Create cake |
| PUT | /api/cakes/:id | Admin | Update cake |
| DELETE | /api/cakes/:id | Admin | Delete cake |
| GET | /api/cart | Yes | Get cart |
| POST | /api/cart | Yes | Add to cart |
| PUT | /api/cart/:id | Yes | Update item |
| DELETE | /api/cart/:id | Yes | Remove item |
| POST | /api/orders | Yes | Place order |
| GET | /api/orders | Yes | My orders |
| PATCH | /api/orders/:id/cancel | Yes | Cancel |
| PATCH | /api/orders/:id/review | Yes | Rate order |
| GET | /api/promos | No | Active promos |
| GET | /api/admin/dashboard | Admin | Stats |
| GET | /api/admin/orders | Admin | All orders |
| PATCH | /api/admin/orders/:id/status | Admin | Update status |
| CRUD | /api/admin/promos | Admin | Manage offers |

### 4.3 Authentication flow

1. User sends email + password to `/api/auth/login`  
2. Server checks bcrypt hash  
3. Server returns JWT token (valid 7 days)  
4. App saves token in SharedPreferences  
5. Every API call sends header: `Authorization: Bearer <token>`  
6. `authMiddleware` verifies token; `adminMiddleware` checks role  

### 4.4 Order placement flow

1. Customer opens checkout  
2. App sends cart items + address + promo code to `POST /api/orders`  
3. Server re-calculates prices from database (security)  
4. Server validates promo via `promoService`  
5. Order document created; cart cleared  
6. Response returned to app → confirmation screen  

### 4.5 Order status flow

```
PENDING → CONFIRMED → BAKING → READY → DELIVERED
    │
    └──→ CANCELLED (customer or admin)
```

Status changes validated in `orderStatus.js` utility.

---

## 5. Database Design

See `04_Database_Design.md` and `database/mongodb_schema.md`.

Collections: **users**, **cakes**, **cartitems**, **orders**, **promos**

Order items are **embedded** inside order document (not separate collection).

---

## 6. Security Design

| Threat | Protection |
|--------|------------|
| Password leak | bcrypt hashing |
| Fake API calls | JWT on protected routes |
| Customer accessing admin | Role check middleware |
| Wrong cart price | Server-side `cakePricing.js` |
| SQL injection | N/A — MongoDB with Mongoose |

---

## 7. Deployment Design

| Environment | Backend | Database | App |
|-------------|---------|----------|-----|
| Development | localhost:3000 | Local MongoDB | Emulator |
| Production | Render.com | MongoDB Atlas | Release APK |

`PUBLIC_APP_URL` used for share links (`/p/:cakeId`).

---

## 8. Design decisions log

| Decision | Reason |
|----------|--------|
| Flutter instead of Kotlin | Faster UI, team preference |
| MongoDB instead of MySQL | Flexible JSON documents for order items |
| Provider instead of Bloc | Simpler for project size |
| Single app for admin + customer | Less work than two apps |
| Image URL instead of upload | Saves time; upload is future work |

---

*Version 2.0 | Sweet Delights SE Project*
