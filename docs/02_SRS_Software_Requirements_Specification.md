# Software Requirements Specification (SRS)

## Sweet Delights — Cake Online Shopping App

**Document ID:** SRS-CAKE-001  
**Version:** 2.0  
**Date:** June 2026  
**Prepared by:** [Team Name]

---

## 1. Introduction

### 1.1 Purpose
This SRS document describes what the **Sweet Delights** cake ordering system should do. It is written for our development team, guide, and examiner. It covers functional requirements, non-functional requirements, and interfaces.

### 1.2 Scope
The system has three parts:
1. **Flutter Android app** — customer and admin UI  
2. **Node.js REST API** — business logic and security  
3. **MongoDB database** — stores users, cakes, cart, orders, promos  

Customers browse and order cakes. Admin manages menu and orders from the same app using admin login.

### 1.3 Definitions

| Term | Meaning |
|------|---------|
| API | Application Programming Interface (backend URLs) |
| JWT | JSON Web Token used for login session |
| COD | Cash on Delivery |
| UPI | Unified Payments Interface (PhonePe, GPay, etc.) |
| Admin | Bakery staff with special login |
| Guest | User who did not login yet |

### 1.4 References
- IEEE 830 style SRS format (from SE syllabus)  
- Flutter documentation — https://flutter.dev  
- Express.js documentation  

---

## 2. Overall Description

### 2.1 Product perspective

```
┌─────────────────┐     HTTPS/JSON      ┌─────────────────┐     Mongoose     ┌──────────┐
│  Flutter App    │ ◄─────────────────► │  Node.js API    │ ◄──────────────► │ MongoDB  │
│  (Android)      │     JWT Token       │  (Express)      │                  │          │
└─────────────────┘                     └─────────────────┘                  └──────────┘
```

The mobile app never talks to database directly. All data goes through API.

### 2.2 Product functions (summary)
- User registration and login  
- Browse cake catalog with search and categories  
- Add to cart with customization  
- Checkout and place order  
- Track order status  
- Admin: manage cakes, orders, offers, view dashboard  

### 2.3 User classes

| User | Description |
|------|-------------|
| Guest | Can browse home, search, view cake details |
| Customer | Can cart, checkout, orders, profile, wishlist |
| Admin | Full admin panel — menu, orders, offers, customers |

### 2.4 Operating environment
- Android 7.0+ (API 24)  
- Internet connection required for API  
- Backend runs on Node 18+ with MongoDB  

### 2.5 Constraints
- College project timeline (one semester)  
- Payment gateway not fully integrated (simulated)  
- Single bakery only (not multi-vendor)  

### 2.6 Assumptions
- User has basic smartphone knowledge  
- Bakery has one admin account  
- Product images are URLs (not uploaded files in v1)  

---

## 3. Functional Requirements

### 3.1 Authentication (FR-AUTH)

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-AUTH-01 | User can register with name, email, phone, password | High | Done |
| FR-AUTH-02 | Email format and password min 6 chars validated | High | Done |
| FR-AUTH-03 | User can login with email and password | High | Done |
| FR-AUTH-04 | Wrong password shows error message | High | Done |
| FR-AUTH-05 | User can logout | Medium | Done |
| FR-AUTH-06 | Login session saved until logout | Medium | Done |
| FR-AUTH-07 | User can update profile | Medium | Done |
| FR-AUTH-08 | Forgot password option | Low | Partial |

### 3.2 Catalog (FR-CAT)

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-CAT-01 | Show cakes with image, name, price | High | Done |
| FR-CAT-02 | Categories: Birthday, Wedding, Cupcake, Custom, Seasonal | High | Done |
| FR-CAT-03 | Cake detail: description, sizes, flavours, price | High | Done |
| FR-CAT-04 | Search by cake name | High | Done |
| FR-CAT-05 | Filter by category, sort options | Medium | Done |
| FR-CAT-06 | Show rating on cake card | Low | Done (static/seed rating) |
| FR-CAT-07 | Show out of stock label | Medium | Done |
| FR-CAT-08 | Promo banners on home | Medium | Done |

### 3.3 Cart (FR-CART)

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-CART-01 | Add cake to cart from detail page | High | Done |
| FR-CART-02 | Select quantity, size, flavour before add | High | Done |
| FR-CART-03 | Optional custom message on cake | Medium | Done |
| FR-CART-04 | View cart with subtotal | High | Done |
| FR-CART-05 | Update quantity or remove item | High | Done |
| FR-CART-06 | Price calculated with size multiplier | High | Done |
| FR-CART-07 | Cart saved on server for logged-in user | Medium | Done |

