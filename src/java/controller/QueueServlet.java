// Member C (Orders & Queue Management) should implement this file

package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Random;
import model.User;
import model.dao.NotificationDAO;
import model.dao.OrderDAO;

public class QueueServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession();
        if (session.getAttribute("queueNumber") != null) {
            Integer lastOrderId = (Integer) session.getAttribute("lastOrderId");
            if (lastOrderId != null) {
                OrderDAO orderDAO = new OrderDAO();
                model.Order order = orderDAO.getOrderById(lastOrderId);
                if (order != null) {
                    req.setAttribute("orderStatus", order.getStatus());
                }
            }
            req.getRequestDispatcher("queue.jsp").forward(req, resp);
        } else {
            resp.sendRedirect("menu.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        Object cartObj = session.getAttribute("cart");

        if (cartObj == null) {
            resp.sendRedirect("menu.jsp"); // No cart, go back
            return;
        }

        User queueUser = (User) session.getAttribute("user");
        if (queueUser == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        // Get queue number from DB
        model.dao.QueueDAO queueDAO = new model.dao.QueueDAO();
        int queueNumber = queueDAO.assignQueueNumber(queueUser.getUserId());

        session.setAttribute("queueNumber", queueNumber);

        try {
            // orderId must be stored in session by OrderServlet (Member C)
            Integer orderId = (Integer) session.getAttribute("lastOrderId");
 
            if (orderId != null && queueNumber > 0) {
                NotificationDAO notifDAO = new NotificationDAO();
                notifDAO.insertQueueUpdateNotification(
                    queueUser.getUserId(),
                    orderId,
                    queueNumber
                );
            }
        } catch (Exception notifEx) {
            // Notification failure must NOT stop queue processing
            System.err.println("[QueueServlet] Notification error: " + notifEx.getMessage());
        }

        resp.sendRedirect("queue.jsp");
    }
}
