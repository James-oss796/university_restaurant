package model.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class QueueDAO {
    private static final int SERVICE_MINUTES_PER_ORDER = 4;

    public int assignQueueNumber(int orderId) {
        String sql = "INSERT INTO queue (order_id, queue_number, position, estimated_wait_time, status, joined_at) "
                   + "VALUES (?, ?, ?, ?, 'waiting', NOW())";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            int queueNumber = getNextQueueNumber(con);
            int position = getNextPosition(con);
            int estimatedWaitTime = Math.max((position - 1) * SERVICE_MINUTES_PER_ORDER, 0);

            ps.setInt(1, orderId);
            ps.setInt(2, queueNumber);
            ps.setInt(3, position);
            ps.setInt(4, estimatedWaitTime);
            ps.executeUpdate();

            return queueNumber;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public boolean updateQueueStatus(int queueId, String newStatus) {
        String sql = "UPDATE queue SET status = ? WHERE queue_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, newStatus);
            ps.setInt(2, queueId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public int getPositionByOrder(int orderId) {
        return getIntValue("SELECT position FROM queue WHERE order_id = ?", orderId);
    }

    public int getQueueNumberByOrder(int orderId) {
        return getIntValue("SELECT queue_number FROM queue WHERE order_id = ?", orderId);
    }

    public int getEstimatedWaitTimeByOrder(int orderId) {
        return getIntValue("SELECT estimated_wait_time FROM queue WHERE order_id = ?", orderId);
    }

    public int getLivePositionByOrder(int orderId) {
        String sql = "SELECT CASE "
                   + "WHEN paid.payment_id IS NOT NULL THEN 0 "
                   + "ELSE ("
                   + "    SELECT COUNT(*) + 1 "
                   + "    FROM queue q2 "
                   + "    LEFT JOIN payments p2 ON p2.order_id = q2.order_id "
                   + "    WHERE q2.status = 'waiting' "
                   + "      AND p2.payment_id IS NULL "
                   + "      AND (q2.joined_at < q.joined_at "
                   + "           OR (q2.joined_at = q.joined_at AND q2.queue_id < q.queue_id))"
                   + ") "
                   + "END AS live_position "
                   + "FROM queue q "
                   + "LEFT JOIN payments paid ON paid.order_id = q.order_id "
                   + "WHERE q.order_id = ? "
                   + "LIMIT 1";

        return getIntValue(sql, orderId);
    }

    public int getLiveEstimatedWaitTimeByOrder(int orderId) {
        int livePosition = getLivePositionByOrder(orderId);
        return livePosition <= 1 ? 0 : (livePosition - 1) * SERVICE_MINUTES_PER_ORDER;
    }

    public int getActiveQueueCount() {
        String sql = "SELECT COUNT(*) "
                   + "FROM queue q "
                   + "LEFT JOIN payments p ON p.order_id = q.order_id "
                   + "WHERE q.status = 'waiting' AND p.payment_id IS NULL";
        return getSingleCount(sql);
    }

    public int getLongestActiveWaitMinutes() {
        int activeQueueCount = getActiveQueueCount();
        return activeQueueCount <= 1 ? 0 : (activeQueueCount - 1) * SERVICE_MINUTES_PER_ORDER;
    }

    public int getAverageActiveWaitMinutes() {
        int activeQueueCount = getActiveQueueCount();
        return activeQueueCount <= 1 ? 0 : ((activeQueueCount - 1) * SERVICE_MINUTES_PER_ORDER) / 2;
    }

    public int getNextQueueNumberPreview() {
        String sql = "SELECT COALESCE(MAX(queue_number), 0) + 1 "
                   + "FROM queue WHERE DATE(joined_at) = CURDATE()";
        return getSingleCount(sql);
    }

    public List<Map<String, Object>> getActiveQueueOverview(int limit) {
        List<Map<String, Object>> rows = new ArrayList<>();
        String sql = "SELECT q.queue_number, q.order_id, u.name AS customer_name, o.total_amount, "
                   + "o.status, q.joined_at, TIMESTAMPDIFF(MINUTE, q.joined_at, NOW()) AS waiting_minutes "
                   + "FROM queue q "
                   + "JOIN orders o ON o.order_id = q.order_id "
                   + "JOIN users u ON u.user_id = o.customer_id "
                   + "LEFT JOIN payments p ON p.order_id = q.order_id "
                   + "WHERE q.status = 'waiting' AND p.payment_id IS NULL "
                   + "ORDER BY q.joined_at ASC, q.queue_id ASC "
                   + "LIMIT " + sanitizeLimit(limit);

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("queueNumber", rs.getInt("queue_number"));
                row.put("orderId", rs.getInt("order_id"));
                row.put("customerName", rs.getString("customer_name"));
                row.put("totalAmount", rs.getDouble("total_amount"));
                row.put("status", rs.getString("status"));
                row.put("joinedAt", rs.getString("joined_at"));
                row.put("waitingMinutes", rs.getInt("waiting_minutes"));
                rows.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rows;
    }

    private int getNextQueueNumber(Connection con) throws SQLException {
        String sql = "SELECT COALESCE(MAX(queue_number), 0) + 1 "
                   + "FROM queue WHERE DATE(joined_at) = CURDATE()";

        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 1;
    }

    private int getNextPosition(Connection con) throws SQLException {
        String sql = "SELECT COUNT(*) + 1 FROM queue WHERE status = 'waiting'";

        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 1;
    }

    private int getIntValue(String sql, int orderId) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private int getSingleCount(String sql) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private int sanitizeLimit(int limit) {
        return Math.max(1, Math.min(limit, 20));
    }
}
