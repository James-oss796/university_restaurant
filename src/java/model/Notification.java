// Member D (Notifications) - Notification.java


package model;

/**
 * Notification model class.
 *
 * Database table: notifications
 * Columns: notification_id, customer_id, order_id, message, type,
 *          is_read, sent_at
 *
 * type is constrained to ENUM('order_status','queue_update','promotion') in MySQL.
 * is_read defaults to FALSE in the DB (new notifications are unread).
 * sent_at is set to NOW() by the DB on INSERT.
 */
public class Notification {

 
    // Constants for notification type values (mirrors DB ENUM)
 
    public static final String TYPE_ORDER_STATUS = "order_status";
    public static final String TYPE_QUEUE_UPDATE = "queue_update";
    public static final String TYPE_PROMOTION    = "promotion";

    // Fields
    private int    notificationId;
    private int    customerId;   // FK → users.user_id
    private int    orderId;      // FK → orders.order_id (0 if not order-related)
    private String message;
    private String type;         // "order_status" | "queue_update" | "promotion"
    private boolean isRead;
    private String sentAt;       // Stored as String (timestamp from DB)

    // Constructors

    /** Default no-arg constructor (required by DAO layer). */
    public Notification() {}

    /**
     * Convenience constructor for building a notification before persisting.
     * notificationId and sentAt are set by the DB on INSERT.
     */
    public Notification(int customerId, int orderId,
                        String message, String type) {
        this.customerId = customerId;
        this.orderId    = orderId;
        this.message    = message;
        this.type       = type;
        this.isRead     = false;
    }

    // Business helpers

    /**
     * Returns a human-readable label for the notification type.
     * e.g. "order_status" → "Order Status"
     */
    public String getTypeLabel() {
        switch (type == null ? "" : type) {
            case TYPE_ORDER_STATUS: return "Order Status";
            case TYPE_QUEUE_UPDATE: return "Queue Update";
            case TYPE_PROMOTION:    return "Promotion";
            default:                return type;
        }
    }

    /**
     * Returns a CSS class string based on notification type.
     * Useful in JSP for colour-coding notification entries.
     */
    public String getTypeCssClass() {
        switch (type == null ? "" : type) {
            case TYPE_ORDER_STATUS: return "notif-order";
            case TYPE_QUEUE_UPDATE: return "notif-queue";
            case TYPE_PROMOTION:    return "notif-promo";
            default:                return "notif-default";
        }
    }

    // Getters & Setters

    public int getNotificationId() { return notificationId; }
    public void setNotificationId(int notificationId) { this.notificationId = notificationId; }

    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public boolean isRead() { return isRead; }
    public void setRead(boolean read) { isRead = read; }

    public String getSentAt() { return sentAt; }
    public void setSentAt(String sentAt) { this.sentAt = sentAt; }

    @Override
    public String toString() {
        return "Notification{id=" + notificationId
             + ", customerId=" + customerId
             + ", orderId=" + orderId
             + ", type=" + type
             + ", isRead=" + isRead + "}";
    }
}
