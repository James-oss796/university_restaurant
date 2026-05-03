// Member D (Payments & Notifications) - PaymentServlet.java
// Controller servlet that handles all payment-related HTTP requests.
//
// GET  /PaymentServlet          → show payment form (cashier view, optionally pre-filled with orderId)
// POST /PaymentServlet          → process payment form submission
// POST /PaymentServlet?action=history → cashier views payment history (all payments)
//
// Role requirement: Only users with role="cashier" may access this servlet.
// Students and admins are redirected to the login page.

package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

import model.Notification;
import model.Order;
import model.Payment;
import model.User;
import model.dao.NotificationDAO;
import model.dao.OrderDAO;
import model.dao.PaymentDAO;

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

        // 3. Determine active view (process vs history)
        String view = req.getParameter("view");
        if (view == null || view.isEmpty()) view = "process";
        req.setAttribute("activeView", view);

        if ("history".equals(view)) {
            // Fetch ALL payments for the History view
            PaymentDAO paymentDAO = new PaymentDAO();
            List<Payment> paymentHistory = paymentDAO.getAllPayments();
            req.setAttribute("paymentHistory", paymentHistory);
        } else {
            // Fetch pending orders for the Process view
            OrderDAO orderDAO = new OrderDAO();
            List<Order> pendingOrders = orderDAO.getPendingOrdersDetails();
            req.setAttribute("pendingOrders", pendingOrders);
        }

        // 4. Forward to payment.jsp
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

        // Validate: orderId is required
        if (orderIdStr.isEmpty()) {
            req.setAttribute("error", "Order ID is required.");
            req.getRequestDispatcher("payment.jsp").forward(req, resp);
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdStr);
            if (orderId <= 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Order ID must be a positive integer.");
            req.getRequestDispatcher("payment.jsp").forward(req, resp);
            return;
        }

        // Validate: amount is required and must be a positive number
        if (amountStr.isEmpty()) {
            req.setAttribute("error", "Amount is required.");
            req.setAttribute("prefilledOrderId", orderId);
            req.getRequestDispatcher("payment.jsp").forward(req, resp);
            return;
        }

        double amount;
        try {
            amount = Double.parseDouble(amountStr);
            if (amount <= 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Amount must be a positive number.");
            req.setAttribute("prefilledOrderId", orderId);
            req.getRequestDispatcher("payment.jsp").forward(req, resp);
            return;
        }

        // Validate: payment method must be "cash" or "mobile_money"
        if (!Payment.METHOD_CASH.equals(method) && !Payment.METHOD_MOBILE_MONEY.equals(method)) {
            req.setAttribute("error", "Please select a valid payment method.");
            req.setAttribute("prefilledOrderId", orderId);
            req.getRequestDispatcher("payment.jsp").forward(req, resp);
            return;
        }

        // Validate: mobile_money requires a transaction reference
        if (Payment.METHOD_MOBILE_MONEY.equals(method) && reference.isEmpty()) {
            req.setAttribute("error",
                "A transaction reference is required for Mobile Money payments.");
            req.setAttribute("prefilledOrderId", orderId);
            req.setAttribute("prefilledAmount", amountStr);
            req.setAttribute("selectedMethod", method);
            req.getRequestDispatcher("payment.jsp").forward(req, resp);
            return;
        }

        // 4. Prevent duplicate payments
        PaymentDAO paymentDAO = new PaymentDAO();
        if (paymentDAO.isOrderPaid(orderId)) {
            req.setAttribute("error",
                "Order #" + orderId + " has already been paid. "
              + "Please verify the order number.");
            req.getRequestDispatcher("payment.jsp").forward(req, resp);
            return;
        }

        // 5. Build Payment object and persist
        Payment payment = new Payment(orderId, cashier.getUserId(), amount, method, reference);
        int generatedId = paymentDAO.insertPayment(payment);

        if (generatedId == -1) {
            req.setAttribute("error",
                "Payment could not be saved. Please try again.");
            req.setAttribute("prefilledOrderId", orderId);
            req.setAttribute("prefilledAmount", amountStr);
            req.setAttribute("selectedMethod", method);
            req.getRequestDispatcher("payment.jsp").forward(req, resp);
            return;
        }

        // 5.5 Update Order Status to 'served' (Direct transition)
        try {
            OrderDAO orderDAO = new OrderDAO();
            orderDAO.updateOrderStatus(orderId, "served");
        } catch (Exception e) {
            System.err.println("[PaymentServlet] Could not update order status: " + e.getMessage());
        }

        // 6. Trigger a notification for the student
        //    We need the student's user_id from the orders table.
        //    OrderDAO.getCustomerIdByOrder() is suggested as an addition to Member C's DAO.
        //    If that method is not yet available we use a safe fallback (no notification).
        try {
            OrderDAO orderDAO = new OrderDAO();
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

        resp.sendRedirect(req.getContextPath() + "/payment.jsp");
    }

    // Private helper — show payment history (used by cashier dashboard)
    

    private void showPaymentHistory(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        PaymentDAO dao = new PaymentDAO();
        List<Payment> allPayments = dao.getAllPayments();
        req.setAttribute("paymentHistory", allPayments);
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
}
