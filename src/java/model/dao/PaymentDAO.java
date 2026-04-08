package model.dao;

import model.Payment;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * PaymentDAO — CRUD operations for the payments table.
 *
 * Methods:
 *  - insertPayment(Payment)             → save a new payment; returns generated payment_id or -1
 *  - getPaymentsByOrder(int orderId)    → list payments for one order
 *  - getAllPayments()                   → list all payments (cashier / admin view)
 *  - getPaymentsByDate(Date date)       → list payments for a specific date (reports)
 *  - isOrderPaid(int orderId)           → check if an order already has a payment
 *  - getOrderAmountDue(int orderId)     → retrieve the total_amount from orders for the orderId
 */
public class PaymentDAO {

    // 1. INSERT — save a new payment record

    /**
     * Persists a Payment to the database.
     *
     * Sets payment_date and payment_time automatically using CURDATE() / CURTIME().
     * The generated payment_id is injected back into the payment object.
     *
     * @param payment  A populated Payment object (orderId, cashierId, amount,
     *                 paymentMethod, transactionReference must be set).
     * @return  The generated payment_id (> 0) on success, or -1 on failure.
     */
    public int insertPayment(Payment payment) {
        String sql = "INSERT INTO payments "
                   + "(order_id, cashier_id, amount, payment_method, "
                   + " transaction_reference, payment_date, payment_time) "
                   + "VALUES (?, ?, ?, ?, ?, CURDATE(), CURTIME())";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, payment.getOrderId());
            ps.setInt(2, payment.getCashierId());
            ps.setDouble(3, payment.getAmount());
            ps.setString(4, payment.getPaymentMethod());

