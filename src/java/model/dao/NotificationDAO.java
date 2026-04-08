package model.dao;

import model.Notification;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * NotificationDAO — CRUD operations for the notifications table.
 *
 * Methods:
 *  - insertNotification(Notification)           → save a new notification; returns generated ID or -1
 *  - getNotificationsByUser(int customerId)      → list all notifications for a student
 *  - getUnreadCountByUser(int customerId)        → count of unread notifications (for badge display)
 *  - markAsRead(int notificationId)             → mark one notification as read
 *  - markAllAsRead(int customerId)              → mark all notifications for a user as read
 *  - insertPaymentConfirmationNotification(...)  → convenience method triggered after payment
 *  - insertOrderStatusNotification(...)          → convenience method triggered on order status change
 *  - insertQueueUpdateNotification(...)          → convenience method triggered on queue position change
 */
public class NotificationDAO {

    // 1. INSERT — persist a Notification record

    /**
     * Inserts a notification record into the database.
     * sent_at is set automatically by NOW() in the SQL.
     * is_read defaults to FALSE.
     *
     * @param n  A Notification object with customerId, orderId, message, type set.
     * @return   The generated notification_id (> 0) on success, or -1 on failure.
     */
    public int insertNotification(Notification n) {
        String sql = "INSERT INTO notifications "
                   + "(customer_id, order_id, message, type, is_read, sent_at) "
                   + "VALUES (?, ?, ?, ?, FALSE, NOW())";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, n.getCustomerId());

            // order_id is optional for promotions (set to 0 or use NULL)
            if (n.getOrderId() > 0) {
                ps.setInt(2, n.getOrderId());
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }

            ps.setString(3, n.getMessage());
            ps.setString(4, n.getType());

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int generatedId = generatedKeys.getInt(1);
                        n.setNotificationId(generatedId);
                        return generatedId;
                    }
                }
            }

        } catch (SQLException e) {
            System.err.println("[NotificationDAO.insertNotification] Error: " + e.getMessage());
            e.printStackTrace();
        }
        return -1;
    }

    // 2. READ — all notifications for a specific user (student view)

    /**
     * Returns all notifications for a specific customer, newest first.
     * Used by notification.jsp to display the student's notification list.
     *
     * @param customerId  The user_id of the student.
     * @return  List of Notification objects (may be empty, never null).
     */
    public List<Notification> getNotificationsByUser(int customerId) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT * FROM notifications "
                   + "WHERE customer_id = ? "
                   + "ORDER BY sent_at DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }

        } catch (SQLException e) {
            System.err.println("[NotificationDAO.getNotificationsByUser] Error: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // 3. READ — count of unread notifications (for navigation badge)

    /**
     * Returns the number of unread notifications for a given user.
     * Used by layout.jsp to show a badge count on the Notifications link.
     *
     * @param customerId  The user_id of the student.
     * @return  Count of unread notifications (0 if none or on error).
     */
    public int getUnreadCountByUser(int customerId) {
        String sql = "SELECT COUNT(*) FROM notifications "
                   + "WHERE customer_id = ? AND is_read = FALSE";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (SQLException e) {
            System.err.println("[NotificationDAO.getUnreadCountByUser] Error: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    // 4. UPDATE — mark a single notification as read

    /**
     * Marks one notification as read (is_read = TRUE).
     * Called when a student clicks on a specific notification.
     *
     * @param notificationId  The notification to mark as read.
     * @return  true on success, false otherwise.
     */
    public boolean markAsRead(int notificationId) {
        String sql = "UPDATE notifications SET is_read = TRUE "
                   + "WHERE notification_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, notificationId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("[NotificationDAO.markAsRead] Error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // 5. UPDATE — mark ALL notifications for a user as read

    /**
     * Marks all of a student's notifications as read.
     * Called when the student opens the notification page or clicks "Mark all as read".
     *
     * @param customerId  The user_id of the student.
     * @return  true if at least one row was updated, false otherwise.
     */
    public boolean markAllAsRead(int customerId) {
        String sql = "UPDATE notifications SET is_read = TRUE "
                   + "WHERE customer_id = ? AND is_read = FALSE";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("[NotificationDAO.markAllAsRead] Error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // 6. Convenience — send a payment confirmation notification

    /**
     * Creates and inserts a payment confirmation notification for a student.
     * Called by PaymentServlet immediately after a successful payment.
     *
     * @param customerId  The student who placed the order.
     * @param orderId     The order that was just paid for.
     * @param amount      The amount that was paid.
     * @param method      Payment method string ("cash" or "mobile_money").
     * @return  The generated notification_id or -1 on failure.
     */
    public int insertPaymentConfirmationNotification(int customerId, int orderId,
                                                     double amount, String method) {
        String methodLabel = "mobile_money".equals(method) ? "Mobile Money" : "Cash";
        String message = String.format(
            "Payment of KES %.2f received via %s for Order #%d. Thank you!",
            amount, methodLabel, orderId
        );

        Notification n = new Notification(customerId, orderId, message,
                                          Notification.TYPE_ORDER_STATUS);
        return insertNotification(n);
    }

    // 7. Convenience — send an order status change notification

    /**
     * Creates and inserts an order status update notification.
     * Intended to be called by QueueServlet or an admin action
     * when the order status changes (pending → preparing → ready → served).
     *
     * @param customerId  The student to notify.
     * @param orderId     The order whose status changed.
     * @param newStatus   The new order status string.
     * @return  The generated notification_id or -1 on failure.
     */
    public int insertOrderStatusNotification(int customerId, int orderId, String newStatus) {
        String message = String.format(
            "Your Order #%d status has been updated to: %s.",
            orderId, newStatus
        );

        Notification n = new Notification(customerId, orderId, message,
                                          Notification.TYPE_ORDER_STATUS);
        return insertNotification(n);
    }

    // 8. Convenience — send a queue position update notification

    /**
     * Creates and inserts a queue update notification.
     * Intended to be called by QueueServlet when a queue
     * number is assigned or position changes.
     *
     * @param customerId   The student to notify.
     * @param orderId      The related order.
     * @param queueNumber  The assigned queue number.
     * @return  The generated notification_id or -1 on failure.
     */
    public int insertQueueUpdateNotification(int customerId, int orderId, int queueNumber) {
        String message = String.format(
            "You have been assigned Queue #%d for Order #%d. Please wait for your number to be called.",
            queueNumber, orderId
        );

        Notification n = new Notification(customerId, orderId, message,
                                          Notification.TYPE_QUEUE_UPDATE);
        return insertNotification(n);
    }

    // Private helper — map a ResultSet row to a Notification object

    private Notification mapRow(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setNotificationId(rs.getInt("notification_id"));
        n.setCustomerId(rs.getInt("customer_id"));
        n.setOrderId(rs.getInt("order_id"));
        n.setMessage(rs.getString("message"));
        n.setType(rs.getString("type"));
        n.setRead(rs.getBoolean("is_read"));
        n.setSentAt(rs.getString("sent_at"));
        return n;
    }
}

