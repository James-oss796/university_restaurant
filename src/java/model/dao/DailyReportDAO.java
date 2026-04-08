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
    
}
