package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import model.Order;
import model.MenuItem;
import model.dao.OrderDAO;
import model.dao.MenuItemDAO;

public class OrderServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        
        // Get the logged-in user's ID (assuming it's stored in session after login)
        Integer customerId = (Integer) session.getAttribute("userId");
        
        if (customerId == null) {
            // User not logged in, redirect to login page
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        Map<Integer, Integer> cart = new HashMap<>();

        // Loop through all request parameters to get cart items
        Map<String, String[]> params = req.getParameterMap();

        for (String key : params.keySet()) {
            if (key.startsWith("qty_")) {
                int menuId = Integer.parseInt(key.replace("qty_", ""));
                int qty = Integer.parseInt(req.getParameter(key));

                if (qty > 0) {
                    cart.put(menuId, qty);
                }
            }
        }

        if (cart.isEmpty()) {
            resp.sendRedirect("menu.jsp");
            return;
        }

        // Calculate total amount (you need to fetch prices from database)
        double totalAmount = calculateTotalAmount(cart);
        
        // Create order object
        Order order = new Order();
        order.setCustomerId(customerId);
        order.setTotalAmount(totalAmount);
        
        // Save order to database and get the generated order ID
        OrderDAO orderDAO = new OrderDAO();
        int newOrderId = orderDAO.insertOrder(order);
        
        if (newOrderId > 0) {
            // Save order items to database (you'll need an OrderItemDAO for this)
            saveOrderItems(newOrderId, cart);
            
            // Store cart and order info in session
            session.setAttribute("cart", cart);
            session.setAttribute("lastOrderId", newOrderId);
            session.setAttribute("lastOrder", order);
            
            resp.sendRedirect("order.jsp");
        } else {
            // Failed to create order
            req.setAttribute("error", "Failed to place order. Please try again.");
            req.getRequestDispatcher("menu.jsp").forward(req, resp);
        }
    }
    
    private double calculateTotalAmount(Map<Integer, Integer> cart) {
        double total = 0.0;
        MenuItemDAO menuDAO = new MenuItemDAO();
        for (Map.Entry<Integer, Integer> entry : cart.entrySet()) {
            MenuItem item = menuDAO.getMenuItemById(entry.getKey());
            if (item != null) {
                total += item.getPrice() * entry.getValue();
            }
        }
        return total;
    }
    
    private void saveOrderItems(int orderId, Map<Integer, Integer> cart) {
        OrderDAO orderDAO = new OrderDAO();
        MenuItemDAO menuDAO = new MenuItemDAO();
        for (Map.Entry<Integer, Integer> entry : cart.entrySet()) {
            MenuItem item = menuDAO.getMenuItemById(entry.getKey());
            if (item != null) {
                double subtotal = item.getPrice() * entry.getValue();
                orderDAO.insertOrderItem(orderId, entry.getKey(), entry.getValue(), item.getPrice(), subtotal);
            }
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        HttpSession session = req.getSession();
        Integer customerId = (Integer) session.getAttribute("userId");
        
        if (customerId == null) {
            resp.sendRedirect("login.jsp");
            return;
        }
        
        String action = req.getParameter("action");
        
        if ("viewOrders".equals(action)) {
            // Get user's order history
            OrderDAO orderDAO = new OrderDAO();
            List<Order> userOrders = orderDAO.getOrdersByUser(customerId);
            req.setAttribute("userOrders", userOrders);
            req.getRequestDispatcher("orderHistory.jsp").forward(req, resp);
        } else {
            // Default: show current order
            resp.sendRedirect("order.jsp");
        }
    }
}