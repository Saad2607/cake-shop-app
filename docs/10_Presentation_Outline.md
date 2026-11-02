# Presentation Outline

## Sweet Delights — Project Defense / Viva

**Duration:** 15–20 minutes + Q&A  
**Team:** [Names and roll numbers]  
**Guide:** [Supervisor Name]

---

## Slide 1 — Title
- **Sweet Delights — Cake Online Shopping App**
- Team names, roll nos.
- Software Engineering Project
- [College Name], June 2026

---

## Slide 2 — Agenda
1. Problem statement  
2. Objectives  
3. SDLC phases  
4. System architecture  
5. Database design  
6. UML (use case + sequence)  
7. **Live demo**  
8. Testing  
9. Conclusion & future work  
10. Q&A  

---

## Slide 3 — Problem Statement
- Phone orders → mistakes, no menu at night  
- Small bakeries have no app  
- **Solution:** Mobile app + backend for ordering and tracking  

*Use simple before/after image or bullet points*

---

## Slide 4 — Objectives
- Android app for cake shopping  
- Cart, checkout, order tracking  
- Admin for menu and orders  
- Full SE documentation  

---

## Slide 5 — SDLC We Followed
Show table from `12_SDLC_Phase_Summary.md`:
Planning → Requirements → Design → Implementation → Testing → Deployment → Docs

Mention we used iterative approach within each phase.

---

## Slide 6 — Technology Stack
| Layer | Tech |
|-------|------|
| Frontend | Flutter, Provider |
| Backend | Node.js, Express |
| Database | MongoDB |
| Auth | JWT, bcrypt |

*Why Flutter?* — Fast UI, one codebase  
*Why MongoDB?* — Flexible order documents  

---

## Slide 7 — System Architecture
Paste diagram from SDD:
```
Flutter App ↔ REST API ↔ MongoDB
```

---

## Slide 8 — Database Design
- 5 collections: users, cakes, cartitems, orders, promos  
- Show ER diagram from `05_UML_Diagrams.md`  

---

## Slide 9 — Use Case Diagram
- Guest, Customer, Admin actors  
- Main use cases: browse, order, admin manage  

---

## Slide 10 — Sequence Diagram
- Place order flow (customer → app → API → DB)  

---

## Slide 11 — LIVE DEMO (5–7 min) ⭐
**Script — practice this:**

1. **Guest browse** — home, search, cake detail  
2. **Customer login** — customer@test.com  
3. **Add to cart** — size, flavour, message  
4. **Checkout** — address, SWEET50 promo, COD  
5. **Admin login** — admin@cakeshop.com  
6. **Update order** — Pending → Baking → Ready  
7. **Customer** — show status change + notification  
8. **Admin** — quick show Offers tab or dashboard chart  

---

## Slide 12 — Key Features Implemented
- Guest browse  
- Server-side price validation  
- Promo system  
- Admin dashboard + charts  
- Share cake link  
- Order reviews  

---

## Slide 13 — Testing
- 25+ manual test cases  
- Pass rate ~90%+  
- Postman API tests  
- Sample bug fix (mention 1 real bug you fixed)  

Show RTM summary from doc 11.

---

## Slide 14 — Challenges Faced
*Be honest — examiners like this:*
- Flutter learning curve  
- Phone connecting to localhost API → solved with server settings  
- Pull-to-refresh UI bug → fixed  
- Started with Kotlin plan, switched to Flutter + API  

---

## Slide 15 — Future Work
- Razorpay real payment  
- FCM push notifications  
- Photo upload for custom cakes  
- Server-synced addresses  
- iOS version  

---

## Slide 16 — Conclusion
- Built full-stack cake ordering system  
- Meets most SRS requirements  
- Ready for demo and documentation submission  
- Thank you  

---

## Slide 17 — Q&A

**Prepare answers for:**
- Why MongoDB not SQL?  
- How is admin secured?  
- How is cart price validated?  
- What is JWT?  
- What would you do differently?  

---

## Demo Backup Plan
- Screen recording video if live demo fails  
- Emulator + phone both ready  
- Backend running before entering room  
- `npm run seed` done morning of viva  

---

*Good luck! — Team Sweet Delights*
