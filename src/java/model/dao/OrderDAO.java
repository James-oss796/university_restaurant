package model.dao;
import model.Order;
import java.sql.*;
import java.util.*;

public class OrderDAO {
    // 1. insertOrder
    public boolean insertOrder(Order o) {
        String sql = "INSERT INTO orders (customer_id, total_amount, status, created_at) VALUES (?, ?, ?, NOW())";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, o.getCustomerId());
            ps.setDouble(2, o.getTotalAmount());
            ps.setString(3, "PENDING"); // Initial status

            int rows = ps.executeUpdate();
            return rows > 0;
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
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order o = new Order();
                o.setOrderId(rs.getInt("order_id"));
                o.setTotalAmount(rs.getDouble("total_amount"));
                o.setStatus(rs.getString("status"));
                o.setCreatedAt(rs.getString("created_at"));
                list.add(o);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}

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
