# Software Requirements Specification (SRS)

## Cake Online Shopping Android App

**Document ID:** SRS-CAKE-001  
**Version:** 1.0  
**Date:** June 2026

---

## 1. Introduction

### 1.1 Purpose
This Software Requirements Specification describes the functional and non-functional requirements for the Cake Online Shopping Android App. It is intended for developers, testers, project supervisors, and stakeholders.

### 1.2 Scope
The system is an Android mobile application enabling users to browse a cake catalog, customize orders, manage a shopping cart, and place orders. An optional admin module supports product and order management.

### 1.3 Definitions & Acronyms

| Term | Definition |
|------|------------|
| SRS | Software Requirements Specification |
| UI | User Interface |
| API | Application Programming Interface |
| MVP | Minimum Viable Product |
| CRUD | Create, Read, Update, Delete |
| Room | Android SQLite ORM library |

### 1.4 References
- IEEE Std 830-1998 (SRS template guidance)
- Android Developer Documentation
- Material Design 3 Guidelines

### 1.5 Overview
Sections 2–4 cover overall description, functional requirements, and non-functional requirements.

---

## 2. Overall Description

### 2.1 Product Perspective
The app is a standalone Android client with local SQLite storage. It may optionally connect to a REST backend for sync in future versions.

```
┌─────────────────────────────────────┐
│     Cake Online Shopping App        │
│  ┌─────────┐  ┌──────────────────┐  │
│  │   UI    │  │  ViewModel Layer │  │
│  └────┬────┘  └────────┬─────────┘  │
│       │                │            │
│  ┌────▼────────────────▼─────────┐  │
│  │      Repository Layer         │  │
│  └────┬──────────────────────────┘  │
│       │                             │
│  ┌────▼────┐  ┌─────────────────┐  │
│  │  Room   │  │ Retrofit (opt.) │  │
│  │ SQLite  │  │   REST API      │  │
│  └─────────┘  └─────────────────┘  │
└─────────────────────────────────────┘
```

### 2.2 Product Functions (Summary)
- User account management
- Product catalog browsing
- Search and filter
- Shopping cart management
- Order placement and tracking
- Admin product/order management (optional)

### 2.3 User Classes

| User Class | Description | Technical Skill |
|------------|-------------|-----------------|
| Customer | Primary app user | Low–Medium |
| Administrator | Manages catalog and orders | Medium |
| Guest | Browses without login | Low |

