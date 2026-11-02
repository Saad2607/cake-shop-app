# Project Report

## Sweet Delights — Cake Online Shopping Android Application

**Course:** Software Engineering  
**Institution:** [Your College Name]  
**Department:** [Computer Science / IT / SE]  
**Submitted By:**  
- [Member 1 Name] — [Roll No.]  
- [Member 2 Name] — [Roll No.]  
- [Member 3 Name] — [Roll No.]  
- [Member 4 Name] — [Roll No.]  

**Guide:** [Supervisor Name]  
**Date:** June 2026

---

## Certificate / Declaration

We hereby declare that the project **"Sweet Delights — Cake Online Shopping App"** submitted for the Software Engineering course is our own work. We have referred documentation and online resources as listed in references. This work has not been submitted elsewhere.

| Name | Signature | Date |
|------|-----------|------|
| | | |
| | | |

**Guide's approval:** ___________________

---

## Abstract

Ordering cakes through phone calls is slow and error-prone for both customer and bakery. Our project **Sweet Delights** is a full-stack mobile solution for this problem.

We developed an **Android application using Flutter** that connects to a **Node.js REST API** and **MongoDB** database. Customers can browse cakes without login, add items to cart with customization (size, flavour, message), apply promo codes, and place orders with cash on delivery or UPI. They can track order status from Pending to Delivered and rate completed orders.

The same application includes an **admin module** for bakery staff. Admin can manage the menu, update order status, create promotional offers, and view a dashboard with sales statistics and charts.

The project follows the complete **Software Development Life Cycle (SDLC)** including feasibility study, requirements specification, system design, UML diagrams, implementation, testing, and documentation. This report describes each phase and the final working system.

**Keywords:** Flutter, Node.js, MongoDB, REST API, JWT, E-commerce, Cake ordering, Software Engineering

---

## Table of Contents

1. Introduction  
2. Literature Survey / Background  
3. Requirements Analysis  
4. System Design  
5. Implementation  
6. Testing  
7. Results and Discussion  
8. Conclusion and Future Work  
9. References  
10. Appendices  

---

## 1. Introduction

### 1.1 Background
Online food ordering apps like Swiggy and Zomato are very common in India. But most small bakeries still depend on phone calls and WhatsApp messages for cake orders. There is no standard way for customers to see full menu, compare prices, or track when the cake is ready.

### 1.2 Problem Statement
- Customers cannot browse cakes 24/7  
- Customization details (size, flavour, message) get misunderstood on call  
- No digital order history for repeat orders  
- Bakery owner has no simple tool to manage orders digitally  

### 1.3 Objectives
1. Build a user-friendly Android app for cake ordering  
2. Implement secure login and role-based admin access  
3. Provide cart, checkout, and order tracking  
4. Give admin tools to manage products and orders  
5. Complete all SE documentation as per syllabus  

### 1.4 Scope
**Included:** Flutter Android app, REST API, MongoDB, customer + admin features, documentation  
**Not included:** iOS app, real payment gateway, live GPS tracking, multi-bakery marketplace  

### 1.5 Organization of Report
Chapter 2 discusses background. Chapter 3 covers requirements. Chapter 4 is design. Chapter 5 is implementation. Chapter 6 is testing. Chapter 7 discusses results. Chapter 8 concludes.

---

## 2. Literature Survey / Background

### 2.1 Existing solutions
| App / System | What it does | Limitation for our case |
|--------------|--------------|-------------------------|
| Bakingo, FNP | Large cake delivery apps | Too complex for college project scope |
| Swiggy/Zomato | Food delivery | Commission model, not bakery-owned app |
| Phone ordering | Traditional | No catalog, no tracking |
| Excel/WhatsApp | Small shops | Manual, no proper software |

### 2.2 Why we built our own
We needed a project that demonstrates **full SDLC** and **client–server architecture** as taught in Software Engineering. A simple local-only app would not show API design, database, and security. So we chose Flutter + Node.js + MongoDB.

### 2.3 Technology comparison (our decision)

| Option | Pros | Cons | Our choice |
|--------|------|------|------------|
| Kotlin + SQLite only | Offline, native | No real backend for SE demo | Not selected |
| Flutter + Firebase | Fast backend | Less control over API design | Considered |
| Flutter + Node + MongoDB | Full stack, clear layers | Needs server hosting | **Selected** |

