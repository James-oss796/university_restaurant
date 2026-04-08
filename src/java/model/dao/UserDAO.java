package model.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.User;

public class UserDAO {

    private String lastErrorMessage;

    public User findByEmail(String email) {
        clearError();

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "SELECT * FROM users WHERE email=?")) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setUserId(rs.getInt("user_id"));
                    u.setStudentId(rs.getString("student_id"));
                    u.setName(rs.getString("name"));
                    u.setPhoneNumber(rs.getString("phone_number"));
                    u.setEmail(rs.getString("email"));
                    u.setPasswordHash(rs.getString("password_hash"));
                    u.setRole(rs.getString("role"));
                    u.setActive(rs.getBoolean("is_active"));
                    u.setCreatedAt(rs.getString("created_at"));
                    return u;
                }
            }

        } catch (SQLException e) {
            setError("The system could not read user records from the database.", e);
        }
        return null;
    }

    public boolean insertUser(User user) {
        clearError();

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "INSERT INTO users(student_id, name, phone_number, email, password_hash, role, is_active) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)")) {

            if (user.getStudentId() == null || user.getStudentId().trim().isEmpty()) {
                ps.setNull(1, Types.VARCHAR);
            } else {
                ps.setString(1, user.getStudentId());
            }

            ps.setString(2, user.getName());
            ps.setString(3, user.getPhoneNumber());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getPasswordHash());
            ps.setString(6, user.getRole());
            ps.setBoolean(7, user.isActive());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            if (e.getErrorCode() == 1062 || "23000".equals(e.getSQLState())) {
                setError("That email is already registered.");
            } else {
                setError("The system could not save your account details right now.", e);
            }
        }
        return false;
    }

    public int countAllUsers() {
        return getCount("SELECT COUNT(*) FROM users");
    }

    public int countActiveUsers() {
        return getCount("SELECT COUNT(*) FROM users WHERE is_active = 1");
    }

    public Map<String, Integer> countUsersByRole() {
        Map<String, Integer> counts = new LinkedHashMap<>();
        counts.put("student", 0);
        counts.put("cashier", 0);
        counts.put("admin", 0);

        String sql = "SELECT role, COUNT(*) AS total FROM users GROUP BY role";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                counts.put(rs.getString("role"), rs.getInt("total"));
            }
        } catch (SQLException e) {
            setError("The system could not summarize user roles.", e);
        }
        return counts;
    }

    public List<User> getRecentUsers(int limit) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT user_id, student_id, name, phone_number, email, role, is_active, created_at "
                   + "FROM users ORDER BY created_at DESC LIMIT " + sanitizeLimit(limit);

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setStudentId(rs.getString("student_id"));
                user.setName(rs.getString("name"));
                user.setPhoneNumber(rs.getString("phone_number"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                user.setActive(rs.getBoolean("is_active"));
                user.setCreatedAt(rs.getString("created_at"));
                users.add(user);
            }
        } catch (SQLException e) {
            setError("The system could not load recent users.", e);
        }
        return users;
    }

    public boolean hasError() {
        return lastErrorMessage != null && !lastErrorMessage.isEmpty();
    }

    public String getLastErrorMessage() {
        return lastErrorMessage;
    }

    private void clearError() {
        lastErrorMessage = null;
    }

    private int getCount(String sql) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            setError("The system could not read user totals.", e);
        }
        return 0;
    }

    private int sanitizeLimit(int limit) {
        return Math.max(1, Math.min(limit, 20));
    }

    private void setError(String message) {
        lastErrorMessage = message;
    }

    private void setError(String message, SQLException e) {
        lastErrorMessage = message;
        e.printStackTrace();
    }
}
