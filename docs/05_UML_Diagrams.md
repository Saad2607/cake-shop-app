# UML Diagrams

## Cake Online Shopping Android App

**Document ID:** UML-CAKE-001  
**Version:** 1.0  
**Date:** June 2026

> Use [Mermaid Live Editor](https://mermaid.live) or Draw.io to render/export these diagrams for your report.

---

## 1. Use Case Diagram

```mermaid
flowchart TB
    subgraph System["Cake Online Shopping App"]
        UC1[Register]
        UC2[Login / Logout]
        UC3[Browse Catalog]
        UC4[Search & Filter]
        UC5[View Cake Details]
        UC6[Add to Cart]
        UC7[Manage Cart]
        UC8[Checkout & Place Order]
        UC9[View Order History]
        UC10[Track Order Status]
        UC11[Manage Profile]
        UC12[Manage Products]
        UC13[Manage Orders]
    end

    Customer((Customer))
    Guest((Guest))
    Admin((Administrator))

    Guest --> UC3
    Guest --> UC4
    Guest --> UC5

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
    Customer --> UC11

    Admin --> UC2
    Admin --> UC12
    Admin --> UC13
```

---

## 2. Use Case Descriptions

### UC-01: Register Account

| Field | Description |
|-------|-------------|
| **Actor** | Customer |
| **Precondition** | App installed, user not logged in |
| **Main Flow** | 1. User opens Register screen<br>2. Enters name, email, phone, password<br>3. System validates input<br>4. System creates account<br>5. User redirected to Login or Home |
| **Alternate Flow** | 3a. Email already exists → show error<br>3b. Invalid email format → show validation error |
| **Postcondition** | New user record in database |

### UC-08: Place Order

| Field | Description |
|-------|-------------|
| **Actor** | Customer |
| **Precondition** | User logged in, cart not empty |
| **Main Flow** | 1. User opens Cart and taps Checkout<br>2. Enters delivery address and date<br>3. Selects payment method<br>4. Reviews order summary<br>5. Confirms order<br>6. System generates order ID and clears cart<br>7. Confirmation screen displayed |
| **Postcondition** | Order saved with PENDING status |

---

## 3. Class Diagram

```mermaid
classDiagram
    class User {
        +Long id
        +String name
        +String email
        +String phone
        +String passwordHash
        +UserRole role
        +Long createdAt
    }

    class Cake {
        +Long id
        +String name
        +String description
        +CakeCategory category
        +Double basePrice
        +String imageUrl
        +List~String~ flavors
        +List~String~ sizes
        +Float rating
        +Boolean inStock
    }

    class CartItem {
        +Long id
        +Long userId
        +Long cakeId
        +Int quantity
        +String selectedSize
        +String selectedFlavor
        +String customMessage
        +Double unitPrice
    }

    class Order {
        +Long id
        +String orderNumber
        +Long userId
        +Double totalAmount
        +OrderStatus status
        +String deliveryAddress
        +Long deliveryDate
        +String paymentMethod
        +Long createdAt
    }

    class OrderItem {
        +Long id
        +Long orderId
        +Long cakeId
        +String cakeName
        +Int quantity
        +String size
        +String flavor
        +String customMessage
        +Double price
    }

    class UserRepository {
        +register(user) Result
        +login(email, password) Result~User~
        +getUserById(id) User
    }

    class CakeRepository {
        +getAllCakes() List~Cake~
        +getCakeById(id) Cake
        +search(query) List~Cake~
        +filter(category, minPrice, maxPrice) List~Cake~
    }

    class CartRepository {
        +getCartItems(userId) List~CartItem~
        +addItem(item) Unit
        +updateQuantity(id, qty) Unit
        +removeItem(id) Unit
        +clearCart(userId) Unit
    }

    class OrderRepository {
        +placeOrder(order, items) Order
        +getOrdersByUser(userId) List~Order~
        +updateStatus(orderId, status) Unit
    }

    class CatalogViewModel {
        -cakeRepository: CakeRepository
        +cakes: LiveData~List~Cake~~
        +loadCakes()
        +search(query)
    }

    class CartViewModel {
        -cartRepository: CartRepository
        +cartItems: LiveData~List~CartItem~~
        +total: LiveData~Double~
        +addToCart(item)
        +removeFromCart(id)
    }

    User "1" --> "*" CartItem : owns
    User "1" --> "*" Order : places
    Cake "1" --> "*" CartItem : in
    Order "1" --> "*" OrderItem : contains
    Cake "1" --> "*" OrderItem : references

    UserRepository ..> User
    CakeRepository ..> Cake
    CartRepository ..> CartItem
    OrderRepository ..> Order
    OrderRepository ..> OrderItem

    CatalogViewModel --> CakeRepository
    CartViewModel --> CartRepository
```

---

## 4. Sequence Diagram — Login

```mermaid
sequenceDiagram
    actor User
    participant LoginActivity
    participant AuthViewModel
    participant UserRepository
    participant UserDao
    participant Database

    User->>LoginActivity: Enter email & password
    User->>LoginActivity: Tap Login
    LoginActivity->>AuthViewModel: login(email, password)
    AuthViewModel->>UserRepository: authenticate(email, password)
    UserRepository->>UserDao: getUserByEmail(email)
    UserDao->>Database: SELECT query
    Database-->>UserDao: User row
    UserDao-->>UserRepository: User entity
    UserRepository->>UserRepository: verifyPassword(hash)
    alt Valid credentials
        UserRepository-->>AuthViewModel: Success(User)
        AuthViewModel-->>LoginActivity: Navigate to Main
        LoginActivity-->>User: Show Home screen
    else Invalid credentials
        UserRepository-->>AuthViewModel: Error
        AuthViewModel-->>LoginActivity: Show error message
        LoginActivity-->>User: "Invalid email or password"
    end
```

---

## 5. Sequence Diagram — Place Order

```mermaid
sequenceDiagram
    actor User
    participant CheckoutActivity
    participant OrderViewModel
    participant OrderRepository
    participant CartRepository
    participant OrderDao
    participant CartDao

    User->>CheckoutActivity: Fill address, date, payment
    User->>CheckoutActivity: Tap Place Order
    CheckoutActivity->>OrderViewModel: placeOrder(details)
    OrderViewModel->>CartRepository: getCartItems(userId)
    CartRepository-->>OrderViewModel: List of CartItems
    OrderViewModel->>OrderViewModel: calculateTotal()
    OrderViewModel->>OrderRepository: createOrder(order, items)
    OrderRepository->>OrderDao: insertOrder(order)
    OrderRepository->>OrderDao: insertOrderItems(items)
    OrderRepository->>CartRepository: clearCart(userId)
    CartRepository->>CartDao: deleteAllForUser(userId)
    OrderRepository-->>OrderViewModel: Order with orderNumber
    OrderViewModel-->>CheckoutActivity: Success
    CheckoutActivity-->>User: Order Confirmation screen
```

---

## 6. Activity Diagram — Shopping Flow

```mermaid
flowchart TD
    A([Start App]) --> B{Logged in?}
    B -->|No| C[Login / Register]
    B -->|Yes| D[Home - Browse Catalog]
    C --> D
    D --> E[Select Category / Search]
    E --> F[View Cake Details]
    F --> G{In Stock?}
    G -->|No| D
    G -->|Yes| H[Select Size, Flavor, Qty]
    H --> I[Add to Cart]
    I --> J{Continue Shopping?}
    J -->|Yes| D
    J -->|No| K[Open Cart]
    K --> L{Cart Empty?}
    L -->|Yes| D
    L -->|No| M[Checkout]
    M --> N[Enter Delivery Info]
    N --> O[Review Order]
    O --> P{Confirm?}
    P -->|No| K
    P -->|Yes| Q[Place Order]
    Q --> R[Order Confirmation]
    R --> S([End])
```

---

## 7. Activity Diagram — Order Status (Admin)

```mermaid
flowchart LR
    PENDING --> CONFIRMED
    CONFIRMED --> BAKING
    BAKING --> READY
    READY --> DELIVERED
    PENDING --> CANCELLED
    CONFIRMED --> CANCELLED
```

---

## 8. Component Diagram

```mermaid
flowchart TB
    subgraph Presentation
        Activities[Activities]
        Fragments[Fragments]
        Adapters[RecyclerView Adapters]
    end

    subgraph ViewModel
        VMs[ViewModels]
    end

    subgraph Domain
        Repos[Repositories]
        Models[Entity Models]
    end

    subgraph Data
        Room[Room Database]
        Prefs[SharedPreferences]
        API[Retrofit API - Optional]
    end

    Activities --> VMs
    Fragments --> VMs
    VMs --> Repos
    Repos --> Room
    Repos --> Prefs
    Repos --> API
    Room --> Models
```

---

## 9. Deployment Diagram

```mermaid
flowchart TB
    subgraph Client["Android Device"]
        APK[Cake Shop APK]
        SQLite[(SQLite DB)]
        APK --> SQLite
    end

    subgraph Optional["Optional Cloud"]
        Server[REST API Server]
        CloudDB[(Cloud Database)]
        Server --> CloudDB
    end

    APK -.->|HTTPS| Server
```

---

## 10. State Diagram — Order Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Pending: Order placed
    Pending --> Confirmed: Admin confirms
    Pending --> Cancelled: User/Admin cancels
    Confirmed --> Baking: Production starts
    Confirmed --> Cancelled: Admin cancels
    Baking --> Ready: Cake finished
    Ready --> Delivered: Delivered to customer
    Delivered --> [*]
    Cancelled --> [*]
```

---

*Export diagrams as PNG/SVG for inclusion in Project Report and presentation slides.*
