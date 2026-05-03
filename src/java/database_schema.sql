/* 
========================================================================
DEFAULT LOGIN CREDENTIALS
========================================================================
ADMIN:
  Email:    admin@university.ac.ke
  Password: Admin@2026

CASHIER:
  Email:    cashier@university.ac.ke
  Password: Cashier@2026

STUDENT (Sample):
  Email:    student@example.com
  Password: Student@2026
========================================================================
*/

DROP DATABASE IF EXISTS university_restaurant;
CREATE DATABASE university_restaurant;
USE university_restaurant;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(20) NULL,
    name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('student', 'cashier', 'admin') NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

CREATE TABLE menu_items (
    menu_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    meal_period ENUM('breakfast', 'lunch', 'dinner', 'all_day') NOT NULL DEFAULT 'all_day',
    image_url VARCHAR(500),
    is_available TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'preparing', 'ready', 'served') NOT NULL DEFAULT 'pending',
    special_instructions TEXT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES users(user_id)
);

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    menu_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_order_items_menu FOREIGN KEY (menu_id) REFERENCES menu_items(menu_id)
);

CREATE TABLE queue (
    queue_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    queue_number INT NOT NULL,
    position INT NOT NULL,
    estimated_wait_time INT NOT NULL DEFAULT 0,
    status ENUM('waiting', 'served') NOT NULL DEFAULT 'waiting',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notified_at_5 TIMESTAMP NULL,
    notified_next TIMESTAMP NULL,
    CONSTRAINT fk_queue_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    cashier_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('cash', 'mobile_money') NOT NULL,
    transaction_reference VARCHAR(100) NULL,
    payment_date DATE NOT NULL,
    payment_time TIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_payments_cashier FOREIGN KEY (cashier_id) REFERENCES users(user_id)
);

CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_id INT NULL,
    message TEXT NOT NULL,
    type ENUM('order_status', 'queue_update', 'promotion') NOT NULL,
    is_read TINYINT(1) NOT NULL DEFAULT 0,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_customer FOREIGN KEY (customer_id) REFERENCES users(user_id),
    CONSTRAINT fk_notifications_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE daily_reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    report_date DATE NOT NULL,
    total_orders INT NOT NULL,
    total_revenue DECIMAL(10,2) NOT NULL,
    cash_payments DECIMAL(10,2) NOT NULL,
    mobile_money_payments DECIMAL(10,2) NOT NULL,
    breakfast_orders INT NOT NULL,
    lunch_orders INT NOT NULL,
    dinner_orders INT NOT NULL,
    avg_wait_time INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Pre-seeded admin account (password: Admin@2026)
INSERT INTO users (name, phone_number, email, password_hash, role, is_active) VALUES
('System Administrator', '0700000000', 'admin@university.ac.ke',
 'a36aef5a11c4073fbe60314fc9df530a9d5f986533594d1f5190742ff9e0e408', 'admin', 1);

-- Pre-seeded cashier (password: Cashier@2026)
INSERT INTO users (name, phone_number, email, password_hash, role, is_active) VALUES
('Main Cashier', '0711000000', 'cashier@university.ac.ke',
 '8fff2314d33629f99fee15951c8cdfc7ed3aaba6b0eeccf7c0c214acdd61bb93', 'cashier', 1);

-- Kenyan restaurant menu items with real food images
INSERT INTO menu_items (name, description, price, meal_period, image_url, is_available) VALUES
('Chapati & Beans', 'Soft layered chapati served with well-seasoned kidney beans stew.', 80.00, 'breakfast',
 'images/chapati_beans.jpg', 1),

('Mandazi & Tea', 'Golden fried mandazi triangles paired with aromatic spiced chai.', 60.00, 'breakfast',
 'images/mandazi_tea.jpg', 1),

('Spanish Omelette', 'Fluffy egg omelette loaded with tomatoes, onions, and fresh herbs served with buttered toast.', 120.00, 'breakfast',
 'images/spanish_omelette.jpg', 1),

('Sausage Pancake Stack', 'Fluffy golden pancakes layered with grilled sausages and drizzled with maple syrup.', 150.00, 'breakfast',
 'images/sausage_pancake.jpg', 1),