            // transaction_reference can be NULL for cash payments
            String ref = payment.getTransactionReference();
            if (ref == null || ref.trim().isEmpty()) {
                ps.setNull(5, java.sql.Types.VARCHAR);
            } else {
                ps.setString(5, ref.trim());
            }

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int generatedId = generatedKeys.getInt(1);
                        payment.setPaymentId(generatedId);
                        return generatedId;
                    }
                }
            }

        } catch (SQLException e) {
            System.err.println("[PaymentDAO.insertPayment] Error: " + e.getMessage());
            e.printStackTrace();
        }
        return -1;
    }

    // 2. READ — payments for a specific order

    /**
     * Returns all payments linked to a specific order.
     * Normally an order has one payment, but the schema allows multiple
     * (e.g. partial payment scenarios).
     *
     * @param orderId  The order to look up.
     * @return  List of Payment objects (may be empty, never null).
     */
    public List<Payment> getPaymentsByOrder(int orderId) {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT p.*, u.name AS cashier_name "
                   + "FROM payments p "
                   + "LEFT JOIN users u ON p.cashier_id = u.user_id "
                   + "WHERE p.order_id = ? "
                   + "ORDER BY p.payment_date DESC, p.payment_time DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    payments.add(mapRow(rs));
                }
            }

        } catch (SQLException e) {
            System.err.println("[PaymentDAO.getPaymentsByOrder] Error: " + e.getMessage());
            e.printStackTrace();
        }
        return payments;
    }

    // 3. READ — all payments (for cashier dashboard and admin reports)

    /**
     * Returns all payment records, newest first.
     * Joins the users table to include cashier name for display.
     *
     * @return  List of Payment objects (may be empty, never null).
     */
    public List<Payment> getAllPayments() {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT p.*, u.name AS cashier_name "
                   + "FROM payments p "
                   + "LEFT JOIN users u ON p.cashier_id = u.user_id "
                   + "ORDER BY p.payment_date DESC, p.payment_time DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                payments.add(mapRow(rs));
            }

        } catch (SQLException e) {
            System.err.println("[PaymentDAO.getAllPayments] Error: " + e.getMessage());
            e.printStackTrace();
        }
        return payments;
    }

    public List<Payment> getRecentPayments(int limit) {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT p.*, u.name AS cashier_name "
                   + "FROM payments p "
                   + "LEFT JOIN users u ON p.cashier_id = u.user_id "
                   + "ORDER BY p.payment_date DESC, p.payment_time DESC "
                   + "LIMIT " + sanitizeLimit(limit);

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                payments.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[PaymentDAO.getRecentPayments] Error: " + e.getMessage());
            e.printStackTrace();
        }
        return payments;
    }

    // 4. READ — payments for a specific date (used by reports)

    /**
     * Returns all payments recorded on a given date.
     * Intended to be used by the reports flow for aggregation.
     *
     * @param date  The date to filter on (java.sql.Date).
     * @return  List of Payment objects (may be empty, never null).
     */
    public List<Payment> getPaymentsByDate(Date date) {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT p.*, u.name AS cashier_name "
                   + "FROM payments p "
                   + "LEFT JOIN users u ON p.cashier_id = u.user_id "
                   + "WHERE p.payment_date = ? "
                   + "ORDER BY p.payment_time DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDate(1, date);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    payments.add(mapRow(rs));
                }
            }

        } catch (SQLException e) {
            System.err.println("[PaymentDAO.getPaymentsByDate] Error: " + e.getMessage());
            e.printStackTrace();
        }
        return payments;
    }

    // 5. CHECK — whether an order has already been paid

    /**
     * Returns true if at least one payment record exists for the given order.
     * Used by PaymentServlet to prevent double-payment.
     *
     * @param orderId  Order to check.
     * @return  true if already paid, false otherwise.
     */
    public boolean isOrderPaid(int orderId) {
        String sql = "SELECT COUNT(*) FROM payments WHERE order_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }

        } catch (SQLException e) {
            System.err.println("[PaymentDAO.isOrderPaid] Error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public int countPaymentsToday() {
        return getIntValue("SELECT COUNT(*) FROM payments WHERE payment_date = CURDATE()");
    }

    public int countPaymentsByMethodToday(String method) {
        String sql = "SELECT COUNT(*) FROM payments WHERE payment_date = CURDATE() AND payment_method = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, method);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("[PaymentDAO.countPaymentsByMethodToday] Error: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    public double getTotalRevenueToday() {
        return getDoubleValue("SELECT COALESCE(SUM(amount), 0) FROM payments WHERE payment_date = CURDATE()");
    }

    // 6. READ — fetch the total_amount of an order (to pre-fill form)

    /**
     * Retrieves the total_amount from the orders table for a given order.
     * Used by PaymentServlet to pre-populate the amount field on the payment form.
     *
     * @param orderId  Order to look up.
     * @return  Total amount as double, or 0.0 if not found.
     */
    public double getOrderAmountDue(int orderId) {
        String sql = "SELECT total_amount FROM orders WHERE order_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("total_amount");
                }
            }

        } catch (SQLException e) {
            System.err.println("[PaymentDAO.getOrderAmountDue] Error: " + e.getMessage());
            e.printStackTrace();
        }
        return 0.0;
    }

    // Private helper — map a ResultSet row to a Payment object

    private Payment mapRow(ResultSet rs) throws SQLException {
        Payment p = new Payment();
        p.setPaymentId(rs.getInt("payment_id"));
        p.setOrderId(rs.getInt("order_id"));
        p.setCashierId(rs.getInt("cashier_id"));
        p.setAmount(rs.getDouble("amount"));
        p.setPaymentMethod(rs.getString("payment_method"));
        p.setTransactionReference(rs.getString("transaction_reference"));

        // payment_date and payment_time may be null in edge cases
        java.sql.Date pDate = rs.getDate("payment_date");
        java.sql.Time pTime = rs.getTime("payment_time");
        p.setPaymentDate(pDate != null ? pDate.toString() : "");
        p.setPaymentTime(pTime != null ? pTime.toString() : "");

        // cashier_name is a joined column — not always present
        try {
            p.setCashierName(rs.getString("cashier_name"));
        } catch (SQLException ignored) {
            // column not in result set if called without JOIN
        }
        return p;
    }

    private int getIntValue(String sql) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[PaymentDAO.getIntValue] Error: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    private double getDoubleValue(String sql) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            System.err.println("[PaymentDAO.getDoubleValue] Error: " + e.getMessage());
            e.printStackTrace();
        }
        return 0.0;
    }

    private int sanitizeLimit(int limit) {
        return Math.max(1, Math.min(limit, 20));
    }
}

