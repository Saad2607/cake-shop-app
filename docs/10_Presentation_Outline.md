# Presentation Outline

## Cake Online Shopping Android App — Project Defense

**Duration:** 15–20 minutes + Q&A  
**Format:** PowerPoint / Google Slides  
**Team:** [Names]

---

## Slide 1: Title Slide

- **Title:** Cake Online Shopping Android App
- Team members & IDs
- Course: Software Engineering
- Supervisor name
- Institution & date

---

## Slide 2: Agenda

1. Problem & motivation
2. Objectives & scope
3. Requirements overview
4. System design & architecture
5. Database design
6. UML diagrams
7. Implementation demo
8. Testing results
9. Conclusion & future work
10. Q&A

---

## Slide 3: Problem Statement

- Traditional cake ordering challenges
- Phone orders → errors, limited hours
- No digital catalog for local bakeries
- **Our solution:** Mobile app for 24/7 browsing and ordering

*Visual: Before/After comparison or pain point icons*

---

## Slide 4: Project Objectives

- User-friendly Android cake shopping app
- Browse, customize, cart, checkout
- Order tracking and history
- Complete SE documentation
- MVVM + Room architecture

---

## Slide 5: Scope

**In Scope:**
- Android app, SQLite, customer features, documentation

**Out of Scope:**
- iOS, real payments, GPS tracking (v1)

---

## Slide 6: Feasibility Summary

| Dimension | Result |
|-----------|--------|
| Technical | ✅ Feasible |
| Economic | ✅ Low cost |
| Operational | ✅ Standard ops |
| Schedule | ✅ 14 weeks |

---

## Slide 7: Functional Requirements

- Authentication (register, login)
- Product catalog (browse, search, filter)
- Shopping cart
- Checkout & orders
- Order history & tracking
- User profile

*Reference SRS document*

---

## Slide 8: Non-Functional Requirements

- Performance: < 3s launch
- Security: Hashed passwords
- Usability: Material Design
- Compatibility: Android 7.0+

---

## Slide 9: System Architecture (MVVM)

```
View → ViewModel → Repository → Room DB
```

- Diagram from SDD
- Layer responsibilities

---

## Slide 10: Use Case Diagram

*Insert exported use case diagram*

- Customer, Guest, Admin actors
- 12 primary use cases

---

## Slide 11: Class Diagram

*Insert class diagram*

- Key entities: User, Cake, CartItem, Order
- Repositories and ViewModels

---

## Slide 12: Database ER Diagram

*Insert ER diagram*

- 5 tables
- Relationships: User→Orders, Order→OrderItems

---

## Slide 13: Sequence Diagram — Place Order

*Insert sequence diagram*

- Checkout flow interaction

---

## Slide 14: UI Design

*Screenshots or wireframes:*
- Login / Register
- Home catalog
- Cake detail
- Cart
- Checkout
- Order confirmation

**Color theme:** Pink (#E91E63) + cream background

---

## Slide 15: Technology Stack

| Layer | Tech |
|-------|------|
| Language | Kotlin |
| UI | Material Design 3 |
| DB | Room (SQLite) |
| Architecture | MVVM |

---

## Slide 16: Implementation Highlights

- Package structure
- Room entities & DAOs
- RecyclerView adapters
- LiveData for reactive UI
- Sample data seeding

*Optional: 1–2 code snippets*

---

## Slide 17: Live Demo

**Demo script (5 min):**
1. Launch app → Login
2. Browse cakes → Filter Birthday
3. Open cake detail → Add to cart
4. View cart → Checkout
5. Place order → View confirmation
6. Check order history

*Record backup video if live demo risky*

---

## Slide 18: Testing

- Test plan overview
- 29+ test cases
- Pass rate: ___%
- Tools: JUnit, Espresso, manual

*Table of results*

---

## Slide 19: Challenges & Solutions

| Challenge | Solution |
|-----------|----------|
| Learning Android/Kotlin | Official docs, tutorials |
| Cart total calculation | Centralized calculator |
| DB relationships | Early schema review |

---

## Slide 20: Conclusion

- Successfully delivered MVP cake shopping app
- Full SDLC documentation
- Meets primary requirements
- Ready for extension (Firebase, payments)

---

## Slide 21: Future Work

- Real payment gateway
- Push notifications
- Multi-bakery marketplace
- Web admin panel
- iOS version

---

## Slide 22: Thank You / Q&A

- Questions?
- Contact: [team email]
- GitHub / project folder path

---

## Presenter Assignment (Suggested)

| Slides | Presenter |
|--------|-----------|
| 1–3 | Member 1 (Intro) |
| 4–8 | Member 2 (Requirements) |
| 9–13 | Member 3 (Design) |
| 14–17 | Member 4 (Implementation & Demo) |
| 18–22 | All / Member 1 (Testing & Close) |

---

## Tips for Defense

1. **Rehearse demo** on actual device beforehand
2. **Backup APK** and screen recording
3. **Know your UML** — examiners often ask about diagrams
4. **Trace requirements** — link features to SRS IDs
5. **Time management** — 2 min per slide average

---

*Document Version: 1.0 | June 2026*
