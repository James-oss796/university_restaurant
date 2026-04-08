package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import model.MenuItem;
import model.Order;
import model.User;
import model.dao.MenuItemDAO;
import model.dao.NotificationDAO;
import model.dao.OrderDAO;
import model.dao.QueueDAO;

public class QueueServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User queueUser = getStudentUser(req);
        if (queueUser == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        HttpSession session = req.getSession(false);
        OrderDAO orderDAO = new OrderDAO();
        List<Order> orders = orderDAO.getOrdersByUser(queueUser.getUserId());

        if (!orders.isEmpty()) {
            Order latestOrder = orders.get(0);
            QueueDAO queueDAO = new QueueDAO();
            int orderId = latestOrder.getOrderId();
            int queueNumber = queueDAO.getQueueNumberByOrder(orderId);
            int queuePosition = queueDAO.getLivePositionByOrder(orderId);
            int estimatedWaitMinutes = queueDAO.getLiveEstimatedWaitTimeByOrder(orderId);

            req.setAttribute("lastOrderId", orderId);
            req.setAttribute("queueNumber", queueNumber);
            req.setAttribute("queuePosition", queuePosition);
            req.setAttribute("estimatedWaitMinutes", estimatedWaitMinutes);
            req.setAttribute("lastOrderTotal", latestOrder.getTotalAmount());
            req.setAttribute("orderStatus", latestOrder.getStatus());
            req.setAttribute("activeQueueCount", queueDAO.getActiveQueueCount());

            if (session != null) {
                session.setAttribute("lastOrderId", orderId);
                session.setAttribute("queueNumber", queueNumber);
                session.setAttribute("queuePosition", queuePosition);
                session.setAttribute("estimatedWaitMinutes", estimatedWaitMinutes);
                session.setAttribute("lastOrderTotal", latestOrder.getTotalAmount());
            }
        }

        req.getRequestDispatcher("queue.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        User queueUser = getStudentUser(req);
        if (queueUser == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        Map<Integer, Integer> cart = getCart(session.getAttribute("cart"));
        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/MenuServlet");
            return;
        }
        MenuItemDAO menuItemDAO = new MenuItemDAO();
        Map<Integer, MenuItem> itemsById = menuItemDAO.getMenuItemsByIds(cart.keySet());
        if (itemsById.size() != cart.size()) {
            req.setAttribute("error", "Your cart contains unavailable items. Please build the order again.");
            req.getRequestDispatcher("order.jsp").forward(req, resp);
            return;
        }

        double total = 0;
        for (Map.Entry<Integer, Integer> entry : cart.entrySet()) {
            MenuItem item = itemsById.get(entry.getKey());
            if (item == null) {
                req.setAttribute("error", "Your cart contains invalid menu items. Please try again.");
                req.getRequestDispatcher("order.jsp").forward(req, resp);
                return;
            }
            total += item.getPrice() * entry.getValue();
        }

        Order order = new Order(queueUser.getUserId(), total, "pending");
        OrderDAO orderDAO = new OrderDAO();
        int orderId = orderDAO.createOrderWithItems(order, cart, itemsById);
        if (orderId <= 0) {
            req.setAttribute("error", "Your order could not be saved. Please try again.");
            req.getRequestDispatcher("order.jsp").forward(req, resp);
            return;
        }

        QueueDAO queueDAO = new QueueDAO();
        int queueNumber = queueDAO.assignQueueNumber(orderId);
        if (queueNumber <= 0) {
            req.setAttribute("error", "Your order was saved, but queue assignment failed. Please contact the cashier.");
            req.getRequestDispatcher("order.jsp").forward(req, resp);
            return;
        }

        int queuePosition = queueDAO.getLivePositionByOrder(orderId);
        int estimatedWaitMinutes = queueDAO.getLiveEstimatedWaitTimeByOrder(orderId);

        session.setAttribute("lastOrderId", orderId);
        session.setAttribute("queueNumber", queueNumber);
        session.setAttribute("queuePosition", queuePosition);
        session.setAttribute("estimatedWaitMinutes", estimatedWaitMinutes);
        session.setAttribute("lastOrderTotal", total);
        session.removeAttribute("cart");
        session.removeAttribute("selectedItems");
        session.removeAttribute("cartTotal");

        try {
            NotificationDAO notificationDAO = new NotificationDAO();
            notificationDAO.insertQueueUpdateNotification(queueUser.getUserId(), orderId, queueNumber);
        } catch (Exception notificationError) {
            System.err.println("[QueueServlet] Notification error: " + notificationError.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/QueueServlet");
    }

    private User getStudentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) {
            return null;
        }

        Object sessionUser = session.getAttribute("user");
        if (!(sessionUser instanceof User user) || !"student".equals(user.getRole())) {
            return null;
        }
        return user;
    }

    @SuppressWarnings("unchecked")
    private Map<Integer, Integer> getCart(Object cartObject) {
        if (!(cartObject instanceof Map<?, ?> rawCart)) {
            return null;
        }

        for (Map.Entry<?, ?> entry : rawCart.entrySet()) {
            if (!(entry.getKey() instanceof Integer) || !(entry.getValue() instanceof Integer)) {
                return null;
            }
        }

        return (Map<Integer, Integer>) rawCart;
    }
}
