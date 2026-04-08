package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

import model.Notification;
import model.Payment;
import model.User;
import model.dao.NotificationDAO;
import model.dao.OrderDAO;
import model.dao.PaymentDAO;
import model.dao.QueueDAO;

/**
 * PaymentServlet — handles payment processing for cashiers.
 *
 * Flow:
 *  1. Cashier opens payment.jsp (GET) — optionally with ?orderId=X to pre-fill form.
 *  2. Cashier submits the payment form (POST).
 *  3. Servlet validates input, prevents double-payment, saves payment via PaymentDAO.
 *  4. Servlet sends a payment confirmation notification to the student via NotificationDAO.
 *  5. Servlet redirects to payment.jsp with a success message.
 *
 * Error handling:
 *  - Missing / invalid fields → forward back to payment.jsp with error attribute.
 *  - Order already paid        → forward back to payment.jsp with specific error.
 *  - DB failure                → forward back to payment.jsp with generic error.
 */
public class PaymentServlet extends HttpServlet {

    // GET — display the payment form
    

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // 1. Enforce cashier-only access
        User user = getSessionUser(req);
        if (!isCashier(user)) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        HttpSession session = req.getSession(false);
        if (session != null) {
            Object successMessage = session.getAttribute("paymentSuccess");
            if (successMessage != null) {
                req.setAttribute("paymentSuccess", successMessage);
                session.removeAttribute("paymentSuccess");
            }
        }

        loadCashierDashboardData(req);

        String action = getValue(req.getParameter("action"));
        if ("history".equals(action)) {
            showPaymentHistory(req, resp);
            return;
        }

        // 2. If an orderId was passed in the URL, pre-populate the amount field
        String orderIdParam = req.getParameter("orderId");
        if (orderIdParam != null && !orderIdParam.trim().isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdParam.trim());