---

## 3. Requirements Analysis

Detailed SRS is in `02_SRS_Software_Requirements_Specification.md`.

### 3.1 Functional requirements summary
- **Authentication:** Register, login, profile  
- **Catalog:** Browse, search, categories, cake detail  
- **Cart:** Add, update, remove with customization  
- **Orders:** Checkout, payment selection, confirmation  
- **Tracking:** Status updates, cancel, review  
- **Admin:** Menu CRUD, order management, promos, dashboard  

### 3.2 Non-functional requirements
- Password hashing (bcrypt)  
- JWT authentication  
- Material-style responsive UI  
- API response within few seconds on normal network  
- Android API 24+ support  

### 3.3 Use cases
13 main use cases identified — see `05_UML_Diagrams.md` and traceability matrix `11_Requirements_Traceability_Matrix.md`.

### 3.4 Requirements gathering method
- Team discussion with guide  
- Reference from popular food ordering apps  
- SRS template from SE course  

---

## 4. System Design

Full SDD in `03_System_Design_Document.md`.

### 4.1 Architecture
Three-tier: **Presentation (Flutter)** → **Application (Express)** → **Data (MongoDB)**

### 4.2 Module design

**Flutter modules:**
- Auth screens  
- Home / catalog  
- Cart / checkout  
- Orders  
- Profile  
- Admin panel  

**Backend modules:**
- authController  
- cakeController  
- cartController  
- orderController  
- promoController  
- adminController  

### 4.3 Database design
Five MongoDB collections. Order line items embedded in order document. See `04_Database_Design.md`.

### 4.4 UML diagrams
- Use case diagram  
- Class diagram (logical)  
- Sequence diagrams (place order, admin update)  
- Activity diagrams  
- Component and deployment diagrams  

All in `05_UML_Diagrams.md`.

### 4.5 API design
RESTful JSON API with JWT bearer token. Public endpoints for cakes and promos. Protected endpoints for cart and orders. Admin-only routes for management.

---

## 5. Implementation

### 5.1 Development environment
- Windows 10/11  
- VS Code, Android Studio  
- Node.js 18, Flutter 3.2+  
- MongoDB local / Atlas  
- Git for version control  

### 5.2 Backend implementation
**Location:** `backend/src/`

Key implementation points:
- `server.js` — Express app, CORS, routes, health check  
- `models/` — Mongoose schemas with validation  
- `middleware/auth.js` — JWT verify + admin role  
- `utils/cakePricing.js` — server-side price by size (prevents tampering)  
- `services/promoService.js` — discount validation from database  
- `scripts/seed.js` — demo users, cakes, promos  

### 5.3 Flutter implementation
**Location:** `flutter-app/cake_shop/lib/`

Key screens:
| Screen | File | Purpose |
|--------|------|---------|
| Home | `home_tab.dart` | Catalog, search, promos |
| Cake detail | `cake_detail_screen.dart` | Customization |
| Checkout | `checkout_screen.dart` | Address, payment, promo |
| Orders | `orders_tab.dart` | History + tracking |
| Admin dashboard | `admin_dashboard_tab.dart` | KPIs + charts |
| Admin menu | `admin_products_tab.dart` | CRUD cakes |

State management using **Provider** pattern. `ApiService` class handles all HTTP calls.

### 5.4 Security implementation
- Passwords hashed with bcrypt before saving  
- JWT token stored in SharedPreferences  
- Admin routes return 403 if role is not ADMIN  
- Cart prices recalculated on server at checkout  

### 5.5 Challenges during implementation
1. **API connection on real phone** — Solved with configurable server URL in dev settings  
2. **Scroll jump on home refresh** — Fixed with custom refresh indicator  
3. **Admin notifications** — Used polling instead of FCM for simplicity  
4. **Promo system** — Moved from hardcoded list to MongoDB with admin UI  

---

## 6. Testing

Full test plan in `06_Test_Plan_and_Test_Cases.md`.

### 6.1 Testing approach
We mainly did **manual system testing** because of time and team size. Some API endpoints were tested with Postman.

