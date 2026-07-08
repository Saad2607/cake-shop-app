# User Manual

## Sweet Delights — User Guide

**Version:** 3.0

---

## 1. Introduction

Welcome to **Sweet Delights** — your mobile app for browsing and ordering handcrafted cakes online. You can explore the menu as a guest and sign in only when you want to checkout or track orders.

---

## 2. System Requirements

- Android smartphone or tablet (primary target)
- Android 7.0 (Nougat) or higher
- At least 50 MB free storage
- Internet connection

---

## 3. Installation

### Option A: From APK
1. Receive the `app-release.apk` file from your team or download link
2. Enable **Install from unknown sources** if prompted
3. Open the APK and tap **Install**
4. Tap **Open** when done

### Option B: From Flutter (developers)
```bash
cd flutter-app/cake_shop
flutter pub get
flutter run
```

---

## 4. Getting Started

### 4.1 First launch
1. **Splash screen** — Sweet Delights logo and branding
2. **Onboarding** (first time) — swipe through features, tap **Get Started**
3. **Home** — browse cakes immediately (no login required)

### 4.2 Create an account
1. Go to **Account** tab → **Create Account** (or **Sign In** → Register)
2. Enter name, email, phone, and password
3. Tap **Register**, then sign in

### 4.3 Sign in
1. **Account** tab → **Sign In**
2. Enter email and password
3. Use **Forgot password?** if needed
4. After sign-in you return to the Account tab (back button does not exit the app)

**Demo account:**
- Email: `customer@test.com`
- Password: `test123`

---

## 5. Using the App

### 5.1 Home — Browse cakes

- **Search** — find cakes by name
- **Categories** — Birthday, Wedding, Cupcake, Custom, Seasonal
- **Delivery ETA** — estimated delivery time chip
- **Promo banner** — offers (e.g. SWEET50 with countdown)
- **Notification bell** — tap for latest order update (when signed in)
- Tap a cake card to open **details**

### 5.2 Cake details

- View photos, description, sizes, flavors, and price
- Optional **custom message** on the cake
- **Add to Cart** — choose size and flavor first
- **Wishlist** (heart icon)
- **Share** — sends cake image, name, price, and a **product link** friends can open in browser or app

### 5.3 Cart & checkout

- **Cart** tab — change quantities, remove items, floating cart bar on Home
- **Checkout** — delivery address (saved Home/Office/Other), date, UPI or COD
- Guest cart merges after login

### 5.4 Orders

- **Orders** tab (sign-in required) — active and past orders
- Tap an order for tracking steps, ETA, and items
- **Cancel** while status is Pending
- **Rate** delivered orders (1–5 stars)

### 5.5 Account & Settings

**Account tab (signed in):**
- Order history shortcut, wishlist
- **Settings** — opens:
  - Order notifications (on/off)
  - Edit profile
  - Delivery addresses
  - Help & support
- Sign out

**Account tab (guest):**
- Sign In / Create Account
- Browse without signing in

### 5.6 Notifications

When order notifications are enabled (Settings), you receive alerts as your order moves through: confirmed → baking → ready → delivered.

### 5.7 Sharing a cake

1. Open any cake → tap **Share**
2. Choose WhatsApp, Messages, etc.
3. Recipient gets image + text + link (e.g. `https://your-server.com/p/...`)
4. Opening the link shows the product page; **Open in app** if Sweet Delights is installed

---

## 6. Navigation Summary

| Tab | Function |
|-----|----------|
| Home | Browse, search, promos |
| Cart | Shopping cart |
| Orders | Track orders (login required) |
| Account | Profile, settings, sign in |

**Back button:** From a non-Home tab, back goes to Home first; from Sign In, back returns to Account.

---

## 7. Admin

Sign in with the admin account to manage the bakery:

| Email | Password |
|-------|----------|
| admin@cakeshop.com | admin123 |

- Dashboard, orders, customers
- Add/edit cakes with image URL preview
- Update order status (triggers customer notifications)

---

## 8. Troubleshooting

| Problem | Solution |
|---------|----------|
| Login fails | Check credentials; use demo account or register |
| Shared link does not open for friends | Use release APK with cloud server URL, not PC IP |
| Images not loading | Check internet; re-run backend seed if needed |
| Cart empty after login | Guest cart syncs on login — add items again if needed |
| Notifications not showing | Enable in Settings; allow notification permission on Android |
| API connection error (dev) | Set server in Account → Server connection (dev) |

---

## 9. FAQ

**Q: Can I browse without an account?**  
A: Yes. Sign in is required for checkout and order history.

**Q: Is payment real?**  
A: UPI opens your wallet apps; cash on delivery is also available. Configure your merchant UPI ID in the app for live payments.

**Q: Does the shared link work for everyone?**  
A: Yes, as long as the app was built with a public server URL (not a home Wi‑Fi IP). Links look like `https://your-server.com/p/...`.

**Q: How do I update cake photos?**  
A: Sign in as admin, edit the product, and paste a new image URL. Default images come from the backend seed script.

---

## 10. Privacy

We store your name, email, phone, and order history on the server. Passwords are hashed. Shared product links only show public cake info (name, price, description, image).

---

## 11. Changelog

| Version | Notes |
|---------|--------|
| 1.0 | First release |
| 3.0 | Branding, settings, share links, notifications, reviews, saved addresses, guest browse |

---

Questions or issues? Open an issue on GitHub or contact the maintainer.
