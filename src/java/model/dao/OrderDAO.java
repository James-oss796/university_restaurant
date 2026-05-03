package model.dao;

import model.Order;
import java.sql.*;
import java.util.*;

public class OrderDAO {
    
    // 1. insertOrder - Returns the generated order ID
    public int insertOrder(Order o) {
        String sql = "INSERT INTO orders (customer_id, total_amount, status, order_date, order_time) VALUES (?, ?, ?, CURDATE(), CURTIME())";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, o.getCustomerId());
            ps.setDouble(2, o.getTotalAmount());
            ps.setString(3, "pending"); // Must be lowercase to match ENUM definition

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        int newId = keys.getInt(1);
                        o.setOrderId(newId);  // inject back into the Order object
                        return newId;          // return the generated ID
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1; // Return -1 if insertion failed
    }

    public boolean insertOrderItem(int orderId, int menuId, int quantity, double unitPrice, double subtotal) {
        String sql = "INSERT INTO order_items (order_id, menu_id, quantity, unit_price, subtotal) VALUES (?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, menuId);
            ps.setInt(3, quantity);
            ps.setDouble(4, unitPrice);
            ps.setDouble(5, subtotal);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 2. getOrdersByUser
    public List<Order> getOrdersByUser(int customerId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM orders WHERE customer_id = ? ORDER BY created_at DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = new Order();
                    o.setOrderId(rs.getInt("order_id"));
                    o.setCustomerId(rs.getInt("customer_id"));
                    o.setTotalAmount(rs.getDouble("total_amount"));
                    o.setStatus(rs.getString("status"));
                    o.setCreatedAt(rs.getString("created_at"));
                    list.add(o);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. getOrderById
    public Order getOrderById(int orderId) {
        String sql = "SELECT * FROM orders WHERE order_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order o = new Order();
                    o.setOrderId(rs.getInt("order_id"));
                    o.setCustomerId(rs.getInt("customer_id"));
                    o.setTotalAmount(rs.getDouble("total_amount"));
                    o.setStatus(rs.getString("status"));
                    o.setCreatedAt(rs.getString("created_at"));
                    return o;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 4. updateOrderStatus
    public boolean updateOrderStatus(int orderId, String status) {
        String sql = "UPDATE orders SET status = ? WHERE order_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setInt(2, orderId);
            
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 5. getCustomerIdByOrder
    public int getCustomerIdByOrder(int orderId) {
        String sql = "SELECT customer_id FROM orders WHERE order_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
 
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("customer_id");
                }
            }
 
        } catch (SQLException e) {
            System.err.println("[OrderDAO.getCustomerIdByOrder] Error: " + e.getMessage());
            e.printStackTrace();
        }
        return -1;
    }

    // 6. getPendingOrdersDetails (For Cashier Dashboard)
    public List<Order> getPendingOrdersDetails() {
        List<Order> list = new ArrayList<>();
        // Query joins orders, users, order_items, and menu_items to get a summary
        String sql = "SELECT o.order_id, o.customer_id, o.total_amount, o.status, o.created_at, " +
                     "u.name AS customer_name, " +
                     "GROUP_CONCAT(CONCAT(oi.quantity, 'x ', m.name) SEPARATOR ', ') AS items_desc " +
                     "FROM orders o " +
                     "JOIN users u ON o.customer_id = u.user_id " +
                     "LEFT JOIN order_items oi ON o.order_id = oi.order_id " +
                     "LEFT JOIN menu_items m ON oi.menu_id = m.menu_id " +
                     "WHERE o.status = 'pending' " +
                     "GROUP BY o.order_id, u.name " +
                     "ORDER BY o.created_at ASC";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Order o = new Order();
                o.setOrderId(rs.getInt("order_id"));
                o.setCustomerId(rs.getInt("customer_id"));
                o.setTotalAmount(rs.getDouble("total_amount"));
                o.setStatus(rs.getString("status"));
                o.setCreatedAt(rs.getString("created_at"));
                o.setCustomerName(rs.getString("customer_name"));
                o.setItemsDescription(rs.getString("items_desc"));
                list.add(o);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}