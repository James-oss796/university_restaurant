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
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        Object cartObj = session.getAttribute("cart");

        if (cartObj == null) {
            resp.sendRedirect("menu.jsp"); // No cart, go back
            return;
        }

        // Simulate assigning a queue number
        Random rand = new Random();
        int queueNumber = rand.nextInt(1000) + 1; // 1–1000

        session.setAttribute("queueNumber", queueNumber);

        try {
            User queueUser = (User) session.getAttribute("user");
            // orderId must be stored in session by OrderServlet (Member C)
            Integer orderId = (Integer) session.getAttribute("lastOrderId");
 
            if (queueUser != null && orderId != null && queueNumber > 0) {
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