### 6.2 Test cases executed
- Authentication: login, register, admin login  
- Catalog: browse, search, category  
- Cart: add, update, remove  
- Checkout: COD order, promo code  
- Orders: tracking, cancel, admin status update  
- Admin: add cake, delete with confirmation, offers  

### 6.3 Sample results
| Area | Cases | Passed |
|------|-------|--------|
| Auth | 5 | 5 |
| Catalog | 5 | 5 |
| Cart/Order | 8 | 7 |
| Admin | 6 | 6 |
| **Total** | **24** | **23** |

One failure (promo edge case) was fixed and retested.

### 6.4 Bugs fixed
- Cart price mismatch for large sizes  
- Order notification count for admin  
- Custom message not showing in admin order card  
- Checkout scroll overflow on small screens  

---

## 7. Results and Discussion

### 7.1 What we achieved
- Working Android app with customer and admin flows  
- REST API with 25+ endpoints  
- MongoDB database with seed data  
- Promo and dashboard features beyond basic SRS  
- Complete documentation set in `docs/` folder  
- Deployable to Render + MongoDB Atlas  

### 7.2 SRS coverage
Approximately **90%** of requirements fully implemented. Partial items:
- Forgot password (basic, no email OTP)  
- Addresses on device only  
- Payment simulated (not Razorpay live)  
- Product ratings from reviews not aggregated yet  

See `11_Requirements_Traceability_Matrix.md`.

### 7.3 Screenshots (append to printed report)
1. Home screen with promos  
2. Cake detail  
3. Checkout  
4. Order tracking  
5. Admin dashboard  
6. Admin orders  
7. Admin offers  

*Take screenshots from emulator before printing.*

### 7.4 Limitations
- Not published on Play Store  
- No real payment verification  
- No push notifications when app is closed  
- Single bakery only  

### 7.5 Learning outcomes
Our team learned:
- How to design REST API  
- Flutter UI development  
- MongoDB schema design  
- JWT authentication flow  
- Writing SRS, UML, test plan for real project  
- Team coordination with Git  

---

## 8. Conclusion and Future Work

### 8.1 Conclusion
We successfully built **Sweet Delights**, a cake online ordering system with Flutter frontend and Node.js backend. The app allows customers to browse, order, and track cakes, and allows admin to manage the bakery operations from the same application.

The project demonstrates practical application of Software Engineering concepts — requirements analysis, design, implementation, testing, and documentation — as required by our course.

### 8.2 Future enhancements
1. Integrate Razorpay payment gateway  
2. Firebase Cloud Messaging for push notifications  
3. Image upload for custom photo cakes  
4. Save addresses on server  
5. Product reviews on cake detail page  
6. Publish on Google Play Store  
7. iOS version using same Flutter codebase  

---

## 9. References

1. Flutter Documentation — https://docs.flutter.dev  
2. Express.js Guide — https://expressjs.com  
3. MongoDB Manual — https://www.mongodb.com/docs  
4. Mongoose ODM — https://mongoosejs.com  
5. JWT Introduction — https://jwt.io  
6. IEEE SRS Template (course material)  
7. Material Design Guidelines — https://m3.material.io  
8. Provider package — https://pub.dev/packages/provider  

---

## 10. Appendices

### Appendix A — Project file structure
```
SE Project/
├── backend/           Node.js API
├── flutter-app/cake_shop/   Flutter app
├── database/          Schema docs
├── docs/              All SE documents
├── README.md
└── SETUP.md
```

### Appendix B — API endpoint list
See `03_System_Design_Document.md` Section 4.2

### Appendix C — Demo credentials
| Role | Email | Password |
|------|-------|----------|
| Customer | customer@test.com | test123 |
| Admin | admin@cakeshop.com | admin123 |

### Appendix D — Document index
| # | Document |
|---|----------|
| 01 | Project Proposal |
| 02 | SRS |
| 03 | System Design |
| 04 | Database Design |
| 05 | UML Diagrams |
| 06 | Test Plan |
| 07 | User Manual |
| 08 | Project Report (this file) |
| 09 | Feasibility Study |
| 10 | Presentation Outline |
| 11 | Requirements Traceability Matrix |
| 12 | SDLC Phase Summary |

---

*End of Report — Sweet Delights SE Project 2026*
