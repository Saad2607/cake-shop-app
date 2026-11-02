# User Manual

## Sweet Delights — Cake Online Shopping App

**Version:** 2.0  
**For:** Customers and Admin (bakery staff)  
**Date:** June 2026

---

## 1. Introduction

**Sweet Delights** is a mobile app for ordering cakes online. You can browse the menu without creating an account. Sign in when you want to checkout or see your orders.

This manual explains how to use the app step by step.

---

## 2. Requirements

- Android phone or tablet (version 7.0 or higher)  
- Internet connection  
- APK installed from your project team OR run via Flutter on emulator  

---

## 3. Installation

### For end user (APK)
1. Copy `app-release.apk` to phone  
2. Allow install from unknown sources if asked  
3. Tap APK → Install → Open  

### For developers
```bash
cd flutter-app/cake_shop
flutter pub get
flutter run
```

---

## 4. Demo Accounts

| Role | Email | Password |
|------|-------|----------|
| Customer | customer@test.com | test123 |
| Admin | admin@cakeshop.com | admin123 |

---

## 5. Customer Guide

### 5.1 First launch
1. Splash screen appears  
2. Onboarding slides (first time only) — tap **Get Started**  
3. Home screen opens — you can browse immediately  

### 5.2 Home screen
- **Search bar** — type cake name  
- **Categories** — All, Birthday, Wedding, Cupcake, Custom, Seasonal  
- **Promo banners** — swipe offers; tap to apply code or read info  
- **Cake cards** — tap to open details  
- Pull down to **refresh** menu and offers  

### 5.3 Cake details
- Choose **size** and **flavour**  
- Add optional **message on cake**  
- Tap **Add to Cart** (login required if not signed in)  
- **Wishlist** heart to save locally  
- **Share** button to send cake link  

### 5.4 Cart
- Open **Cart** tab  
- Change quantity or remove items  
- Tap **Proceed to Checkout**  

### 5.5 Checkout
1. Select or add **delivery address** (GPS or manual)  
2. Pick **delivery date**  
3. Enter **promo code** if you have one (e.g. SWEET50)  
4. Choose payment: **COD**, **UPI**, or **Card**  
5. Tap **Place Order**  
6. See confirmation screen with order number  

### 5.6 Orders
- **Orders** tab shows all your orders  
- Tap order for details and status tracker  
- **Cancel** only if status is Pending  
- **Rate** after order is Delivered  

### 5.7 Account
- **Sign In** / **Create Account**  
- View profile, wishlist, help, settings  
- **Logout** from profile menu  

---

## 6. Admin Guide

Login with `admin@cakeshop.com` / `admin123`. App opens **Admin Panel** automatically.

### 6.1 Overview tab
- Today's revenue and orders  
- Charts for last 7 days  
- Quick links to other tabs  

### 6.2 Orders tab
- See all customer orders  
- Filter by status, search by order number  
- Tap order → change status (Pending → Confirmed → Baking → Ready → Delivered)  

### 6.3 Menu tab
- View all cakes  
- **Add menu item** — fill form, paste image URL, save  
- **⋮ menu** on item → Edit, Mark unavailable, Remove (with confirmation)  

### 6.4 Offers tab
- Manage promo banners and discount codes  
- Add / edit / deactivate offers  
- See how many times a code was used  

### 6.5 Customers tab
- List of registered customers  
- Order count and total spent  

### 6.6 Account tab
- Admin profile and logout  

---

## 7. Troubleshooting

| Problem | Solution |
|---------|----------|
| Cannot login | Check internet; verify email/password |
| No cakes showing | Pull to refresh; check backend is running |
| App cannot connect to server | Dev build: Account → Server connection → set PC IP |
| UPI payment | App opens UPI app; confirm payment manually |
| Order not updating | Pull down on Orders tab; wait a few seconds |

---

## 8. Limitations (current version)

- Payment is not a real payment gateway — COD and UPI are simulated for demo  
- Addresses saved on phone only  
- Custom photo cake upload not available yet  
- Notifications work when app is open (polling), not true push when closed  

---

## 9. Support

For college demo: contact project team  
Email: [team-email@college.edu]  
Guide: [Supervisor Name]

---

*Sweet Delights — Software Engineering Project*
