// Member E (Reports & Admin Dashboard) should implement this file

package model.dao;
import model.DailyReport;
import java.sql.*;
import java.util.*;

public class DailyReportDAO {
    public List<DailyReport> getAllReports() {
        List<DailyReport> reports = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery("SELECT * FROM daily_reports ORDER BY report_date DESC")) {

            while (rs.next()) {
                DailyReport r = new DailyReport();
                r.setReportId(rs.getInt("report_id"));
                r.setReportDate(rs.getString("report_date"));
                r.setTotalOrders(rs.getInt("total_orders"));
                r.setTotalRevenue(rs.getDouble("total_revenue"));
                r.setCashPayments(rs.getDouble("cash_payments"));
                r.setMobileMoneyPayments(rs.getDouble("mobile_money_payments"));
                r.setBreakfastOrders(rs.getInt("breakfast_orders"));
                r.setLunchOrders(rs.getInt("lunch_orders"));
                r.setDinnerOrders(rs.getInt("dinner_orders"));
                r.setAvgWaitTime(rs.getInt("avg_wait_time"));
                reports.add(r);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reports;
    }

    // 1. Sales Trends
    public Map<String, Double> getSalesTrends() {
        Map<String, Double> trends = new LinkedHashMap<>();
        String sql = "SELECT order_date, SUM(total_amount) as daily_revenue FROM orders WHERE status != 'pending' GROUP BY order_date ORDER BY order_date DESC LIMIT 7";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                trends.put(rs.getString("order_date"), rs.getDouble("daily_revenue"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return trends;
    }

    // 2. Order Status Breakdown
    public Map<String, Integer> getOrderStatusBreakdown() {
        Map<String, Integer> breakdown = new LinkedHashMap<>();
        String sql = "SELECT status, COUNT(*) as count FROM orders GROUP BY status";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                breakdown.put(rs.getString("status"), rs.getInt("count"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return breakdown;
    }

    // 3. Revenue by Payment Method
    public Map<String, Double> getRevenueByMethod() {
        Map<String, Double> revenue = new LinkedHashMap<>();
        String sql = "SELECT payment_method, SUM(amount) as total FROM payments GROUP BY payment_method";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                revenue.put(rs.getString("payment_method"), rs.getDouble("total"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return revenue;
    }

    // 4. Top Users (User Activity)
    public List<Map<String, Object>> getTopUsers() {
        List<Map<String, Object>> users = new ArrayList<>();
        String sql = "SELECT u.name, COUNT(o.order_id) as order_count, SUM(o.total_amount) as total_spent FROM users u JOIN orders o ON u.user_id = o.customer_id GROUP BY u.user_id ORDER BY order_count DESC LIMIT 5";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("name", rs.getString("name"));
                map.put("order_count", rs.getInt("order_count"));
                map.put("total_spent", rs.getDouble("total_spent"));
                users.add(map);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return users;
    }

    // 5. Menu Performance (Inventory)
    public List<Map<String, Object>> getMenuPerformance() {
        List<Map<String, Object>> items = new ArrayList<>();
        String sql = "SELECT m.name, SUM(oi.quantity) as qty_sold, SUM(oi.subtotal) as revenue FROM menu_items m JOIN order_items oi ON m.menu_id = oi.menu_id GROUP BY m.menu_id ORDER BY qty_sold DESC LIMIT 10";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("name", rs.getString("name"));
                map.put("qty_sold", rs.getInt("qty_sold"));
                map.put("revenue", rs.getDouble("revenue"));
                items.add(map);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return items;
    }
}
