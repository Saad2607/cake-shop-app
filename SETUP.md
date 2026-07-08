# Development setup

Everything you need to run Sweet Delights on your machine.

---

## Requirements

- Node.js 18+
- MongoDB (local install or [MongoDB Atlas](https://www.mongodb.com/atlas) free tier)
- Flutter SDK 3.2+
- Android Studio or VS Code with Flutter extension (optional but helpful)

---

## First-time setup

```bash
# Clone the repo, then:

cd backend
cp .env.example .env
```

Edit `.env`:

```env
MONGODB_URI=mongodb://localhost:27017/cake_shop
JWT_SECRET=change-this-to-a-long-random-string
PUBLIC_APP_URL=http://localhost:3000
```

```bash
npm install
npm run seed
npm run dev
```

In another terminal:

```bash
cd flutter-app/cake_shop
flutter pub get
flutter run
```

---

## Quick checks

| Check | How |
|-------|-----|
| API is up | Open `http://localhost:3000/health` |
| Share page | `http://localhost:3000/p/{any-cake-id-from-seed}` |
| Login works | customer@test.com / test123 |

---

## Connecting the app to your API

| How you're running the app | API base URL |
|----------------------------|--------------|
| Android emulator | `http://10.0.2.2:3000/api` (default in dev menu) |
| Phone on same Wi‑Fi | `http://YOUR_PC_IP:3000/api` |
| USB debugging | `http://127.0.0.1:3000/api` (with `adb reverse`) |
| Release APK | Set `PRODUCTION_API_URL` at build time — see root README |

In debug builds: **Account → Server connection (dev)**.

---

## Deploying

1. Push `backend` to GitHub and deploy on Render (or similar).
2. Set `MONGODB_URI`, `JWT_SECRET`, `PUBLIC_APP_URL=https://your-app.onrender.com`.
3. Run `npm run seed` once on the production database.
4. Build APK with `--dart-define=PRODUCTION_API_URL=https://your-app.onrender.com/api`.

Backend updates deploy with `git push`. App UI changes need a new APK build.

---

## Test accounts

| Role | Email | Password |
|------|-------|----------|
| Customer | customer@test.com | test123 |
| Admin | admin@cakeshop.com | admin123 |

---

## Useful commands

```bash
# Backend
cd backend && npm run dev
cd backend && npm run seed
node backend/scripts/validate-final-images.js

# Flutter
cd flutter-app/cake_shop && flutter run
cd flutter-app/cake_shop && flutter build apk --release --dart-define=PRODUCTION_API_URL=...
```

---

## MongoDB connection strings

| Setup | `MONGODB_URI` |
|-------|----------------|
| Local | `mongodb://localhost:27017/cake_shop` |
| Atlas | `mongodb+srv://user:pass@cluster.mongodb.net/cake_shop` |
