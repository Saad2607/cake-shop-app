# System Design Document (SDD)

## Cake Online Shopping Android App

**Document ID:** SDD-CAKE-001  
**Version:** 1.0  
**Date:** June 2026

---

## 1. Introduction

### 1.1 Purpose
This document describes the system architecture, module design, data flow, and interface specifications for the Cake Online Shopping Android App.

### 1.2 Scope
Covers Flutter mobile app, Node.js REST API, and MongoDB database design.

---

## 2. System Architecture

### 2.1 Full-Stack Architecture

```
┌─────────────────┐     HTTP/REST      ┌─────────────────┐     Mongoose     ┌─────────────────┐
│  Flutter App    │ ◄────────────────► │  Node.js API    │ ◄──────────────► │    MongoDB      │
│  (Provider)     │     JWT Auth       │  (Express)      │                  │                 │
└─────────────────┘                    └─────────────────┘                  └─────────────────┘
```

### 2.2 Flutter Client Pattern

```
┌──────────────────────────────────────────────────────────┐
│                        VIEW LAYER                         │
│  Activities / Fragments / XML Layouts / Adapters         │
└─────────────────────────┬────────────────────────────────┘
                          │ observes
┌─────────────────────────▼────────────────────────────────┐
│                     VIEWMODEL LAYER                       │
│  AuthViewModel | CatalogViewModel | CartViewModel |       │
│  OrderViewModel | ProfileViewModel | AdminViewModel       │
└─────────────────────────┬────────────────────────────────┘
                          │ uses
┌─────────────────────────▼────────────────────────────────┐
│                    REPOSITORY LAYER                       │
│  UserRepository | CakeRepository | CartRepository |       │
│  OrderRepository                                          │
└─────────────────────────┬────────────────────────────────┘
                          │ uses
┌─────────────────────────▼────────────────────────────────┐
│                      DATA LAYER                           │
│  HTTP API Service (REST) → Node.js Backend → MongoDB      │
└──────────────────────────────────────────────────────────┘
```

### 2.2 Layer Responsibilities

| Layer | Responsibility |
|-------|----------------|
| **View** | Display UI, capture user input, observe ViewModel state |
| **ViewModel** | Business logic, UI state, survives configuration changes |
| **Repository** | Single source of truth, abstracts data sources |
| **Data** | Persistence (Room), preferences, network |

---

## 3. Module Design

### 3.1 Application Modules

| Module | Package | Description |
|--------|---------|-------------|
| **app** | `com.cakeshop.app` | Application class, DI setup |
| **ui.auth** | `...ui.auth` | Login, Register screens |
| **ui.catalog** | `...ui.catalog` | Home, product list, detail |
| **ui.cart** | `...ui.cart` | Cart management |
| **ui.checkout** | `...ui.checkout` | Checkout flow |
| **ui.orders** | `...ui.orders` | Order history, tracking |
| **ui.profile** | `...ui.profile` | User profile |
| **ui.admin** | `...ui.admin` | Admin dashboard (optional) |
| **data** | `...data` | Entities, DAOs, Database, Repositories |
| **utils** | `...utils` | Helpers, constants, validators |

### 3.2 Screen Flow

```
SplashActivity
    │
    ├──► LoginActivity ◄──► RegisterActivity
    │         │
    │         ▼
    └──► MainActivity (Bottom Navigation)
              │
              ├── HomeFragment ──► CakeDetailActivity
              ├── CartFragment ──► CheckoutActivity ──► OrderConfirmationActivity
              ├── OrdersFragment ──► OrderDetailActivity
              └── ProfileFragment
```

---

## 4. Class Design (Key Classes)

### 4.1 Entity Classes

```kotlin
// User
data class User(
    val id: Long,
    val name: String,
    val email: String,
    val phone: String,
    val passwordHash: String,
    val role: UserRole,  // CUSTOMER, ADMIN
    val createdAt: Long
)

// Cake (Product)
data class Cake(
    val id: Long,
    val name: String,
    val description: String,
    val category: CakeCategory,
    val basePrice: Double,
    val imageUrl: String,
    val flavors: List<String>,
    val sizes: List<CakeSize>,
    val rating: Float,
    val inStock: Boolean
)

// CartItem
data class CartItem(
    val id: Long,
    val userId: Long,
    val cakeId: Long,
    val quantity: Int,
    val selectedSize: String,
    val selectedFlavor: String,
    val customMessage: String?,
    val unitPrice: Double
)

// Order
data class Order(
    val id: Long,
    val orderNumber: String,
    val userId: Long,
    val totalAmount: Double,
    val status: OrderStatus,
    val deliveryAddress: String,
    val deliveryDate: Long,
    val paymentMethod: String,
    val createdAt: Long
)

// OrderItem
data class OrderItem(
    val id: Long,
    val orderId: Long,
    val cakeId: Long,
    val cakeName: String,
    val quantity: Int,
    val size: String,
    val flavor: String,
    val customMessage: String?,
    val price: Double
)
```

