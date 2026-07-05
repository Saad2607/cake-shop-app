# Software Engineering Project Checklist

## Cake Online Shopping App (Flutter + Node.js + MongoDB)

---

## Phase 1: Environment Setup

- [ ] Install Node.js 18+
- [ ] Install MongoDB (local) OR create MongoDB Atlas cluster
- [ ] Install Flutter SDK 3.2+
- [ ] Copy `backend/.env.example` to `backend/.env`
- [ ] Set `MONGODB_URI` in `.env`

---

## Phase 2: Backend

- [ ] Start MongoDB service (if local)
- [ ] `cd backend && npm install`
- [ ] `npm run seed` — demo users & cakes in MongoDB
- [ ] `npm run dev` — API running on port 3000
- [ ] Test: `GET http://localhost:3000/health`
- [ ] Test login: `POST http://localhost:3000/api/auth/login`

---

## Phase 3: Flutter Frontend

- [ ] `cd flutter-app/cake_shop`
- [ ] `flutter pub get`
- [ ] Run `flutter create .` if platform folders missing
- [ ] Set `ApiConfig.baseUrl` in `lib/config/api_config.dart`
- [ ] `flutter run` on emulator/device
- [ ] Test full flow: login → browse → cart → checkout → orders

---

## Phase 4: Documentation

- [ ] Fill team names in proposal & report
- [ ] Update SDD with Flutter + Node.js + MongoDB architecture
- [ ] Export UML diagrams as PNG
- [ ] Add screenshots to project report
- [ ] Complete test case execution log

---

## Phase 5: Submission

- [ ] APK build: `flutter build apk`
- [ ] Presentation slides from `docs/10_Presentation_Outline.md`
- [ ] Demo video backup
- [ ] Submit all docs + source code

---

## Deliverables

| # | Deliverable | Location |
|---|-------------|----------|
| 1 | Flutter App | `flutter-app/cake_shop/` |
| 2 | Node.js API | `backend/` |
| 3 | MongoDB Schema | `database/mongodb_schema.md` |
| 4 | Documentation | `docs/` |
| 5 | Project Report | `docs/08_Project_Report.md` |

---

## Demo Credentials

| Email | Password |
|-------|----------|
| customer@test.com | test123 |
| admin@cakeshop.com | admin123 |

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
