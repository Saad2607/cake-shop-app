# Flutter App — Sweet Delights

Mobile frontend for the Cake Online Shopping App.

## Prerequisites

- Flutter SDK 3.2+
- Running backend API (see `../../backend/README.md`)

## Setup

```bash
flutter pub get

# Generate platform folders if missing:
flutter create . --project-name cake_shop --org com.cakeshop

flutter run
```

## Configure API URL

**Release builds** use the cloud URL from `lib/config/api_config.dart`:

```dart
// Or at build time:
// flutter build apk --release --dart-define=PRODUCTION_API_URL=https://YOUR-APP.onrender.com/api
```

**Debug builds:** Account tab → **Server connection (dev)** (Wi‑Fi / USB / emulator / cloud).

## Build release APK

```bash
flutter build apk --release \
  --dart-define=PRODUCTION_API_URL=https://YOUR-APP.onrender.com/api
```

## Project structure

```
lib/
├── main.dart
├── config/api_config.dart       # Production API & share URL
├── constants/app_branding.dart  # "Sweet Delights"
├── models/
├── services/                    # API, notifications, server settings
├── providers/                   # Auth, cart, orders, wishlist, …
├── screens/
│   ├── home/                    # Main tabs
│   ├── catalog/                 # Cake detail + share
│   ├── profile/                 # Account, settings
│   ├── admin/                   # Admin panel
│   └── auth/
├── widgets/
│   ├── app_logo.dart            # Brand logo
│   └── deep_link_handler.dart   # Open shared cake links
└── utils/
    ├── cake_share.dart          # Share image + product link
    └── cake_visuals.dart        # Name-matched cake images
```

## Main features

- Guest browsing; sign-in required for checkout and orders
- Share cake: photo + link (`/p/{id}` on your server)
- Order notifications, wishlist, delivery addresses
- Settings: notifications, profile, addresses, help
- Admin: cakes, orders, image URL on products

## Demo login

| Email | Password |
|-------|----------|
| customer@test.com | test123 |
| admin@cakeshop.com | admin123 |

## App icon & splash

- Launcher: `android/app/src/main/res/drawable/ic_launcher_foreground.xml`
- Brand widget: `lib/widgets/app_logo.dart`

After icon changes, reinstall the app or run `flutter run` to refresh the launcher icon.
