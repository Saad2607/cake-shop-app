# Sweet Delights — Backend REST API 🚀

The backend for the Sweet Delights application is a high-performance **Node.js** and **Express** REST API connected to **MongoDB Atlas**, featuring role-based access control (`CUSTOMER`, `ADMIN`, `RIDER`), automated delivery assignment, and 4-digit doorstep PIN security.

---

## 🛠️ Tech Stack & Dependencies

- **Runtime**: Node.js (v18+)
- **Framework**: Express 4.19+
- **Database**: MongoDB (Mongoose 8.3+)
- **Authentication**: JSON Web Tokens (`jsonwebtoken` 9.0+) with `bcryptjs` password hashing
- **Input Validation**: `express-validator` 7.0+
- **Dev Tooling**: `nodemon` for zero-downtime hot reload

---

## 📦 Directory Structure

```
backend/
├── scripts/
│   ├── ensure_rider.js          # Ensures demo delivery partner exists in database
│   ├── link_unassigned_orders.js # Utility to link legacy unassigned orders to active riders
│   ├── seed.js                  # Database seeder with cakes, promos, admin & customer users
│   └── validate-final-images.js # Image URL validator
├── src/
│   ├── config/                  # Database connection setup
│   ├── controllers/
│   │   ├── adminController.js   # Analytics, customer management
│   │   ├── authController.js    # Register, login, forgot-password, profile
│   │   ├── cakeController.js    # Cake catalog, search, filter, CRUD
│   │   ├── cartController.js    # Persistent server-side cart
│   │   ├── orderController.js   # Order placement, status pipeline, auto-assignment
│   │   ├── promoController.js   # Coupon and discount engine
│   │   └── riderController.js   # Pickups, active deliveries, OTP completion
│   ├── middleware/
│   │   └── auth.js              # authMiddleware, adminMiddleware, riderMiddleware
│   ├── models/
│   │   ├── Cake.js              # Cake schema with pricing per size & flavor options
│   │   ├── CartItem.js          # Server cart item schema
│   │   ├── Order.js             # 6-stage order schema with Rider & OTP fields
│   │   ├── Promo.js             # Promotional offers schema
│   │   └── User.js              # User schema with roles (CUSTOMER, ADMIN, RIDER)
│   ├── routes/
│   │   └── api.js               # Route definitions
│   ├── utils/
│   │   ├── cakePricing.js       # Dynamic size & weight pricing logic
│   │   ├── errors.js            # Central error formatting
│   │   ├── orderStatus.js       # Order state transitions state machine
│   │   └── validators.js        # Input validation rules
│   └── server.js                # Server entry point
├── .env.example
├── package.json
└── README.md
```

---

## 🚦 Order Status State Machine

The order lifecycle adheres strictly to a 6-stage finite state machine defined in [`src/utils/orderStatus.js`](src/utils/orderStatus.js):

| Transition | Allowed Next Statuses | Actor | Description |
|:---|:---|:---|:---|
| `PENDING` | `CONFIRMED`, `BAKING`, `CANCELLED` | Customer / Bakery | Customer placed order; bakery kitchen acknowledges |
| `CONFIRMED` | `BAKING`, `CANCELLED` | Bakery Kitchen | Order scheduled for oven prep |
| `BAKING` | `READY`, `CANCELLED` | Bakery Kitchen | Cake baking & artisan piping in progress |
| `READY` | `OUT_FOR_DELIVERY`, `DELIVERED`, `CANCELLED` | Bakery / Rider | Cake boxed; ready for rider pickup or counter collection |
| `OUT_FOR_DELIVERY` | `DELIVERED`, `CANCELLED` | Delivery Partner | Rider dispatched on scooter; OTP generated |
| `DELIVERED` | *(Terminal)* | Customer & Rider | Doorstep 4-digit PIN verified; order finalized |
| `CANCELLED` | *(Terminal)* | Customer / Admin | Order cancelled & refunded |

---

## 📡 API Reference Overview

