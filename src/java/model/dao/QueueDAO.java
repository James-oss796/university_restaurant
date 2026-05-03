package model.dao;
import java.sql.*;

public class QueueDAO {
    // 1. assignQueueNumber
    public int assignQueueNumber(int customerId) {
        // Logic: Get the current max queue number for the day and add 1
        String sql = "INSERT INTO queue (customer_id, queue_number, status, joined_at) " +
                     "VALUES (?, (SELECT IFNULL(MAX(queue_number), 0) + 1 FROM queue AS q), 'WAITING', NOW())";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, customerId);
            ps.executeUpdate();
            
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) {
                int newId = rs.getInt(1);
                // Fetch the actual queue_number assigned
                try (PreparedStatement ps2 = con.prepareStatement("SELECT queue_number FROM queue WHERE queue_id = ?")) {
                    ps2.setInt(1, newId);
                    try (ResultSet rs2 = ps2.executeQuery()) {
                        if (rs2.next()) {
                            return rs2.getInt("queue_number");
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1; // Failure
    }

    // 2. updateQueueStatus
    public boolean updateQueueStatus(int queueId, String newStatus) {
        String sql = "UPDATE queue SET status = ? WHERE queue_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, newStatus); // e.g., "SERVING", "COMPLETED", "CANCELLED"
            ps.setInt(2, queueId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
