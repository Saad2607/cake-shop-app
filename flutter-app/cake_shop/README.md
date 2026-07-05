# Flutter App — Cake Shop

Mobile frontend for Cake Online Shopping App.

## Prerequisites

- Flutter SDK 3.2+
- Running backend API (see `../../backend/README.md`)20...............................................

## Setup

```bash
flutter pub get

# Generate platform folders if missing:
flutter create . --project-name cake_shop --org com.cakeshop

flutter run
```

## Configure API URL

Edit `lib/config/api_config.dart`:

```dart
static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
```

## Project Structure

```
lib/
├── main.dart
├── config/api_config.dart
├── models/          # Data models
├── services/        # API HTTP client
├── providers/       # State management (Provider)
├── screens/         # UI screens
└── theme/           # App theme
```

## Demo Login

- Email: `customer@test.com`
- Password: `test123`