### 2.4 Operating Environment
- **OS:** Android 7.0 (Nougat, API 24) and above
- **Devices:** Smartphones and tablets (min 4.5" screen)
- **Network:** Wi-Fi or mobile data (optional for offline catalog)

### 2.5 Design & Implementation Constraints
- Must use Kotlin as primary language
- Must use Material Design components
- Local data persistence via Room
- Minimum target SDK: API 34

### 2.6 Assumptions & Dependencies
- Users have Google Play Services (optional)
- Product images are bundled or loaded from URLs
- Payment is simulated (no real gateway in v1.0)
- Delivery is handled outside the app (status updates only)

---

## 3. Functional Requirements

### 3.1 User Authentication (FR-AUTH)

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-AUTH-01 | System shall allow new users to register with name, email, phone, and password | High |
| FR-AUTH-02 | System shall validate email format and password strength (min 6 characters) | High |
| FR-AUTH-03 | System shall allow registered users to login with email and password | High |
| FR-AUTH-04 | System shall display error message for invalid credentials | High |
| FR-AUTH-05 | System shall allow users to logout | Medium |
| FR-AUTH-06 | System shall persist login session until logout | Medium |
| FR-AUTH-07 | System shall allow password change from profile | Low |

### 3.2 Product Catalog (FR-CAT)

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-CAT-01 | System shall display list of cakes with image, name, and price | High |
| FR-CAT-02 | System shall categorize cakes (Birthday, Wedding, Cupcake, Custom, Seasonal) | High |
| FR-CAT-03 | System shall show cake detail page with description, flavors, sizes, and price | High |
| FR-CAT-04 | System shall support search by cake name or keyword | High |
| FR-CAT-05 | System shall filter by category, price range, and rating | Medium |
| FR-CAT-06 | System shall display product ratings and reviews (read-only in v1) | Low |
| FR-CAT-07 | System shall show "Out of Stock" for unavailable items | Medium |

### 3.3 Shopping Cart (FR-CART)

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-CART-01 | System shall allow adding cakes to cart from detail page | High |
| FR-CART-02 | System shall allow selecting quantity, size, and flavor before add | High |
| FR-CART-03 | System shall allow optional custom message on cake (max 50 chars) | Medium |
| FR-CART-04 | System shall display cart with item list, quantities, and subtotal | High |
| FR-CART-05 | System shall allow updating quantity or removing items from cart | High |
| FR-CART-06 | System shall calculate total price including selected options | High |
| FR-CART-07 | System shall persist cart across app sessions for logged-in users | Medium |

### 3.4 Checkout & Orders (FR-ORD)

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-ORD-01 | System shall require login before checkout | High |
| FR-ORD-02 | System shall collect delivery address and contact phone | High |
| FR-ORD-03 | System shall allow selecting delivery date (future dates only) | High |
| FR-ORD-04 | System shall show order summary before confirmation | High |
| FR-ORD-05 | System shall place order and generate unique order ID | High |
| FR-ORD-06 | System shall clear cart after successful order | High |
| FR-ORD-07 | System shall display order confirmation screen | High |
| FR-ORD-08 | System shall simulate payment (Cash on Delivery / Mock Card) | Medium |

### 3.5 Order History & Tracking (FR-TRACK)

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-TRACK-01 | System shall list all past orders for logged-in user | High |
| FR-TRACK-02 | System shall show order details (items, total, date, status) | High |
| FR-TRACK-03 | System shall display order status: Pending, Confirmed, Baking, Ready, Delivered, Cancelled | High |
| FR-TRACK-04 | System shall allow cancelling orders in Pending status only | Medium |

### 3.6 User Profile (FR-PROF)

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-PROF-01 | System shall display user profile (name, email, phone) | Medium |
| FR-PROF-02 | System shall allow editing profile information | Medium |
| FR-PROF-03 | System shall allow saving multiple delivery addresses | Low |

### 3.7 Admin Module (FR-ADMIN) — Optional

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-ADMIN-01 | Admin shall login with separate admin credentials | Medium |
| FR-ADMIN-02 | Admin shall add, edit, delete cake products | Medium |
| FR-ADMIN-03 | Admin shall view all orders and update order status | Medium |
| FR-ADMIN-04 | Admin shall view basic sales summary | Low |

---

## 4. Non-Functional Requirements

### 4.1 Performance (NFR-PERF)

| ID | Requirement |
|----|-------------|
| NFR-PERF-01 | App shall launch within 3 seconds on mid-range device |
| NFR-PERF-02 | Catalog list shall load within 2 seconds |
| NFR-PERF-03 | App shall support catalog of at least 500 products |

### 4.2 Usability (NFR-USE)

| ID | Requirement |
|----|-------------|
| NFR-USE-01 | UI shall follow Material Design 3 guidelines |
| NFR-USE-02 | Primary tasks (browse, add to cart, checkout) shall complete in ≤ 5 taps |
| NFR-USE-03 | App shall provide clear error and success feedback |

### 4.3 Reliability (NFR-REL)

| ID | Requirement |
|----|-------------|
| NFR-REL-01 | App shall not crash during normal operation |
| NFR-REL-02 | Cart and order data shall not be lost on app restart |
| NFR-REL-03 | Invalid input shall be handled gracefully |

### 4.4 Security (NFR-SEC)

| ID | Requirement |
|----|-------------|
| NFR-SEC-01 | Passwords shall be stored hashed (not plain text) |
| NFR-SEC-02 | Session tokens shall be stored in EncryptedSharedPreferences |
| NFR-SEC-03 | Admin functions shall require admin role verification |

### 4.5 Compatibility (NFR-COMP)

| ID | Requirement |
|----|-------------|
| NFR-COMP-01 | App shall run on Android API 24 through API 34 |
| NFR-COMP-02 | UI shall adapt to screen sizes 4.5" to 10" |

### 4.6 Maintainability (NFR-MAIN)

| ID | Requirement |
|----|-------------|
| NFR-MAIN-01 | Code shall follow MVVM architecture |
| NFR-MAIN-02 | Code shall be documented with KDoc for public APIs |
| NFR-MAIN-03 | Project shall use Git for version control |

---

## 5. External Interface Requirements

### 5.1 User Interfaces
- Splash screen → Home/Catalog
- Bottom navigation: Home, Cart, Orders, Profile
- Material cards, RecyclerView lists, FloatingActionButton where appropriate

### 5.2 Hardware Interfaces
- Touchscreen input
- Camera (optional, for profile photo — future)

### 5.3 Software Interfaces
- Android OS, Google Play Services (optional)
- Room Database (SQLite)
- Retrofit for REST API (optional extension)

### 5.4 Communication Interfaces
- HTTP/HTTPS for optional API calls
- No SMS/email in v1.0

---

## 6. Use Case Summary

| Use Case ID | Name | Actor |
|-------------|------|-------|
| UC-01 | Register Account | Customer |
| UC-02 | Login | Customer |
| UC-03 | Browse Catalog | Customer, Guest |
| UC-04 | Search Cakes | Customer |
| UC-05 | View Cake Details | Customer |
| UC-06 | Add to Cart | Customer |
| UC-07 | Manage Cart | Customer |
| UC-08 | Place Order | Customer |
| UC-09 | Track Order | Customer |
| UC-10 | Manage Profile | Customer |
| UC-11 | Manage Products | Admin |
| UC-12 | Manage Orders | Admin |

*Detailed use cases and diagrams: see `05_UML_Diagrams.md`*

---

## 7. Acceptance Criteria

1. All **High** priority functional requirements implemented and tested
2. App runs without crash on Android 7.0+ emulator and one physical device
3. Complete user flow: Register → Browse → Add to Cart → Checkout → View Order
4. Documentation package complete per course rubric

---

## Appendix A: Requirement Traceability Matrix (Sample)

| Requirement | Design Module | Test Case |
|-------------|---------------|-----------|
| FR-AUTH-01 | AuthActivity, UserRepository | TC-AUTH-01 |
| FR-CAT-01 | CatalogFragment, CakeAdapter | TC-CAT-01 |
| FR-CART-01 | CartViewModel, CartDao | TC-CART-01 |
| FR-ORD-05 | CheckoutActivity, OrderRepository | TC-ORD-01 |

---

*Approved by: _________________ Date: _________*
