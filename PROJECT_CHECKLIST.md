# Software Engineering Project Checklist

## Sweet Delights — Cake Online Shopping App (Flutter + Node.js + MongoDB)

---

## Phase 1: Environment Setup

- [ ] Install Node.js 18+
- [ ] Install MongoDB (local) OR create MongoDB Atlas cluster
- [ ] Install Flutter SDK 3.2+
- [ ] Copy `backend/.env.example` to `backend/.env`
- [ ] Set `MONGODB_URI`, `JWT_SECRET`, and `PUBLIC_APP_URL` in `.env`

---

## Phase 2: Backend

- [ ] Start MongoDB service (if local)
- [ ] `cd backend && npm install`
- [ ] `npm run seed` — demo users, 24 cakes, image URLs
- [ ] `npm run dev` — API on port 3000
- [ ] Test: `GET http://localhost:3000/health`
- [ ] Test share page: `GET http://localhost:3000/p/{cakeId}`
- [ ] Test login: `POST http://localhost:3000/api/auth/login`

---

## Phase 3: Flutter Frontend

- [ ] `cd flutter-app/cake_shop`
- [ ] `flutter pub get`
- [ ] Run `flutter create .` if platform folders missing
- [ ] Set `PRODUCTION_API_URL` in `api_config.dart` or `--dart-define` for release
- [ ] `flutter run` on emulator/device
- [ ] Test: guest browse → sign in → cart → checkout → orders → share cake
- [ ] Test: Settings, notifications, wishlist, reviews

---

## Phase 4: Deployment (optional)

- [ ] Deploy backend to Render with MongoDB Atlas
- [ ] Run `npm run seed` on production database
- [ ] Build APK: `flutter build apk --release --dart-define=PRODUCTION_API_URL=...`
- [ ] Verify shared product links open in browser

---

## Phase 5: Documentation

- [ ] Fill team names in proposal & report
- [ ] Update screenshots (Sweet Delights UI, logo, share, settings)
- [ ] Export UML diagrams as PNG
- [ ] Complete test case execution log

---

## Phase 6: Submission

- [ ] APK build: `flutter build apk --release`
- [ ] Presentation slides from `docs/10_Presentation_Outline.md`
- [ ] Demo video backup
- [ ] Submit all docs + source code

---

## Deliverables

| # | Deliverable | Location |
|---|-------------|----------|
| 1 | Flutter App (Sweet Delights) | `flutter-app/cake_shop/` |
| 2 | Node.js API | `backend/` |
| 3 | MongoDB Schema | `database/mongodb_schema.md` |
| 4 | Documentation | `docs/` |
| 5 | Project Report | `docs/08_Project_Report.md` |

---

## Demo Credentials

| Role | Email | Password |
|------|-------|----------|
| Customer | customer@test.com | test123 |
| Admin | admin@cakeshop.com | admin123 |

---

## MongoDB Connection Examples

| Setup | MONGODB_URI |
|-------|-------------|
| Local | `mongodb://localhost:27017/cake_shop` |
| Atlas | `mongodb+srv://user:pass@cluster.mongodb.net/cake_shop` |

---

## API URL Quick Reference

| Device | baseUrl |
|--------|---------|
| Android Emulator | `http://10.0.2.2:3000/api` |
| iOS Simulator | `http://localhost:3000/api` |
| Physical Phone | `http://YOUR_PC_IP:3000/api` |
