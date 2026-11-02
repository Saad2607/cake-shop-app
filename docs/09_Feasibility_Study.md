# Feasibility Study

## Sweet Delights — Cake Online Shopping App

**Course:** Software Engineering  
**Date:** June 2026

---

## 1. Purpose

Before starting full development, our group checked whether this project is **technically possible**, **affordable**, **usable in real life**, and **finishable in one semester**. This document is that check.

---

## 2. Technical Feasibility

### 2.1 Can we build it with available tech?

| Need | Our choice | Available? |
|------|------------|------------|
| Mobile app | Flutter | Yes — free, good docs |
| Backend API | Node.js + Express | Yes — we studied JavaScript in earlier sem |
| Database | MongoDB | Yes — NoSQL, easy with Node |
| Login security | JWT + bcrypt | Yes — standard approach |
| Images | URL links (Unsplash) | Yes — no own server needed for images |
| Admin panel | Same Flutter app | Yes — role-based routing |

**Result:** Technically feasible.

### 2.2 Team skills

We are SE/CS students with basic knowledge of:
- Programming (C/Java/Python from earlier courses)  
- Some HTML/CSS/JS  
- Database concepts from DBMS subject  
- Flutter was new for most of us but tutorials helped  

One member focused more on backend, two on Flutter UI, one on docs and testing.

### 2.3 Hardware / software needed

**For development:**
- Laptop with 8 GB RAM (16 GB better for emulator)  
- Android Studio or VS Code  
- Node.js installed  
- MongoDB local OR free Atlas account  

**For users:**
- Android phone version 7.0+ (API 24)  
- Internet for API calls  

### 2.4 Technical risks

| Risk | Level | Plan |
|------|-------|------|
| Learning Flutter | Medium | YouTube + official docs |
| Phone not reaching localhost API | Medium | Wi-Fi IP / USB debugging settings in app |
| MongoDB connection fail | Low | Atlas cloud backup |

---

## 3. Economic Feasibility

### 3.1 Cost to build (student project)

| Item | Cost |
|------|------|
| Flutter | Free |
| Node.js, MongoDB tools | Free |
| GitHub | Free |
| MongoDB Atlas M0 | Free |
| Render.com hosting | Free tier |
| **Total** | **₹0** |

### 3.2 If bakery uses it later

They would need:
- Domain name (~₹500–1000/year) — optional  
- Cloud server if traffic grows (~₹500–2000/month)  
- Payment gateway charges (2% per transaction) — future  

For college demo, cost is zero.

### 3.3 Benefit

- Saves shop owner time on phone orders  
- Customer convenience  
- Good learning for our team  
- Portfolio project for placements  

**Result:** Economically feasible for academic use.

---

## 4. Operational Feasibility

### 4.1 Will a bakery actually use it?

| Question | Answer |
|----------|--------|
| Is UI simple enough? | Yes — similar to Swiggy/Zomato style |
| Can admin update orders without training? | Yes — tap status in Orders tab |
| Can admin add new cake? | Yes — form with name, price, image URL |
| Needs full-time IT person? | No — basic smartphone skills enough |

### 4.2 Limitations for real shop

- Payment is simulated (COD + UPI app open) — shop must confirm payment manually  
- Addresses saved on phone only — not synced to cloud yet  
- Single admin account — not multi-staff  

For college project demo, operational feasibility is **acceptable**.

---

## 5. Schedule Feasibility

14-week plan (see proposal). We completed main features in ~10 weeks and used last weeks for testing and docs.

| Milestone | Target | Status |
|-----------|--------|--------|
| SRS + design | Week 4 | Done |
| Working API | Week 6 | Done |
| Customer app flow | Week 8 | Done |
| Admin module | Week 10 | Done |
| Testing + docs | Week 14 | In progress |

**Result:** Schedule feasible with buffer for exams.

---

## 6. Legal / Ethical

- We use demo product images from Unsplash (free to use with attribution in README)  
- User passwords are hashed — not stored plain text  
- Demo accounts only in seed data — no real customer data  
- GDPR not required for academic demo  

---

## 7. Conclusion

| Type | Feasible? |
|------|-----------|
| Technical | Yes |
| Economic | Yes |
| Operational | Yes (for demo / small bakery) |
| Schedule | Yes |

**Recommendation:** Project approved to proceed. We started implementation after guide review of this study.

---

*Prepared by project team | June 2026*
