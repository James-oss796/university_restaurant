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

CREATE TABLE menu_items (
    menu_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    meal_period ENUM('breakfast', 'lunch', 'dinner', 'all_day') NOT NULL DEFAULT 'all_day',
    image_url VARCHAR(255),
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

INSERT INTO menu_items (name, description, price, meal_period, image_url, is_available) VALUES
('Chapati Beans', 'Soft chapati served with well-seasoned beans.', 80.00, 'breakfast', '', 1),
('Mandazi and Tea', 'Fresh mandazi served with hot spiced tea.', 60.00, 'breakfast', '', 1),
('Spanish Omelette', 'Fluffy omelette with herbs and toasted bread.', 120.00, 'breakfast', '', 1),
('Sausage Pancake Stack', 'Golden pancakes served with sausage and syrup.', 150.00, 'breakfast', '', 1),
('Pilau Beef', 'Fragrant pilau rice with beef stew.', 180.00, 'lunch', '', 1),
('Chicken Biryani', 'Well-spiced biryani rice with tender chicken pieces.', 250.00, 'lunch', '', 1),
('Vegetable Fried Rice', 'Colourful fried rice with seasonal vegetables.', 170.00, 'lunch', '', 1),
('Beef Stew and Rice', 'Steamed rice served with rich beef stew.', 200.00, 'lunch', '', 1),
('Ugali Fish', 'Fresh fish served with ugali and greens.', 220.00, 'dinner', '', 1),
('Ugali Chicken', 'Soft ugali with braised chicken and sukuma wiki.', 210.00, 'dinner', '', 1),
('Matoke Beef', 'Mashed matoke served with savoury beef sauce.', 190.00, 'dinner', '', 1),
('Fish Fillet Combo', 'Crispy fish fillet with potato wedges and salad.', 260.00, 'dinner', '', 1),
('Chips Masala', 'Crispy fries tossed in house masala seasoning.', 130.00, 'all_day', '', 1),
('Beef Burger', 'Grilled beef burger with cheese and fresh vegetables.', 240.00, 'all_day', '', 1),
('Chicken Wrap', 'Warm tortilla packed with chicken and fresh salad.', 190.00, 'all_day', '', 1),
('Fresh Juice', 'Refreshing passion, mango, or tropical blend.', 60.00, 'all_day', '', 1);
