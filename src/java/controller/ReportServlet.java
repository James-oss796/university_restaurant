package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.DailyReport;
import model.User;
import model.dao.DailyReportDAO;

public class ReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = getAdminUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        DailyReportDAO dao = new DailyReportDAO();
        List<DailyReport> reports = dao.getAllReports();

        req.setAttribute("reports", reports);
        req.getRequestDispatcher("report.jsp").forward(req, resp);
    }

    private User getAdminUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) {
            return null;
        }

        Object sessionUser = session.getAttribute("user");
        if (!(sessionUser instanceof User user) || !"admin".equals(user.getRole())) {
            return null;
        }
        return user;
    }
}
