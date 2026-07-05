-- Cake Online Shopping Android App
-- Database Schema (SQLite)
-- Version: 1.0

-- ============================================================
-- TABLE: users
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'CUSTOMER',
    created_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- ============================================================
-- TABLE: cakes
-- ============================================================
CREATE TABLE IF NOT EXISTS cakes (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL,
    base_price REAL NOT NULL,
    image_url TEXT,
    flavors TEXT NOT NULL,
    sizes TEXT NOT NULL,
    rating REAL NOT NULL DEFAULT 0.0,
    in_stock INTEGER NOT NULL DEFAULT 1
);

CREATE INDEX IF NOT EXISTS idx_cakes_category ON cakes(category);

-- ============================================================
-- TABLE: cart_items
-- ============================================================
CREATE TABLE IF NOT EXISTS cart_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    user_id INTEGER NOT NULL,
    cake_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    selected_size TEXT NOT NULL,
    selected_flavor TEXT NOT NULL,
    custom_message TEXT,
    unit_price REAL NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (cake_id) REFERENCES cakes(id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE: orders
-- ============================================================
CREATE TABLE IF NOT EXISTS orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    order_number TEXT NOT NULL UNIQUE,
    user_id INTEGER NOT NULL,
    total_amount REAL NOT NULL,
    status TEXT NOT NULL DEFAULT 'PENDING',
    delivery_address TEXT NOT NULL,
    delivery_date INTEGER NOT NULL,
    payment_method TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);

-- ============================================================
-- TABLE: order_items
-- ============================================================
CREATE TABLE IF NOT EXISTS order_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    order_id INTEGER NOT NULL,
    cake_id INTEGER NOT NULL,
    cake_name TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    size TEXT NOT NULL,
    flavor TEXT NOT NULL,
    custom_message TEXT,
    price REAL NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (cake_id) REFERENCES cakes(id)
);

-- ============================================================
-- SEED DATA: Default admin user
-- Password: admin123 (SHA-256 hash - replace in production)
-- ============================================================
INSERT OR IGNORE INTO users (id, name, email, phone, password_hash, role, created_at)
VALUES (
    1,
    'Admin User',
    'admin@cakeshop.com',
    '+1234567890',
    '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9',
    'ADMIN',
    strftime('%s', 'now') * 1000
);

-- Demo customer: test123
INSERT OR IGNORE INTO users (id, name, email, phone, password_hash, role, created_at)
VALUES (
    2,
    'Demo Customer',
    'customer@test.com',
    '+1987654321',
    'ecd71870d1963316a97e3ac3408c9835ad8cf0f3c1bc703527c30265534f75ae',
    'CUSTOMER',
    strftime('%s', 'now') * 1000
);

-- ============================================================
-- SEED DATA: Sample cakes
-- ============================================================
INSERT OR IGNORE INTO cakes (id, name, description, category, base_price, image_url, flavors, sizes, rating, in_stock)
VALUES
(1, 'Chocolate Fudge Birthday Cake',
 'Rich chocolate layers with fudge frosting. Perfect for birthdays.',
 'BIRTHDAY', 25.00, 'cake_chocolate_birthday',
 '["Chocolate","Vanilla"]', '["500g","1kg","2kg"]', 4.5, 1),

(2, 'Vanilla Dream Wedding Cake',
 'Elegant three-tier vanilla cake with buttercream roses.',
 'WEDDING', 120.00, 'cake_wedding_vanilla',
 '["Vanilla","Strawberry"]', '["2kg","3kg","5kg"]', 4.8, 1),

(3, 'Red Velvet Cupcake Box',
 'Box of 12 premium red velvet cupcakes with cream cheese frosting.',
 'CUPCAKE', 15.00, 'cake_red_velvet_cupcake',
 '["Red Velvet"]', '["6 pcs","12 pcs","24 pcs"]', 4.6, 1),

(4, 'Custom Photo Cake',
 'Upload your photo and we print it on a delicious buttercream cake.',
 'CUSTOM', 45.00, 'cake_custom_photo',
 '["Vanilla","Chocolate","Red Velvet"]', '["1kg","2kg"]', 4.7, 1),

(5, 'Christmas Fruit Cake',
 'Traditional spiced fruit cake with nuts and dried fruits. Seasonal special.',
 'SEASONAL', 35.00, 'cake_christmas_fruit',
 '["Fruit","Spice"]', '["500g","1kg"]', 4.4, 1),

(6, 'Strawberry Shortcake',
 'Light sponge with fresh strawberries and whipped cream.',
 'BIRTHDAY', 28.00, 'cake_strawberry',
 '["Strawberry","Vanilla"]', '["500g","1kg"]', 4.5, 1),

(7, 'Lemon Drizzle Cake',
 'Moist lemon cake with tangy drizzle icing.',
 'CUPCAKE', 18.00, 'cake_lemon',
 '["Lemon"]', '["500g","1kg"]', 4.3, 1),

(8, 'Black Forest Gateau',
 'Classic German cake with cherries, chocolate, and whipped cream.',
 'BIRTHDAY', 32.00, 'cake_black_forest',
 '["Chocolate","Cherry"]', '["1kg","2kg"]', 4.9, 1);