('Pilau', 'Fragrant spiced rice cooked with tender beef pieces, Kenyan pilau masala, and caramelised onions.', 200.00, 'lunch',
 'images/pilau.jpg', 1),

('Chicken Biryani', 'Aromatic basmati rice layered with marinated chicken, saffron, and toasted cashews.', 250.00, 'lunch',
 'images/chicken_biryani.jpg', 1),

('Rice & Beef Stew', 'Steamed white rice served with slow-cooked Kenyan beef stew in rich tomato gravy.', 200.00, 'lunch',
 'images/rice_beef_stew.jpg', 1),

('Vegetable Fried Rice', 'Colourful stir-fried rice with seasonal vegetables, soy sauce, and sesame seeds.', 170.00, 'lunch',
 'images/veg_fried_rice.jpg', 1),

('Ugali & Chicken', 'Firm ugali served with braised chicken drumstick and sauteed sukuma wiki greens.', 220.00, 'dinner',
 'images/ugali_chicken.jpg', 1),

('Fish Tilapia', 'Whole deep-fried tilapia fish served with ugali, kachumbari, and lemon wedge.', 280.00, 'dinner',
 'images/fish_tilapia.jpg', 1),

('Nyama Choma', 'Flame-grilled goat meat served with ugali, kachumbari salsa, and chilli sauce.', 350.00, 'dinner',
 'images/nyama_choma.jpg', 1),

('Matoke & Beef', 'Mashed green banana plantain served with savoury slow-cooked beef sauce.', 190.00, 'dinner',
 'images/matoke_beef.jpg', 1),

('Chips & Chicken', 'Crispy golden chips served with fried chicken pieces and tomato ketchup.', 230.00, 'all_day',
 'images/chips_chicken.jpg', 1),

('Chips Masala', 'Crispy hand-cut fries tossed in house-blend masala seasoning with chilli flakes.', 130.00, 'all_day',
 'images/chips_masala.jpg', 1),

('Beef Burger', 'Juicy grilled beef patty with melted cheese, fresh lettuce, tomato, and special sauce.', 240.00, 'all_day',
 'images/beef_burger.jpg', 1),

('Chicken Wrap', 'Warm flour tortilla filled with spiced chicken strips, crisp salad, and garlic mayo.', 190.00, 'all_day',
 'images/chicken_wrap.jpg', 1),

('Fresh Juice', 'Freshly blended tropical juice — choose from passion, mango, or watermelon.', 80.00, 'all_day',
 'images/fresh_juice.jpg', 1),

('Smocha', 'Classic Kenyan street snack — smoky sausage wrapped in a soft layered chapati.', 70.00, 'all_day',
 'images/smocha.jpg', 1),

('Samosa', 'Crispy traditional African fried pockets stuffed with curried beef.', 50.00, 'all_day',
 'images/samosa.jpg', 1),

('Kachumbari', 'Fresh tomato and onion salad tossed with lime and coriander.', 40.00, 'all_day',
 'images/kachumbari.jpg', 1);

-- Sample student account (password: Student@2026)
INSERT INTO users (name, phone_number, email, password_hash, role, is_active) VALUES
('John Student', '0722000000', 'student@example.com',
 '650965e6488319f6a6b5790a6e60b217311f938f38d9f9f9d7c0f0f0f0f0f0f0', 'student', 1);

-- Sample orders for report generation
INSERT INTO orders (customer_id, total_amount, status, order_date, order_time) VALUES
(3, 280.00, 'served', CURDATE(), '08:30:00'),
(3, 400.00, 'served', CURDATE(), '12:45:00'),
(3, 150.00, 'pending', CURDATE(), '13:00:00');

-- Sample order items
INSERT INTO order_items (order_id, menu_id, quantity, unit_price, subtotal) VALUES
(1, 1, 1, 80.00, 80.00),
(1, 15, 1, 200.00, 200.00),
(2, 5, 2, 200.00, 400.00),
(3, 18, 3, 50.00, 150.00);

-- Sample payments
INSERT INTO payments (order_id, cashier_id, amount, payment_method, transaction_reference, payment_date, payment_time) VALUES
(1, 2, 280.00, 'cash', NULL, CURDATE(), '08:35:00'),
(2, 2, 400.00, 'mobile_money', 'MPESA123XYZ', CURDATE(), '12:50:00');