### 3.4 Orders & Checkout (FR-ORD)

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-ORD-01 | Login required for checkout | High | Done |
| FR-ORD-02 | Delivery address and phone | High | Done |
| FR-ORD-03 | Select delivery date | High | Done |
| FR-ORD-04 | Order summary before confirm | High | Done |
| FR-ORD-05 | Generate unique order number | High | Done |
| FR-ORD-06 | Clear cart after successful order | High | Done |
| FR-ORD-07 | Order confirmation screen | High | Done |
| FR-ORD-08 | Payment method: COD / UPI / Card (simulated) | Medium | Partial |
| FR-ORD-09 | Apply promo code at checkout | Medium | Done |

### 3.5 Order Tracking (FR-TRACK)

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-TRACK-01 | List past orders | High | Done |
| FR-TRACK-02 | Order detail with items and total | High | Done |
| FR-TRACK-03 | Status: Pending, Confirmed, Baking, Ready, Delivered, Cancelled | High | Done |
| FR-TRACK-04 | Cancel order if status is Pending | Medium | Done |
| FR-TRACK-05 | Visual progress tracker | Medium | Done |
| FR-TRACK-06 | Rate order after Delivered | Low | Done |

### 3.6 Profile (FR-PROF)

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-PROF-01 | Show name, email, phone | Medium | Done |
| FR-PROF-02 | Edit profile | Medium | Done |
| FR-PROF-03 | Multiple delivery addresses | Low | Partial (saved on device) |
| FR-PROF-04 | Wishlist | Low | Done (local) |

### 3.7 Admin (FR-ADMIN)

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-ADMIN-01 | Admin login with admin role | High | Done |
| FR-ADMIN-02 | Add, edit, delete cakes | High | Done |
| FR-ADMIN-03 | View and update order status | High | Done |
| FR-ADMIN-04 | Sales summary dashboard | Medium | Done |
| FR-ADMIN-05 | Manage promo offers | Medium | Done |
| FR-ADMIN-06 | View customer list | Low | Done |
| FR-ADMIN-07 | Charts (weekly revenue, status) | Low | Done |

---

## 4. Non-Functional Requirements

### 4.1 Performance
- App should open within 3–4 seconds on mid-range phone  
- Cake list should load within 2–3 seconds on good network  
- API timeout set to 15 seconds  

### 4.2 Usability
- Material-style UI, bottom navigation  
- Guest can browse without forced login  
- Error messages shown in snackbar/dialog  

### 4.3 Reliability
- App should not crash on empty cart or network error  
- Invalid form input shows validation message  
- Server validates price — client cannot send wrong price  

### 4.4 Security
- Passwords stored as bcrypt hash in MongoDB  
- JWT token for authenticated API calls  
- Admin routes check `role === ADMIN`  
- HTTPS recommended for production deployment  

### 4.5 Compatibility
- Android API 24 to 34 tested  
- Different screen sizes supported with responsive layout  

### 4.6 Maintainability
- Code split into screens, providers, services, models  
- Git version control used  
- Seed script for demo data  

---

## 5. External Interface Requirements

### 5.1 User interfaces
- Splash → Onboarding (first time) → Main screen  
- Bottom tabs: Home, Cart, Orders, Account  
- Admin bottom tabs: Overview, Orders, Menu, Offers, Customers, Account  

### 5.2 Hardware
- Touchscreen  
- GPS optional (for delivery address)  
- Internet  

### 5.3 Software interfaces
- REST API over HTTP/JSON  
- MongoDB via Mongoose  
- SharedPreferences for local wishlist/addresses  
- flutter_local_notifications for order alerts  

### 5.4 Communication
- HTTP between app and server  
- Public share page: `GET /p/:cakeId`  

---

## 6. Use Case Summary

| ID | Use Case | Actor |
|----|----------|-------|
| UC-01 | Register account | Customer |
| UC-02 | Login / Logout | Customer, Admin |
| UC-03 | Browse catalog | Guest, Customer |
| UC-04 | Search and filter cakes | Guest, Customer |
| UC-05 | Add to cart | Customer |
| UC-06 | Checkout and pay | Customer |
| UC-07 | Track order | Customer |
| UC-08 | Cancel pending order | Customer |
| UC-09 | Rate delivered order | Customer |
| UC-10 | Manage menu | Admin |
| UC-11 | Update order status | Admin |
| UC-12 | Manage offers | Admin |
| UC-13 | View dashboard | Admin |

Detailed diagrams in `05_UML_Diagrams.md`.

---

## 7. Future Enhancements (not in current version)
- Razorpay payment with webhook  
- FCM push notifications  
- Photo upload for custom cakes  
- Server-synced addresses  
- iOS app  

---

*Version 2.0 — Updated for Flutter + Node.js + MongoDB stack*
