# Sweet Delights (Flutter)

Android client for Sweet Delights. Talks to the Node API in `../../backend`.

## Requirements

- Flutter 3.2+
- Backend running (see [backend README](../../backend/README.md))

## Run

```bash
flutter pub get
flutter run
```

If platform folders are missing:

```bash
flutter create . --project-name cake_shop --org com.cakeshop
```

## API URL

**Release builds** use the cloud URL from `lib/config/api_config.dart`, or pass it at build time:

```bash
flutter build apk --release \
  --dart-define=PRODUCTION_API_URL=https://your-api.onrender.com/api
```

**Debug builds** — open **Account → Server connection (dev)** to pick Wi‑Fi, USB, emulator, or cloud.

## Release APK

```bash
flutter build apk --release \
  --dart-define=PRODUCTION_API_URL=https://your-api.onrender.com/api
```

The APK is at `build/app/outputs/flutter-apk/app-release.apk`.

## Code layout

```
lib/
├── config/           API & share URL config
├── constants/        App name and branding
├── models/
├── providers/        State (auth, cart, orders, …)
├── screens/          UI (home, cart, admin, auth, …)
├── services/         HTTP client, notifications
├── widgets/          Logo, cake cards, etc.
└── utils/            Share links, images, helpers
```

## Try it out

| | Email | Password |
|---|--------|----------|
| Customer | customer@test.com | test123 |
| Admin | admin@cakeshop.com | admin123 |

## Icon & splash

Launcher icon assets are under `android/app/src/main/res/`. The in-app logo is `lib/widgets/app_logo.dart`. Reinstall the app after changing launcher icons.
