package model.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.MenuItem;
import model.Order;

public class OrderDAO {

    public int insertOrder(Order order) {
        String sql = "INSERT INTO orders (customer_id, total_amount, status, order_date, order_time, created_at) "
                   + "VALUES (?, ?, ?, CURDATE(), CURTIME(), NOW())";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, order.getCustomerId());
            ps.setDouble(2, order.getTotalAmount());
            ps.setString(3, order.getStatus() == null || order.getStatus().isBlank() ? "pending" : order.getStatus());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        int orderId = keys.getInt(1);
                        order.setOrderId(orderId);
                        return orderId;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public int createOrderWithItems(Order order, Map<Integer, Integer> cart, Map<Integer, MenuItem> itemsById) {
        String orderSql = "INSERT INTO orders (customer_id, total_amount, status, order_date, order_time, created_at) "
                        + "VALUES (?, ?, ?, CURDATE(), CURTIME(), NOW())";
        String itemSql = "INSERT INTO order_items (order_id, menu_id, quantity, unit_price, subtotal) "
                       + "VALUES (?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);

            int orderId;
            try (PreparedStatement orderPs = con.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS)) {
                orderPs.setInt(1, order.getCustomerId());
                orderPs.setDouble(2, order.getTotalAmount());
                orderPs.setString(3, order.getStatus() == null || order.getStatus().isBlank()
                        ? "pending" : order.getStatus());
                orderPs.executeUpdate();

                try (ResultSet keys = orderPs.getGeneratedKeys()) {
                    if (!keys.next()) {
                        con.rollback();
                        return -1;
                    }
                    orderId = keys.getInt(1);
                    order.setOrderId(orderId);
                }
            }

            try (PreparedStatement itemPs = con.prepareStatement(itemSql)) {
                for (Map.Entry<Integer, Integer> entry : cart.entrySet()) {
                    MenuItem item = itemsById.get(entry.getKey());
                    if (item == null) {
                        con.rollback();
                        return -1;
                    }

                    int quantity = entry.getValue();
                    double unitPrice = item.getPrice();
                    double subtotal = quantity * unitPrice;

                    itemPs.setInt(1, orderId);
                    itemPs.setInt(2, item.getMenuId());
                    itemPs.setInt(3, quantity);
                    itemPs.setDouble(4, unitPrice);
                    itemPs.setDouble(5, subtotal);
                    itemPs.addBatch();
                }
                itemPs.executeBatch();
            }

            con.commit();
            return orderId;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public List<Order> getOrdersByUser(int customerId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM orders WHERE customer_id = ? ORDER BY created_at DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setOrderId(rs.getInt("order_id"));
                    order.setCustomerId(rs.getInt("customer_id"));
                    order.setTotalAmount(rs.getDouble("total_amount"));
                    order.setStatus(rs.getString("status"));
                    order.setCreatedAt(rs.getString("created_at"));
                    list.add(order);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
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

    public boolean updateOrderStatus(int orderId, String status) {
        String sql = "UPDATE orders SET status = ? WHERE order_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[OrderDAO.updateOrderStatus] Error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public int countOrdersToday() {
        return getCount("SELECT COUNT(*) FROM orders WHERE order_date = CURDATE()");
    }

    public int countOrdersByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM orders WHERE status = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAO.countOrdersByStatus] Error: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    public List<Map<String, Object>> getRecentOrderSummaries(int limit) {
        List<Map<String, Object>> orders = new ArrayList<>();
        String sql = "SELECT o.order_id, u.name AS customer_name, o.total_amount, o.status, "
                   + "o.created_at, q.queue_number, "
                   + "CASE "
                   + "  WHEN p.payment_id IS NULL THEN 'Awaiting payment' "
                   + "  WHEN p.payment_method = 'mobile_money' THEN 'Paid via M-Pesa' "
                   + "  ELSE 'Paid in cash' "
                   + "END AS payment_state "
                   + "FROM orders o "
                   + "JOIN users u ON u.user_id = o.customer_id "
                   + "LEFT JOIN queue q ON q.order_id = o.order_id "
                   + "LEFT JOIN payments p ON p.order_id = o.order_id "
                   + "ORDER BY o.created_at DESC "
                   + "LIMIT " + sanitizeLimit(limit);

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("orderId", rs.getInt("order_id"));
                row.put("customerName", rs.getString("customer_name"));
                row.put("totalAmount", rs.getDouble("total_amount"));
                row.put("status", rs.getString("status"));
                row.put("createdAt", rs.getString("created_at"));
                row.put("queueNumber", rs.getInt("queue_number"));
                row.put("paymentState", rs.getString("payment_state"));
                orders.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAO.getRecentOrderSummaries] Error: " + e.getMessage());
            e.printStackTrace();
        }
        return orders;
    }

    private int getCount(String sql) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAO.getCount] Error: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    private int sanitizeLimit(int limit) {
        return Math.max(1, Math.min(limit, 20));
    }
}
