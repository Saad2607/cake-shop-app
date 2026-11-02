# UML Diagrams

## Sweet Delights — Cake Online Shopping App

**Document ID:** UML-CAKE-001  
**Version:** 2.0  
**Date:** June 2026

> Open `.md` files in VS Code with Mermaid preview, or paste diagrams in [mermaid.live](https://mermaid.live) for report/PPT images.

---

## 1. Use Case Diagram

```mermaid
flowchart TB
    subgraph System["Sweet Delights System"]
        UC1[Register]
        UC2[Login / Logout]
        UC3[Browse Catalog]
        UC4[Search & Filter]
        UC5[View Cake Detail]
        UC6[Add to Cart]
        UC7[Checkout]
        UC8[Track Orders]
        UC9[Cancel Order]
        UC10[Rate Order]
        UC11[Manage Menu]
        UC12[Update Order Status]
        UC13[Manage Offers]
        UC14[View Dashboard]
    end

    Guest((Guest))
    Customer((Customer))
    Admin((Admin))

    Guest --> UC3
    Guest --> UC4
    Guest --> UC5
    Guest --> UC2

    Customer --> UC1
    Customer --> UC2
    Customer --> UC3
    Customer --> UC4
    Customer --> UC5
    Customer --> UC6
    Customer --> UC7
    Customer --> UC8
    Customer --> UC9
    Customer --> UC10

    Admin --> UC2
    Admin --> UC11
    Admin --> UC12
    Admin --> UC13
    Admin --> UC14
```

---

## 2. Use Case Descriptions (Sample)

### UC-07 Checkout
| Field | Detail |
|-------|--------|
| Actor | Customer |
| Precondition | User logged in, cart not empty |
| Main flow | 1. Open checkout 2. Select address 3. Apply promo 4. Choose payment 5. Place order |
| Postcondition | Order created, cart cleared |
| Exception | Network error → show retry message |

### UC-12 Update Order Status
| Field | Detail |
|-------|--------|
| Actor | Admin |
| Precondition | Admin logged in |
| Main flow | 1. Open Orders tab 2. Select order 3. Change status 4. Save |
| Postcondition | Customer sees updated status |

---

## 3. Class Diagram (Logical)

```mermaid
classDiagram
    class User {
        +String id
        +String name
        +String email
        +String phone
        +String role
        +login()
        +updateProfile()
    }

    class Cake {
        +String id
        +String name
        +String category
        +double basePrice
        +List~String~ sizes
        +List~String~ flavors
        +boolean inStock
    }

    class CartItem {
        +String id
        +String userId
        +String cakeId
        +int quantity
        +String selectedSize
        +String selectedFlavor
        +double unitPrice
    }

    class Order {
        +String id
        +String orderNumber
        +String userId
        +double totalAmount
        +String status
        +List~OrderItem~ items
        +cancel()
        +submitReview()
    }

    class Promo {
        +String id
        +String title
        +String code
        +double discountPercent
        +boolean active
    }

    User "1" --> "*" CartItem
    User "1" --> "*" Order
    Cake "1" --> "*" CartItem
    Order "*" --> "*" OrderItem
```

---

## 4. Sequence Diagram — Place Order

```mermaid
sequenceDiagram
    actor Customer
    participant App as Flutter App
    participant API as Express API
    participant DB as MongoDB

    Customer->>App: Tap Place Order
    App->>API: POST /api/orders (JWT, address, promo)
    API->>DB: Load cart items
    API->>API: Validate prices & promo
    API->>DB: Create order document
    API->>DB: Delete cart items
    DB-->>API: OK
    API-->>App: Order JSON
    App-->>Customer: Show confirmation screen
```

---

## 5. Sequence Diagram — Admin Updates Status

```mermaid
sequenceDiagram
    actor Admin
    participant App as Flutter App
    participant API as Express API
    participant DB as MongoDB
    participant Customer as Customer App

    Admin->>App: Change status to BAKING
    App->>API: PATCH /admin/orders/:id/status
    API->>DB: Update order.status
    DB-->>API: Updated order
    API-->>App: Success
    Note over Customer: Polls orders / gets local notification
    Customer->>App: Open Orders tab
    App->>API: GET /api/orders
    API-->>App: Status = BAKING
```

---

## 6. Activity Diagram — Customer Order Flow

```mermaid
flowchart TD
    A[Open App] --> B{Logged in?}
    B -->|No| C[Browse as Guest]
    B -->|Yes| D[Browse Home]
    C --> D
    D --> E[Select Cake]
    E --> F[Choose Size & Flavour]
    F --> G{Login?}
    G -->|No| H[Login Screen]
    H --> G2{Success?}
    G2 -->|No| D
    G2 -->|Yes| I[Add to Cart]
    G -->|Yes| I
    I --> J[Open Cart]
    J --> K[Checkout]
    K --> L[Enter Address]
    L --> M[Select Payment]
    M --> N[Place Order]
    N --> O[Confirmation]
    O --> P[Track in Orders Tab]
```

---

## 7. Activity Diagram — Admin Order Handling

```mermaid
flowchart TD
    A[Admin Login] --> B[Open Orders Tab]
    B --> C[See PENDING orders]
    C --> D[Accept → CONFIRMED]
    D --> E[Start baking → BAKING]
    E --> F[Ready → READY]
    F --> G[Delivered → DELIVERED]
    C --> H[Or Cancel order]
```

---

## 8. Component Diagram

```mermaid
flowchart LR
    subgraph Client["Flutter App"]
        UI[Screens]
        PR[Providers]
        API_CLIENT[ApiService]
        UI --> PR --> API_CLIENT
    end

    subgraph Server["Node.js"]
        ROUTES[Routes]
        CTRL[Controllers]
        MW[Auth Middleware]
        SVC[Promo Service]
        ROUTES --> MW --> CTRL --> SVC
    end

    subgraph Data["MongoDB"]
        COL[(Collections)]
    end

    API_CLIENT <-->|REST/JSON| ROUTES
    CTRL <-->|Mongoose| COL
```

---

## 9. Deployment Diagram

```mermaid
flowchart TB
    Phone[Android Phone\nFlutter APK]
    Emulator[Android Emulator]
    API_SERVER[Node.js Server\nPort 3000]
    MONGO[(MongoDB Atlas)]

    Phone -->|WiFi / Internet| API_SERVER
    Emulator -->|10.0.2.2| API_SERVER
    API_SERVER --> MONGO
```

---

*Draw these diagrams in your report using Mermaid export or redraw in Draw.io for submission PDF.*
