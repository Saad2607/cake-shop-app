# Test Plan and Test Cases

## Sweet Delights — Cake Online Shopping App

**Document ID:** TEST-CAKE-001  
**Version:** 2.0  
**Date:** June 2026  
**Tester:** [Team Member Name]

---

## 1. Introduction

### 1.1 Purpose
This document describes how we tested Sweet Delights before submission. It includes test strategy, environment, test cases, and results.

### 1.2 Scope
- Manual testing of Flutter app (customer + admin flows)  
- Manual API testing with Postman / Thunder Client  
- Basic validation of login, cart, checkout, admin status update  

### 1.3 Out of scope
- Load testing with 1000+ users  
- iOS testing  
- Penetration testing  
- Automated Espresso tests (we use Flutter, not native Android)  

---

## 2. Test Strategy

| Level | Method | Who | Focus |
|-------|--------|-----|-------|
| Unit | Manual logic check | Dev | Price calculation, promo discount |
| Integration | API + DB | Dev | Login → cart → order chain |
| System | Manual on phone | Team | Full user journeys |
| UAT | Friends / team | 3–5 people | Usability feedback |

### 2.1 Entry criteria
- Backend running on port 3000  
- MongoDB seeded with demo data  
- Flutter app builds without errors  
- Test accounts working  

### 2.2 Exit criteria
- All high-priority test cases passed  
- No critical bug open (crash on checkout, login fail)  
- Test results table filled  

---

## 3. Test Environment

| Item | Detail |
|------|--------|
| Device 1 | Android Emulator Pixel 6 API 34 |
| Device 2 | Real phone Android 12 |
| Backend | Node.js on localhost / Render |
| Database | MongoDB local or Atlas |
| OS | Windows 10/11 dev machine |
| App build | Debug APK |

**Test accounts:**
- Customer: `customer@test.com` / `test123`  
- Admin: `admin@cakeshop.com` / `admin123`  

---

## 4. Test Schedule

| Week | Activity |
|------|----------|
| 11 | Write test cases |
| 12 | Execute customer flow tests |
| 12 | Execute admin flow tests |
| 13 | Bug fix and retest |
| 13 | Fill results table for report |

---

## 5. Test Cases

### 5.1 Authentication

| TC ID | Test Case | Steps | Expected | Priority |
|-------|-----------|-------|----------|----------|
| TC-AUTH-01 | Valid login | Enter customer@test.com + test123, tap Sign In | Home screen opens | High |
| TC-AUTH-02 | Invalid password | Wrong password | Error message shown | High |
| TC-AUTH-03 | Register new user | Fill register form with new email | Account created, can login | High |
| TC-AUTH-04 | Logout | Account → Logout | Returns to logged-out state | Medium |
| TC-AUTH-05 | Admin login | Login as admin@cakeshop.com | Admin panel opens | High |

### 5.2 Catalog

| TC ID | Test Case | Steps | Expected | Priority |
|-------|-----------|-------|----------|----------|
| TC-CAT-01 | Browse home | Open app as guest | Cakes visible on home | High |
| TC-CAT-02 | Search | Type "chocolate" in search | Matching cakes shown | High |
| TC-CAT-03 | Category filter | Tap Wedding category | Only wedding cakes | Medium |
| TC-CAT-04 | Cake detail | Tap any cake card | Detail page with sizes | High |
| TC-CAT-05 | Out of stock | Admin marks unavailable | Customer sees unavailable | Medium |

### 5.3 Cart & Checkout

| TC ID | Test Case | Steps | Expected | Priority |
|-------|-----------|-------|----------|----------|
| TC-CART-01 | Add to cart | Select size, tap Add to Cart | Item in cart tab | High |
| TC-CART-02 | Update quantity | Increase qty in cart | Total updates | High |
| TC-CART-03 | Remove item | Swipe or delete item | Item removed | Medium |
| TC-ORD-01 | Checkout guest blocked | Cart → checkout without login | Login prompt | High |
| TC-ORD-02 | Place order COD | Complete checkout with COD | Order confirmation shown | High |
| TC-ORD-03 | Apply promo SWEET50 | Apply code at checkout | Discount reflected | Medium |
| TC-ORD-04 | Empty cart checkout | Try checkout with empty cart | Blocked / message | Medium |

### 5.4 Orders

| TC ID | Test Case | Steps | Expected | Priority |
|-------|-----------|-------|----------|----------|
| TC-TRACK-01 | Order history | Orders tab after placing order | Order listed | High |
| TC-TRACK-02 | Order detail | Tap order | Items, total, status shown | High |
| TC-TRACK-03 | Cancel pending | Cancel PENDING order | Status = CANCELLED | Medium |
| TC-TRACK-04 | Status update | Admin sets BAKING | Customer sees new status | High |
| TC-TRACK-05 | Rate order | Rate after DELIVERED | Rating saved | Low |

### 5.5 Admin

| TC ID | Test Case | Steps | Expected | Priority |
|-------|-----------|-------|----------|----------|
| TC-ADMIN-01 | Dashboard loads | Open Overview tab | KPI cards visible | Medium |
| TC-ADMIN-02 | Add cake | Menu → Add → Save | Cake in list | High |
| TC-ADMIN-03 | Edit cake | Edit name/price | Changes saved | High |
| TC-ADMIN-04 | Delete cake | Remove → confirm dialog | Cake removed | High |
| TC-ADMIN-05 | Update order status | Orders → change status | Saved on server | High |
| TC-ADMIN-06 | Add promo offer | Offers → Add offer | Shows on home | Medium |

### 5.6 API (Postman)

| TC ID | Endpoint | Expected |
|-------|----------|----------|
| TC-API-01 | GET /health | 200 OK |
| TC-API-02 | POST /api/auth/login | 200 + token |
| TC-API-03 | GET /api/cakes | JSON array |
| TC-API-04 | POST /api/orders (with token) | 201 order created |

---

## 6. Test Results Summary

*Fill this table when you run tests before viva.*

| TC ID | Date | Tester | Result | Notes |
|-------|------|--------|--------|-------|
| TC-AUTH-01 | | | Pass / Fail | |
| TC-AUTH-05 | | | Pass / Fail | |
| TC-CAT-01 | | | Pass / Fail | |
| TC-ORD-02 | | | Pass / Fail | |
| TC-TRACK-04 | | | Pass / Fail | |
| TC-ADMIN-04 | | | Pass / Fail | |
| TC-ADMIN-05 | | | Pass / Fail | |

**Summary (example — update with real numbers):**
- Total cases executed: 25  
- Passed: 23  
- Failed: 2 (fixed and retested)  
- Pass rate: 92%  

---

## 7. Bugs Found During Testing

| Bug ID | Description | Severity | Status |
|--------|-------------|----------|--------|
| BUG-01 | Cart total wrong for 2kg size | High | Fixed |
| BUG-02 | Admin notification count wrong | Medium | Fixed |
| BUG-03 | Promo not refreshing on home pull | Low | Fixed |
| BUG-04 | Card payment is mock only | Low | Known limitation |

---

## 8. UAT Feedback (informal)

We showed the app to 3 classmates. Common feedback:
- UI looks good and similar to food apps  
- Wanted photo upload for custom cake (future work)  
- Understood order tracking easily  
- Admin panel was clear for demo  

---

*Version 2.0 — Flutter + Node.js + MongoDB*
