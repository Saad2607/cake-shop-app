# Feasibility Study

## Cake Online Shopping Android App

---

## 1. Introduction

This feasibility study evaluates whether the Cake Online Shopping Android App project is viable from technical, economic, operational, and schedule perspectives. The study supports the go/no-go decision before full development begins.

---

## 2. Technical Feasibility

### 2.1 Technology Availability

| Requirement | Available Solution | Feasible? |
|-------------|-------------------|-----------|
| Mobile platform | Android SDK, Kotlin | ✅ Yes |
| Local database | Room (SQLite) | ✅ Yes |
| UI framework | Material Design 3 | ✅ Yes |
| Image handling | Glide, Coil | ✅ Yes |
| Authentication | Local + Firebase Auth (optional) | ✅ Yes |
| Backend API | Retrofit + REST (optional) | ✅ Yes |

### 2.2 Team Skills

| Skill | Required Level | Team Capability |
|-------|----------------|-----------------|
| Kotlin / Java | Intermediate | Assumed for SE students |
| Android Studio | Basic–Intermediate | Learnable in 2–3 weeks |
| SQL / Database | Basic | Covered in curriculum |
| UI/UX Design | Basic | Templates + Material guidelines |
| Git | Basic | Standard tooling |

### 2.3 Hardware & Software Requirements

**Development:**
- PC/Laptop: 8 GB RAM minimum, 16 GB recommended
- Android Studio + SDK
- Android emulator or physical device (API 24+)

**End User:**
- Android phone/tablet, Android 7.0+
- Internet connection (for sync; offline browse possible with local DB)

### 2.4 Technical Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Learning curve for Android | Medium | Use official docs, tutorials |
| Device fragmentation | Low | Target API 24+, test on 2–3 devices |
| Performance with images | Low | Glide caching, compressed assets |

**Conclusion:** ✅ **Technically feasible** — All required technologies are mature, free, and well-documented.

---

## 3. Economic Feasibility

### 3.1 Development Costs

| Item | Cost (USD) |
|------|------------|
| Android Studio | Free |
| Git / GitHub | Free |
| Emulator | Free |
| Learning resources | Free (official docs, YouTube) |
| Optional Firebase Spark plan | Free tier sufficient |
| Google Play registration | $25 (optional, one-time) |
| **Total (minimum)** | **$0** |

### 3.2 Operational Costs (Post-Launch)

| Item | Monthly Cost |
|------|--------------|
| App hosting (if backend added) | $0–$20 |
| Firebase (free tier) | $0 |
| Domain (optional) | $10–$15/year |

### 3.3 Return on Investment (Business Context)

For a real bakery:
- Increased orders without extra storefront staff
- Reduced phone order errors
- Customer data for marketing
- Break-even possible within months for small bakeries

For **academic project:** Primary ROI is learning and grades, not revenue.

**Conclusion:** ✅ **Economically feasible** — Zero to minimal cost for academic delivery.

---

## 4. Operational Feasibility

### 4.1 User Acceptance

| Stakeholder | Acceptance Factors |
|-------------|-------------------|
| Customers | Familiar e-commerce patterns (Amazon-style browse/cart) |
| Bakery staff | Simple admin screens for product/order updates |
| Supervisor | Complete SDLC documentation |

### 4.2 Organizational Fit

- Aligns with Software Engineering course objectives
- Demonstrates mobile development, DB design, testing, documentation
- Can be extended for final year project or startup prototype

### 4.3 Maintenance & Support

| Aspect | Approach |
|--------|----------|
| Updates | Git version control, semantic versioning |
| Bug fixes | Issue tracker (GitHub Issues) |
| User support | User manual, in-app help (optional) |

**Conclusion:** ✅ **Operationally feasible** — Standard mobile app operations; no special infrastructure required.

---

## 5. Schedule Feasibility

### 5.1 Estimated Effort

| Phase | Person-Hours (4-member team) |
|-------|------------------------------|
| Requirements & docs | 40–60 hrs |
| Design | 30–40 hrs |
| Development | 120–160 hrs |
| Testing | 30–40 hrs |
| Report & presentation | 20–30 hrs |
| **Total** | **240–330 hrs** |

### 5.2 Timeline vs. Academic Semester

- Typical semester: 14–16 weeks
- Recommended project duration: 14 weeks (see proposal Gantt)
- Buffer: 2 weeks for revisions and defense prep

**Conclusion:** ✅ **Schedule feasible** with disciplined weekly milestones.

---

## 6. Legal & Ethical Feasibility

| Concern | Mitigation |
|---------|------------|
| User privacy | Store minimal PII; privacy policy template |
| Payment data | No real payment in v1; mock checkout |
| Copyright (cake images) | Use royalty-free or own photos |
| Terms of service | Template for academic demo |

**Conclusion:** ✅ **Legally feasible** for academic scope with mock payments and proper image licensing.

---

## 7. Overall Feasibility Summary

| Dimension | Result |
|-----------|--------|
| Technical | ✅ Feasible |
| Economic | ✅ Feasible |
| Operational | ✅ Feasible |
| Schedule | ✅ Feasible |
| Legal/Ethical | ✅ Feasible |

### Recommendation

**Proceed with the project.** The Cake Online Shopping Android App is feasible within typical Software Engineering course constraints. Recommended approach: MVP with customer features first, admin module as stretch goal.

---

*Document Version: 1.0 | June 2026*