### 1. Authentication (`/api/auth`)
| Method | Endpoint | Access | Description |
|:---|:---|:---|:---|
| `POST` | `/api/auth/register` | Public | Register customer account |
| `POST` | `/api/auth/login` | Public | Sign in & receive JWT bearer token |
| `POST` | `/api/auth/forgot-password` | Public | Reset account password |
| `GET` | `/api/auth/profile` | Authenticated | Retrieve authenticated user profile |
| `PUT` | `/api/auth/profile` | Authenticated | Update user name and contact phone |

### 2. Catalog & Cart (`/api`)
| Method | Endpoint | Access | Description |
|:---|:---|:---|:---|
| `GET` | `/api/cakes` | Public | List cakes with category, search, and sort filters |
| `GET` | `/api/cakes/:id` | Public | Get single cake details |
| `GET` | `/api/cart` | Authenticated | Retrieve user's server-synchronized cart |
| `POST` | `/api/cart` | Authenticated | Add item to cart with size, flavor, custom text |
| `PUT` | `/api/cart/:id` | Authenticated | Update cart item quantity |
| `DELETE`| `/api/cart/:id` | Authenticated | Remove item from cart |

### 3. Customer Orders (`/api/orders`)
| Method | Endpoint | Access | Description |
|:---|:---|:---|:---|
| `POST` | `/api/orders` | Authenticated | Place order (generates 4-digit delivery PIN) |
| `GET` | `/api/orders` | Authenticated | View customer's order history |
| `GET` | `/api/orders/:id` | Authenticated | Get order details with live tracking info |
| `PATCH`| `/api/orders/:id/cancel` | Authenticated | Cancel pending order |
| `PATCH`| `/api/orders/:id/review` | Authenticated | Submit star rating and feedback comment |

### 4. Delivery Partner API (`/api/rider`)
*Requires `Authorization: Bearer <token>` with `role: 'RIDER'` or `'ADMIN'`.*

| Method | Endpoint | Description |
|:---|:---|:---|
| `GET` | `/api/rider/orders/available` | List orders in `READY` status awaiting pickup |
| `GET` | `/api/rider/orders/active` | List orders currently `OUT_FOR_DELIVERY` assigned to rider |
| `GET` | `/api/rider/orders/history` | List completed deliveries for rider |
| `PATCH`| `/api/rider/orders/:id/pickup` | Rider claims order $\to$ moves to `OUT_FOR_DELIVERY` |
| `PATCH`| `/api/rider/orders/:id/deliver` | Verify customer's 4-digit PIN $\to$ moves to `DELIVERED` |

### 5. Bakery Admin API (`/api/admin`)
*Requires `Authorization: Bearer <token>` with `role: 'ADMIN'`.*

| Method | Endpoint | Description |
|:---|:---|:---|
| `GET` | `/api/admin/dashboard` | KPI analytics (revenue, order counts, status breakdown) |
| `GET` | `/api/admin/orders` | All orders with filter (`status`, search by customer/order) |
| `PATCH`| `/api/admin/orders/:id/status` | Update order status (with auto-rider assignment) |
| `GET` | `/api/admin/riders` | List all registered delivery partners |
| `GET` | `/api/admin/customers` | Customer directory with lifetime orders and total spend |
| `GET` | `/api/admin/promos` | Manage promotional coupon codes |

---

## 💻 Local Setup & Execution

1. **Install dependencies**:
   ```bash
   cd backend
   npm install
   ```
2. **Configure environment**:
   Create `.env` based on `.env.example`:
   ```env
   PORT=3000
   MONGODB_URI=mongodb+srv://<user>:<password>@cluster0.42bbt.mongodb.net/cake_shop?retryWrites=true&w=majority
   JWT_SECRET=super_secret_jwt_key_sweet_delights_2026
   PUBLIC_APP_URL=http://localhost:3000
   ```
3. **Seed database**:
   ```bash
   npm run seed
   ```
4. **Start development server**:
   ```bash
   npm run dev
   ```
   *(Uses `nodemon` for instant hot reloading on every saved file).*

---

## 🔑 Test Credentials

| Role | Email | Password |
|:---|:---|:---|
| Customer | `customer@test.com` | `test123` |
| Admin (Bakery / KDS) | `admin@cakeshop.com` | `admin123` |
| Delivery Partner (Rider) | `rider@cakeshop.com` | `rider123` |
