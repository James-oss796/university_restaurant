package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.MenuItem;
import model.User;
import model.dao.MenuItemDAO;

public class OrderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = getStudentUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        req.getRequestDispatcher("order.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        User user = getStudentUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        Map<Integer, Integer> cart = new LinkedHashMap<>();
        Map<String, String[]> params = req.getParameterMap();

        for (String key : params.keySet()) {
            if (!key.startsWith("qty_")) {
                continue;
            }

            int menuId;
            int quantity;
            try {
                menuId = Integer.parseInt(key.substring(4));
                quantity = Integer.parseInt(getValue(req.getParameter(key)));
            } catch (NumberFormatException e) {
                forwardBackToMenu(req, resp, "Quantities must be whole numbers.");
                return;
            }

            if (menuId <= 0 || quantity < 0) {
                forwardBackToMenu(req, resp, "Enter valid positive quantities for menu items.");
                return;
            }

            if (quantity > 0) {
                cart.put(menuId, quantity);
            }
        }

        if (cart.isEmpty()) {
            forwardBackToMenu(req, resp, "Select at least one menu item before reviewing your order.");
            return;
        }

        MenuItemDAO menuItemDAO = new MenuItemDAO();
        Map<Integer, MenuItem> itemsById = menuItemDAO.getMenuItemsByIds(cart.keySet());
        if (itemsById.size() != cart.size()) {
            forwardBackToMenu(req, resp, "One or more selected menu items are unavailable. Please choose again.");
            return;
        }

        List<MenuItem> selectedItems = new ArrayList<>();
        double cartTotal = 0;
        for (Map.Entry<Integer, Integer> entry : cart.entrySet()) {
            MenuItem item = itemsById.get(entry.getKey());
            if (item == null || !item.isAvailable()) {
                forwardBackToMenu(req, resp, "One or more selected menu items are unavailable. Please choose again.");
                return;
            }

            selectedItems.add(item);
            cartTotal += item.getPrice() * entry.getValue();
        }

        session.setAttribute("cart", cart);
        session.setAttribute("selectedItems", selectedItems);
        session.setAttribute("cartTotal", cartTotal);
        session.removeAttribute("lastOrderId");
        session.removeAttribute("queueNumber");
        session.removeAttribute("queuePosition");
        session.removeAttribute("estimatedWaitMinutes");
        session.removeAttribute("lastOrderTotal");

        resp.sendRedirect(req.getContextPath() + "/OrderServlet");
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

    private void forwardBackToMenu(HttpServletRequest req, HttpServletResponse resp, String errorMessage)
            throws ServletException, IOException {
        req.setAttribute("error", errorMessage);
        req.setAttribute("menuItems", new MenuItemDAO().getAllMenuItems());
        req.getRequestDispatcher("menu.jsp").forward(req, resp);
    }

    private String getValue(String value) {
        return value == null ? "" : value.trim();
    }
}
