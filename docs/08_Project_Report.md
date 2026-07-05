# Project Report

## Cake Online Shopping Android App

**Course:** Software Engineering  
**Institution:** [University Name]  
**Department:** [Department Name]  
**Submitted By:** [Team Member Names & IDs]  
**Supervisor:** [Supervisor Name]  
**Date:** June 2026

---

## Abstract

This report documents the complete software development lifecycle of the Cake Online Shopping Android App — a mobile e-commerce application that enables customers to browse, customize, and order cakes from a local bakery. The project follows standard software engineering practices including requirements analysis, system design, implementation using Kotlin and Android Room, testing, and deployment. The application implements user authentication, product catalog, shopping cart, checkout, and order tracking features using MVVM architecture. Results demonstrate a functional MVP suitable for academic evaluation and future commercial extension.

**Keywords:** Android, E-commerce, Kotlin, Room Database, MVVM, Software Engineering

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Literature Review / Background](#2-literature-review--background)
3. [Requirements Analysis](#3-requirements-analysis)
4. [System Design](#4-system-design)
5. [Implementation](#5-implementation)
6. [Testing](#6-testing)
7. [Results & Discussion](#7-results--discussion)
8. [Conclusion & Future Work](#8-conclusion--future-work)
9. [References](#9-references)
10. [Appendices](#10-appendices)

---

## 1. Introduction

### 1.1 Background
The food and bakery industry is increasingly adopting digital channels. Mobile apps for food ordering (e.g., Uber Eats, DoorDash) have proven successful, but specialized cake ordering apps remain less common, especially for local bakeries.

### 1.2 Problem Statement
Traditional cake ordering via phone or in-person visits is inconvenient, error-prone, and limits customer choice visibility. A dedicated mobile solution addresses these gaps.

### 1.3 Objectives
- Develop an Android app for online cake shopping
- Implement complete order lifecycle from browse to delivery tracking
- Apply software engineering methodologies and produce full documentation

### 1.4 Scope
Customer-facing Android app with local database. Admin module and cloud backend as optional extensions.

### 1.5 Report Organization
Section 2 reviews related work; Section 3 covers requirements; Section 4 design; Section 5 implementation; Section 6 testing; Section 7 results; Section 8 conclusion.

---

## 2. Literature Review / Background

SECTION

### 2.1 Mobile Commerce
Mobile commerce (m-commerce) has grown significantly with smartphone adoption. Studies show users prefer native apps for repeat purchases due to performance and offline capabilities.

### 2.2 Android Development
Google's Android platform dominates global mobile market share. Kotlin is the recommended language, offering null safety and coroutine support. Material Design 3 provides consistent UX patterns.

### 2.3 Related Applications
| App | Platform | Relevance |
|-----|----------|-----------|
| Uber Eats | iOS/Android | Order flow reference |
| Etsy | iOS/Android | Custom product catalog |
| Local bakery apps | Various | Domain-specific UX |

### 2.4 Gap Analysis
Generic food apps lack cake-specific customization (messages, sizes, delivery dates). Our app fills this niche for academic and small-business contexts.

---

## 3. Requirements Analysis

### 3.1 Requirements Gathering Methods
- Stakeholder interviews (team + supervisor)
- Competitor app analysis
- User stories and use cases

### 3.2 Functional Requirements Summary
See full SRS: `02_SRS_Software_Requirements_Specification.md`

| Module | Key Requirements |
|--------|------------------|
| Auth | Register, login, logout |
| Catalog | Browse, search, filter, detail view |
| Cart | Add, update, remove, persist |
| Orders | Checkout, history, status tracking |
| Profile | View/edit user info |

### 3.3 Non-Functional Requirements
- Performance: Launch < 3s
- Security: Hashed passwords
- Usability: Material Design, ≤ 5 taps for core flow
- Compatibility: API 24–34

### 3.4 Use Case Model
12 use cases identified (see `05_UML_Diagrams.md`).

---

## 4. System Design

### 4.1 Architecture
**MVVM** pattern separates UI, business logic, and data layers.

### 4.2 Database Design
Five tables: users, cakes, cart_items, orders, order_items. ER diagram in `04_Database_Design.md`.

### 4.3 UI Design
Material Design 3 with pink/cream bakery theme. Bottom navigation for primary sections.

### 4.4 UML Diagrams
- Use Case Diagram
- Class Diagram
- Sequence Diagrams (Login, Place Order)
- Activity Diagram (Shopping Flow)
- State Diagram (Order Lifecycle)

*Insert exported diagram images here in final submission.*

---

## 5. Implementation

### 5.1 Technology Stack
| Component | Technology |
|-----------|------------|
| Language | Kotlin 1.9 |
| IDE | Android Studio |
| Min SDK | 24 |
| Target SDK | 34 |
| Database | Room 2.6 |
| UI | XML + Material Components |
| Architecture | MVVM |

### 5.2 Project Structure
```
com.cakeshop.app/
├── data/          # Entities, DAOs, Database, Repositories
├── ui/            # Activities, Fragments, Adapters
├── viewmodel/     # ViewModels
└── utils/         # Validators, Constants
```

### 5.3 Key Implementation Details

**Authentication:** Password hashed with SHA-256 before storage. Session stored in SharedPreferences.

**Catalog:** RecyclerView with GridLayoutManager. Category filtering via SQL WHERE clause.

**Cart:** Room table linked to user_id. LiveData observes cart changes for real-time UI updates.

**Orders:** Transaction wraps order + order_items insert and cart clear.

### 5.4 Screenshots
*Insert screenshots of: Login, Home, Detail, Cart, Checkout, Orders, Profile*

---

## 6. Testing

### 6.1 Testing Approach
Unit → Integration → UI → Manual → UAT

### 6.2 Test Results Summary

| Category | Total | Passed | Failed | Pass Rate |
|----------|-------|--------|--------|-----------|
| Authentication | 8 | | | |
| Catalog | 6 | | | |
| Cart | 6 | | | |
| Orders | 7 | | | |
| Profile | 2 | | | |
| **Total** | **29+** | | | |

### 6.3 Sample Bugs Found & Fixed
| Bug | Severity | Resolution |
|-----|----------|------------|
| Cart total incorrect with qty 0 | High | Min quantity validation |
| Crash on empty search | Medium | Null-safe adapter |

---

## 7. Results & Discussion

### 7.1 Achievements
- ✅ Functional Android app with core e-commerce flow
- ✅ Complete documentation package (SRS, SDD, UML, tests)
- ✅ Local database with sample data
- ✅ Material Design UI

### 7.2 Limitations
- No real payment integration
- No push notifications
- Single-vendor (one bakery) only
- No cloud sync between devices

### 7.3 Lessons Learned
- Early database schema review prevents costly refactoring
- MVVM simplifies testing ViewModels independently
- User testing reveals UX issues not caught in development

---

## 8. Conclusion & Future Work

### 8.1 Conclusion
The Cake Online Shopping Android App successfully demonstrates a complete software engineering project from requirements to deployment. The app meets primary functional requirements and provides a foundation for real-world bakery deployment.

### 8.2 Future Work
1. Firebase backend for multi-device sync
2. Real payment gateway (Stripe/PayPal)
3. Push notifications for order updates
4. Admin web dashboard
5. Customer reviews and ratings
6. AI-based cake recommendation

---

## 9. References

1. Google. (2024). *Android Developers Documentation*. https://developer.android.com
2. Google. (2024). *Material Design 3*. https://m3.material.io
3. IEEE. (1998). *IEEE Std 830-1998 — Recommended Practice for Software Requirements Specifications*.
4. Sommerville, I. (2016). *Software Engineering* (10th ed.). Pearson.
5. Android Developers. *Guide to App Architecture*. https://developer.android.com/topic/architecture

---

## 10. Appendices

### Appendix A: Team Contribution
| Member | Contribution |
|--------|--------------|
| [Name 1] | SRS, Android development |
| [Name 2] | Database design, testing |
| [Name 3] | UI design, documentation |
| [Name 4] | UML diagrams, presentation |

### Appendix B: Gantt Chart
*Insert project timeline chart*

### Appendix C: Source Code Listing
*Refer to repository: `android-app/CakeShop`*

### Appendix D: Test Case Log
*See `06_Test_Plan_and_Test_Cases.md`*

### Appendix E: User Manual
*See `07_User_Manual.md`*

---

*End of Report*