### 4.2 Enumerations

```kotlin
enum class CakeCategory { BIRTHDAY, WEDDING, CUPCAKE, CUSTOM, SEASONAL }
enum class OrderStatus { PENDING, CONFIRMED, BAKING, READY, DELIVERED, CANCELLED }
enum class UserRole { CUSTOMER, ADMIN }
```

---

## 5. Database Design

See `04_Database_Design.md` for full ER diagram and schema.

**Tables:** `users`, `cakes`, `cart_items`, `orders`, `order_items`

---

## 6. API Design (Optional Backend)

### 6.1 REST Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register user |
| POST | `/api/auth/login` | Login, return token |
| GET | `/api/cakes` | List cakes (paginated) |
| GET | `/api/cakes/{id}` | Cake detail |
| GET | `/api/cakes/search?q=` | Search |
| POST | `/api/cart/items` | Add to cart |
| GET | `/api/cart` | Get user cart |
| DELETE | `/api/cart/items/{id}` | Remove item |
| POST | `/api/orders` | Place order |
| GET | `/api/orders` | User orders |
| GET | `/api/orders/{id}` | Order detail |
| PATCH | `/api/orders/{id}/status` | Update status (admin) |

### 6.2 Sample JSON — Create Order

```json
{
  "deliveryAddress": "123 Main St, City",
  "deliveryDate": "2026-07-15",
  "paymentMethod": "COD",
  "items": [
    {
      "cakeId": 1,
      "quantity": 1,
      "size": "1kg",
      "flavor": "Chocolate",
      "customMessage": "Happy Birthday!"
    }
  ]
}
```

---

## 7. UI Design Guidelines

### 7.1 Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Primary | `#E91E63` | Buttons, accents (pink — cake theme) |
| Primary Dark | `#C2185B` | Status bar |
| Secondary | `#FF9800` | Highlights |
| Background | `#FFF8F0` | Warm cream background |
| Surface | `#FFFFFF` | Cards |
| Text Primary | `#212121` | Body text |
| Text Secondary | `#757575` | Subtitles |

### 7.2 Typography
- **Headings:** Roboto Medium, 20–24sp
- **Body:** Roboto Regular, 14–16sp
- **Captions:** Roboto Regular, 12sp

### 7.3 Key Screens (Wireframe Descriptions)

**Home Screen**
- Top: Search bar + category chips (horizontal scroll)
- Body: Grid of cake cards (2 columns) — image, name, price, rating
- Bottom nav: Home | Cart (badge) | Orders | Profile

**Cake Detail**
- Hero image, name, price, rating
- Description paragraph
- Dropdowns: Size, Flavor
- Text field: Custom message
- Quantity stepper
- FAB or bottom bar: "Add to Cart"

**Cart**
- List of items with thumbnail, name, options, price
- Swipe to delete or minus button
- Footer: Subtotal, Checkout button

**Checkout**
- Delivery address (EditText)
- Date picker
- Payment method radio (COD / Mock Card)
- Order summary list
- Place Order button

---

## 8. Security Design

| Concern | Implementation |
|---------|----------------|
| Password storage | BCrypt or SHA-256 with salt |
| Session | User ID in EncryptedSharedPreferences |
| Input validation | Email regex, length checks on all forms |
| SQL injection | Room parameterized queries |
| Admin access | Role check in repository before admin ops |

---

## 9. Error Handling

| Scenario | User Message | Action |
|----------|--------------|--------|
| Network failure | "Unable to connect. Please try again." | Retry button |
| Invalid login | "Invalid email or password" | Clear password field |
| Empty cart checkout | "Your cart is empty" | Navigate to home |
| Out of stock | "This item is currently unavailable" | Disable add button |
| DB error | "Something went wrong" | Log to Logcat |

---

## 10. Deployment

### 10.1 Build Variants
- **debug** — Test data preloaded, logging enabled
- **release** — ProGuard/R8 minification, signed APK

### 10.2 Distribution
- Debug APK for supervisor demo
- Optional: Google Play internal testing track

---

## 11. Future Enhancements

1. Firebase Authentication & Firestore sync
2. Real payment gateway (Stripe)
3. Push notifications for order updates
4. Google Maps delivery tracking
5. Wishlist and favorites
6. Multi-language support

---

*Document Version: 1.0 | June 2026*
