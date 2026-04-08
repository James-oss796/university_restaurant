package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Payment;
import model.User;
import model.dao.OrderDAO;
import model.dao.PaymentDAO;
import model.dao.QueueDAO;
import model.dao.UserDAO;

public class AdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;

        if (user == null || !"admin".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        UserDAO userDAO = new UserDAO();
        OrderDAO orderDAO = new OrderDAO();
        PaymentDAO paymentDAO = new PaymentDAO();
        QueueDAO queueDAO = new QueueDAO();

        req.setAttribute("totalUsers", userDAO.countAllUsers());
        req.setAttribute("activeUsers", userDAO.countActiveUsers());
        req.setAttribute("roleCounts", userDAO.countUsersByRole());
        req.setAttribute("todayOrders", orderDAO.countOrdersToday());
        req.setAttribute("pendingOrders", orderDAO.countOrdersByStatus("pending"));
        req.setAttribute("preparingOrders", orderDAO.countOrdersByStatus("preparing"));
        req.setAttribute("paymentsToday", paymentDAO.countPaymentsToday());
        req.setAttribute("revenueToday", paymentDAO.getTotalRevenueToday());
        req.setAttribute("cashPaymentsToday", paymentDAO.countPaymentsByMethodToday(Payment.METHOD_CASH));
        req.setAttribute("mobilePaymentsToday", paymentDAO.countPaymentsByMethodToday(Payment.METHOD_MOBILE_MONEY));
        req.setAttribute("activeQueueCount", queueDAO.getActiveQueueCount());
        req.setAttribute("longestQueueWait", queueDAO.getLongestActiveWaitMinutes());
        req.setAttribute("nextQueueNumber", queueDAO.getNextQueueNumberPreview());
        req.setAttribute("recentOrders", orderDAO.getRecentOrderSummaries(6));
        req.setAttribute("recentPayments", paymentDAO.getRecentPayments(6));
        req.setAttribute("queueOverview", queueDAO.getActiveQueueOverview(6));

        req.getRequestDispatcher("admin.jsp").forward(req, resp);
    }
}
