# Project Proposal

## Sweet Delights — Cake Online Shopping App

**Course:** Software Engineering  
**Department:** [Your Department Name]  
**Institution:** [Your College Name]  
**Academic Year:** 2025–2026  
**Submission Date:** June 2026

---

## 1. Project Title

**Sweet Delights — Cake Online Shopping Android Application**

A mobile app where customers can browse cakes, add to cart, place orders, and track delivery. Bakery staff can manage menu, orders, and offers from the same app using an admin account.

---

## 2. Team Details

| # | Name | Roll No. | Role |
|---|------|----------|------|
| 1 | [Member 1] | [ID] | Team Lead / Backend |
| 2 | [Member 2] | [ID] | Flutter / UI |
| 3 | [Member 3] | [ID] | Documentation / Testing |
| 4 | [Member 4] | [ID] | Admin module / DB |

**Guide / Supervisor:** [Supervisor Name]

---

## 3. Abstract

Most small bakeries still take orders on phone call. Customers cannot see full menu, prices, or order status easily. Our project **Sweet Delights** solves this by giving a proper mobile app for cake ordering.

We built a **Flutter Android app** connected to a **Node.js REST API** and **MongoDB** database. Customers can browse without login, add cakes to cart, apply promo codes, pay via COD or UPI, and track orders. Admin can add cakes, update order status, manage offers, and see basic sales charts.

This project covers the full **SDLC** — planning, requirements, design, coding, testing, and documentation — as required in our Software Engineering subject.

---

## 4. Problem Statement

When ordering cakes in the traditional way:

- Customer has to call the shop and explain size, flavour, message again and again  
- No proper menu with photos and prices at night or on holidays  
- Shop owner writes orders on paper — easy to miss or confuse  
- Customer does not know when cake is ready or out for delivery  
- Re-ordering the same cake next year is difficult  

We wanted a simple digital system that a local bakery could actually use, not just a UI mockup.

---

## 5. Objectives

### Main objectives
1. Build an Android app for browsing and ordering cakes  
2. User registration and login with secure password storage  
3. Shopping cart with size, flavour, and custom message  
4. Checkout with address and delivery date  
5. Order history and status tracking (Pending → Delivered)  
6. Admin panel for products and orders  

### Extra objectives (we added during development)
7. Promo banners and discount codes on home screen  
8. Admin dashboard with charts  
9. Share cake link on WhatsApp  
10. Wishlist and saved addresses on device  

---

## 6. Scope

### In scope
- Flutter mobile app (customer + admin in same APK)  
- Node.js + Express backend  
- MongoDB database  
- JWT authentication  
- REST API  
- Documentation (SRS, design, UML, test plan, report)  
- Manual testing + demo APK  

### Out of scope (for this semester)
- iOS app  
- Real payment gateway (Razorpay live keys)  
- Live GPS driver tracking  
- SMS / email OTP (basic forgot password only)  
- Multi-bakery marketplace (only one shop)  

---

## 7. Target Users

| User | Who | What they do |
|------|-----|--------------|
| Guest | Anyone | Browse cakes, search, view promos |
| Customer | Registered user | Cart, checkout, orders, profile |
| Admin | Bakery owner/staff | Menu, orders, offers, dashboard |

---

## 8. Deliverables

1. Working Flutter APK  
2. Backend source code (`backend/`)  
3. MongoDB schema + seed script  
4. All documents in `docs/` folder  
5. Git repository with commit history  
6. Presentation slides for viva  
7. User manual for demo  

---

## 9. SDLC Methodology

We followed a **modified waterfall with iterations**:

| Phase | What we did | Output |
|-------|-------------|--------|
| **Planning** | Topic selection, proposal, feasibility | This document |
| **Requirements** | Discussed features with guide, wrote SRS | `02_SRS_...md` |
| **Design** | Architecture, DB, UML diagrams | `03_`, `04_`, `05_` |
| **Implementation** | Flutter + Node coding | `flutter-app/`, `backend/` |
| **Testing** | Manual test cases, bug fixing | `06_Test_Plan_...md` |
| **Deployment** | Local + optional Render cloud | `SETUP.md` |
| **Maintenance** | Bug fixes after internal demo | Git commits |

We did not use heavy Agile tools (Jira etc.) because team size is small, but we had weekly meetings and updated tasks on WhatsApp / Google Sheet.

---

## 10. Tools & Technologies

| Part | Technology |
|------|------------|
| Mobile app | Flutter 3.2+, Dart |
| State management | Provider |
| Backend | Node.js 18+, Express |
| Database | MongoDB + Mongoose |
| Auth | JWT + bcrypt |
| IDE | VS Code, Android Studio |
| API testing | Postman, Thunder Client |
| Version control | Git, GitHub |
| Docs | Markdown |
| Diagrams | Mermaid (in markdown files) |
| Charts (admin) | fl_chart package |

*Note: Early proposal mentioned Kotlin/Room. During implementation we switched to Flutter + API for faster UI and proper client–server architecture. Guide approved this change.*

---

## 11. Timeline (14 weeks)

| Week | Work |
|------|------|
| 1–2 | Proposal, feasibility, SRS draft |
| 3–4 | System design, database, UML |
| 5–6 | Backend API + auth + cakes |
| 7–8 | Flutter home, cart, checkout |
| 9–10 | Orders, admin panel, promos |
| 11–12 | Testing, bug fixes, polish |
| 13–14 | Final report, PPT, viva prep |

---

## 12. Budget

Academic project — almost zero cost:

| Item | Cost |
|------|------|
| Software | Free |
| MongoDB Atlas free tier | ₹0 |
| Render free hosting (optional) | ₹0 |
| Play Store (optional) | $25 one-time |

---

## 13. Risks

| Risk | What we did |
|------|-------------|
| Team member busy in exams | Divided modules clearly |
| API not connecting on phone | Added Server Settings screen in dev mode |
| Scope too big | Cut iOS, real payment gateway |
| MongoDB not installed | Used Atlas cloud |

---

## 14. Success Criteria

- [x] App runs on Android emulator and real phone  
- [x] Customer can place order end-to-end  
- [x] Admin can update order status  
- [x] Documentation complete in `docs/`  
- [x] Test cases executed and recorded  
- [ ] Viva demo completed successfully  

---

## 15. Approval

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Team Lead | | | |
| Guide | | | |

---

*Version 2.0 | Updated to match Flutter + Node.js + MongoDB implementation*
