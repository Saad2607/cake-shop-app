# Sweet Delights — Flutter Mobile Client 📱🎨

The Sweet Delights Flutter application provides a unified, cross-platform experience with **Liquid Glass Material 3 theming**, serving **Customers**, **Bakery Kitchen Staff (Admin)**, and **Delivery Partners (Riders)** within a single cohesive codebase.

---

## 🎨 Liquid Glass Design System

Built from first principles for Flutter:
- **Translucent Surfaces**: `BackdropFilter` frosted glass containers with specular top-left highlight borders and gentle diffuse shadows.
- **Color Palette**:
  - Primary Blush Rose: `#C7516B` / `#DE6B7E`
  - Warm Vanilla Cream: `#FFF7F0`
  - Soft Alabaster Background: `#FAF6F2`
  - Deep Espresso / Cocoa Text: `#2B1D19`
  - Champagne Gold Accents: `#E6B980`
- **Midnight Chocolatier Dark Mode**: Deep cocoa tone (`#120B09`) with luminous frosted accents and warm golden highlights.
- **Artisan Custom-Painted Logo**: Scalable, resolution-independent tiered cake brand mark rendered via Flutter's `CustomPainter`.

---

## 🚀 Key Modules & Screen Directory

### 1. Customer Experience
- **Storefront Home (`home_tab.dart`)**: Dynamic promo banners, delivery location indicator, bestsellers carousel, category filters, and floating cart pill.
- **🎨 Interactive Cake Customizer (`cake_customizer_screen.dart`)**:
  - Live 2D/3D cake shape selector (Round, Heart, Square, Multi-Tier).
  - Flavor & frosting picker with instant visual color response.
  - Interactive toppings layer (Macarons, Gold Leaf, Fresh Strawberries, Truffles).
  - **Live Piping Preview**: Real-time calligraphy script rendering custom greeting text directly onto the cake frosting.
  - Photo cake uploader.
- **Cart & Scheduled Checkout (`cart_tab.dart`, `checkout_screen.dart`)**:
  - Saved address selector with location autofill.
  - Delivery date picker with morning, afternoon, and evening time-windows.
  - **Midnight Surprise Delivery** option (11:45 PM – 12:15 AM).
  - Coupon code redemption with live subtotal discounts.
  - Payment simulation (UPI apps, COD, Debit/Credit Card).
- **Celebration Calendar (`celebrations_calendar_screen.dart`)**:
  - Personal calendar to record birthdays and anniversaries with proactive reminders.
- **Live Order Tracking (`order_detail_screen.dart`, `order_tracking_map.dart`)**:
  - Interactive route map with central bakery pin, customer delivery pin, and animated scooter.
  - **🔐 4-Digit Doorstep Delivery PIN Card**: Prominently displayed for customer to share with the delivery partner upon arrival.
  - One-tap phone dialer and WhatsApp chat with the assigned delivery partner.

### 2. Kitchen Display System (KDS) & Admin Panel
- **Tablet KDS Screen (`admin_kds_screen.dart`)**:
  - 4 workflow tabs: **Queue**, **Baking**, **Ready**, and **Dispatch**.
  - Urgency timers (`< 20m` Green, `< 40m` Amber, `> 40m` Red).
  - Highlighted Chef Piping Box for custom messages.
  - One-tap Thermal Receipt and Tax Invoice generation via `printing` and `pdf`.
  - One-tap **"Hand to Rider"** action with automatic driver assignment.
- **Admin Dashboard (`admin_main_screen.dart`)**:
  - Real-time revenue and sales breakdown charts.
  - Instant stock toggles (*"Sold Out for Today"*).
  - Customer lifetime value and order history directory.

### 3. Delivery Partner Portal (`rider_main_screen.dart`)
- **On-Duty / Off-Duty Toggle**: Controls availability for new pickups.
- **Pickups Tab**: Discover cakes marked **READY** in the bakery kitchen and claim them with 1-tap.
- **Active Deliveries Tab**:
  - Customer address with 1-tap **Google Maps Turn-by-Turn Navigation**.
  - Direct call and WhatsApp buttons.
  - **Doorstep PIN Modal**: Enter customer's 4-digit PIN to finalize handover (*with emergency master fallback `0000`*).
- **Delivered History**: Summary of completed trips, daily performance, and past runs.

---

## 📂 Source Code Layout

```
lib/
├── config/              # Production & dev API URLs
├── constants/           # Branding & string constants
├── models/              # User, Order, Cake, CartItem, Celebration, Promo
├── providers/           # 12 Provider state managers (Auth, Rider, Admin, Cart, etc.)
├── screens/
│   ├── admin/           # Dashboard, KDS, Products, Promos, Customers
│   ├── auth/            # Login with 1-tap demo pills, Register, Password Reset
│   ├── cart/            # Cart, Checkout, Scheduled Delivery Slot picker
│   ├── catalog/         # Catalog, Cake Details, Interactive 2D/3D Customizer
│   ├── home/            # Home Tab, Floating Bottom Glass Bar
│   ├── orders/          # Orders Tab, Order Details, Live Route Map & PIN Card
│   ├── profile/         # Profile, Celebration Calendar, Wishlist, Dev Server Settings
│   ├── rider/           # Rider Partner Dashboard (Pickups, Active, History)
│   └── splash_screen.dart
├── services/            # ApiService, InvoiceService, OfflineCache, ServerSettings
├── theme/               # AppTheme, AdminTheme, Glass Theme tokens
├── utils/               # Order status flow, currency formatter, delivery ETA, router
└── widgets/             # GlassContainer, PrimaryButton, OrderTrackingMap, etc.
```

---

## 🏃 Getting Started

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the App
```bash
flutter run
```

### 3. Dev Server Configuration (Physical Devices & Emulators)
In debug builds, open **Account Settings → Server connection (dev)** (or tap the ⚙️ gear icon in the Rider/Admin header) to select your target API server:
- **Android Emulator**: `http://10.0.2.2:3000/api`
- **Physical Device (Wi-Fi)**: `http://192.168.1.17:3000/api` *(replace with your PC's LAN IP)*
- **USB Cable**: `http://127.0.0.1:3000/api` *(with `adb reverse tcp:3000 tcp:3000`)*
- **Cloud (Render)**: Automatically selected in release builds.

---

## 🔑 One-Tap Demo Accounts

The login screen features 1-tap demo chips for rapid role switching:

| Role | Email | Password | Landing Screen |
|:---|:---|:---|:---|
| **Customer** | `customer@test.com` | `test123` | Main Customer Storefront |
| **Bakery Admin** | `admin@cakeshop.com` | `admin123` | Admin Overview & Kitchen Display |
| **Delivery Partner** | `rider@cakeshop.com` | `rider123` | Rider Partner Portal |

---

## 🧪 Testing & Verification

- **Run Static Analysis**:
  ```bash
  flutter analyze
  ```
- **Run Unit & Widget Test Suite**:
  ```bash
  flutter test
  ```
  *(Tests cover Liquid Glass design tokens, User roles, Order status machine, and widget interactions).*

---

## 📦 Building Production APKs

Compile a release APK with your cloud production API URL embedded:

```bash
flutter build apk --release \
  --dart-define=PRODUCTION_API_URL=https://cake-shop-app-0r5r.onrender.com/api
```

The output file is generated at:
`build/app/outputs/flutter-apk/app-release.apk`
