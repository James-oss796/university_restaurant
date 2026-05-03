// Member E (Reports & Admin Dashboard) should implement this file

package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import model.dao.DailyReportDAO;
import model.DailyReport;
import model.User;

public class ReportServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }
        User user = (User) session.getAttribute("user");
        if (!"admin".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        DailyReportDAO dao = new DailyReportDAO();
        List<DailyReport> reports = dao.getAllReports();
        
        // 5 Dynamic Reports
        Map<String, Double> salesTrends = dao.getSalesTrends();
        Map<String, Integer> orderStatusBreakdown = dao.getOrderStatusBreakdown();
        Map<String, Double> revenueByMethod = dao.getRevenueByMethod();
        List<Map<String, Object>> topUsers = dao.getTopUsers();
        List<Map<String, Object>> menuPerformance = dao.getMenuPerformance();

        req.setAttribute("reports", reports);
        req.setAttribute("salesTrends", salesTrends);
        req.setAttribute("orderStatusBreakdown", orderStatusBreakdown);
        req.setAttribute("revenueByMethod", revenueByMethod);
        req.setAttribute("topUsers", topUsers);
        req.setAttribute("menuPerformance", menuPerformance);
        
        req.getRequestDispatcher("report.jsp").forward(req, resp);
    }
}