                // Check if already paid
                PaymentDAO paymentDAO = new PaymentDAO();
                if (paymentDAO.isOrderPaid(orderId)) {
                    req.setAttribute("warning",
                        "Order #" + orderId + " has already been paid.");
                } else {
                    double amountDue = paymentDAO.getOrderAmountDue(orderId);
                    req.setAttribute("prefilledOrderId", orderId);
                    req.setAttribute("prefilledAmount",
                        String.format("%.2f", amountDue));
                }
            } catch (NumberFormatException e) {
                req.setAttribute("error", "Invalid order ID.");
            }
        }

        // 3. Forward to payment.jsp
        req.getRequestDispatcher("payment.jsp").forward(req, resp);
    }

    // POST — process a payment form submission

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        // 1. Enforce cashier-only access
        User cashier = getSessionUser(req);
        if (!isCashier(cashier)) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        // 2. Handle sub-actions (e.g. viewing payment history)
        String action = req.getParameter("action");
        if ("history".equals(action)) {
            showPaymentHistory(req, resp);
            return;
        }

        // 3. Read and validate form fields
        String orderIdStr   = getValue(req.getParameter("orderId"));
        String amountStr    = getValue(req.getParameter("amount"));
        String method       = getValue(req.getParameter("paymentMethod"));
        String reference    = getValue(req.getParameter("transactionReference"));
        populateFormState(req, orderIdStr, amountStr, method, reference);

        // Validate: orderId is required
        if (orderIdStr.isEmpty()) {
            req.setAttribute("error", "Order ID is required.");
            loadCashierDashboardData(req);
            req.getRequestDispatcher("payment.jsp").forward(req, resp);
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdStr);
            if (orderId <= 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Order ID must be a positive integer.");
            loadCashierDashboardData(req);
            req.getRequestDispatcher("payment.jsp").forward(req, resp);
            return;
        }

        // Validate: amount is required and must be a positive number
        if (amountStr.isEmpty()) {
            req.setAttribute("error", "Amount is required.");
            loadCashierDashboardData(req);
            req.getRequestDispatcher("payment.jsp").forward(req, resp);
            return;
        }

        double amount;
        try {
            amount = Double.parseDouble(amountStr);
            if (amount <= 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Amount must be a positive number.");
            loadCashierDashboardData(req);
            req.getRequestDispatcher("payment.jsp").forward(req, resp);
            return;
        }

        // Validate: payment method must be "cash" or "mobile_money"
        if (!Payment.METHOD_CASH.equals(method) && !Payment.METHOD_MOBILE_MONEY.equals(method)) {
            req.setAttribute("error", "Please select a valid payment method.");
            loadCashierDashboardData(req);
            req.getRequestDispatcher("payment.jsp").forward(req, resp);
            return;
        }

        // Validate: mobile_money requires a transaction reference
        if (Payment.METHOD_MOBILE_MONEY.equals(method) && reference.isEmpty()) {
            req.setAttribute("error",
                "A transaction reference is required for Mobile Money payments.");
            loadCashierDashboardData(req);
            req.getRequestDispatcher("payment.jsp").forward(req, resp);
            return;
        }

        // 4. Prevent duplicate payments
        PaymentDAO paymentDAO = new PaymentDAO();
        double amountDue = paymentDAO.getOrderAmountDue(orderId);
        if (amountDue <= 0) {
            req.setAttribute("error", "Order #" + orderId + " was not found.");
            loadCashierDashboardData(req);
            req.getRequestDispatcher("payment.jsp").forward(req, resp);
            return;
        }

        if (paymentDAO.isOrderPaid(orderId)) {
            req.setAttribute("error",
                "Order #" + orderId + " has already been paid. "
              + "Please verify the order number.");
            loadCashierDashboardData(req);
            req.getRequestDispatcher("payment.jsp").forward(req, resp);
            return;
        }

        if (Math.abs(amount - amountDue) > 0.009d) {
            req.setAttribute("error",
                "Amount must match the order total. Order #" + orderId
              + " is due KES " + String.format("%.2f", amountDue) + ".");
            req.setAttribute("prefilledAmount", String.format("%.2f", amountDue));
            loadCashierDashboardData(req);
            req.getRequestDispatcher("payment.jsp").forward(req, resp);
            return;
        }

        // 5. Build Payment object and persist
        Payment payment = new Payment(orderId, cashier.getUserId(), amount, method, reference);
        int generatedId = paymentDAO.insertPayment(payment);

        if (generatedId == -1) {
            req.setAttribute("error",
                "Payment could not be saved. Please try again.");
            loadCashierDashboardData(req);
            req.getRequestDispatcher("payment.jsp").forward(req, resp);
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        orderDAO.updateOrderStatus(orderId, "preparing");

        // 6. Trigger a notification for the student
        //    We need the student's user_id from the orders table.
        //    OrderDAO.getCustomerIdByOrder() supports notification delivery after payment.
        //    If that method is not yet available we use a safe fallback (no notification).
        try {
            int studentId = orderDAO.getCustomerIdByOrder(orderId);
            if (studentId > 0) {
                NotificationDAO notifDAO = new NotificationDAO();
                notifDAO.insertPaymentConfirmationNotification(
                    studentId, orderId, amount, method
                );
            }
        } catch (Exception e) {
            // Notification failure must NOT roll back the payment
            System.err.println("[PaymentServlet] Could not send notification: " + e.getMessage());
        }

        // 7. Success — redirect with success message passed as session attribute
        //    (using session avoids the message being lost on redirect)
        HttpSession session = req.getSession();
        session.setAttribute("paymentSuccess",
            "Payment of KES " + String.format("%.2f", amount)
          + " for Order #" + orderId + " was processed successfully. "
          + "Payment ID: #" + generatedId);

        resp.sendRedirect(req.getContextPath() + "/PaymentServlet");
    }

    // Private helper — show payment history (used by cashier dashboard)
    

    private void showPaymentHistory(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        PaymentDAO dao = new PaymentDAO();
        List<Payment> allPayments = dao.getAllPayments();
        req.setAttribute("paymentHistory", allPayments);
        loadCashierDashboardData(req);
        req.getRequestDispatcher("payment.jsp").forward(req, resp);
    }

    // Private helpers

    /** Retrieves the logged-in User from the session, or null if not logged in. */
    private User getSessionUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        Object obj = session.getAttribute("user");
        return (obj instanceof User) ? (User) obj : null;
    }

    /** Returns true only for cashier role. */
    private boolean isCashier(User user) {
        return user != null && "cashier".equals(user.getRole());
    }

    /** Trims a parameter value, returning empty string if null. */
    private String getValue(String param) {
        return param == null ? "" : param.trim();
    }

    private void populateFormState(HttpServletRequest req, String orderId, String amount,
                                   String method, String reference) {
        req.setAttribute("prefilledOrderId", orderId);
        req.setAttribute("prefilledAmount", amount);
        req.setAttribute("selectedMethod", method);
        req.setAttribute("transactionReference", reference);
    }

    private void loadCashierDashboardData(HttpServletRequest req) {
        PaymentDAO paymentDAO = new PaymentDAO();
        QueueDAO queueDAO = new QueueDAO();

        int paymentsToday = paymentDAO.countPaymentsToday();
        double revenueToday = paymentDAO.getTotalRevenueToday();

        req.setAttribute("paymentsToday", paymentsToday);
        req.setAttribute("revenueToday", revenueToday);
        req.setAttribute("cashPaymentsToday", paymentDAO.countPaymentsByMethodToday(Payment.METHOD_CASH));
        req.setAttribute("mobilePaymentsToday", paymentDAO.countPaymentsByMethodToday(Payment.METHOD_MOBILE_MONEY));
        req.setAttribute("averageTicketToday", paymentsToday == 0 ? 0.0 : revenueToday / paymentsToday);
        req.setAttribute("activeQueueCount", queueDAO.getActiveQueueCount());
        req.setAttribute("averageQueueWait", queueDAO.getAverageActiveWaitMinutes());
        req.setAttribute("nextQueueNumber", queueDAO.getNextQueueNumberPreview());
        req.setAttribute("queueOverview", queueDAO.getActiveQueueOverview(6));
        req.setAttribute("recentPayments", paymentDAO.getRecentPayments(5));
    }
}
