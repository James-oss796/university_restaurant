package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import model.MenuItem;
import model.User;
import model.dao.MenuItemDAO;

public class AdminMenuServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user == null || !"admin".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        MenuItemDAO dao = new MenuItemDAO();
        List<MenuItem> items = dao.getAllAdminMenuItems();

        req.setAttribute("menuItems", items);
        req.getRequestDispatcher("adminMenu.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
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

        String action = req.getParameter("action");
        MenuItemDAO dao = new MenuItemDAO();

        try {
            if ("add".equals(action)) {
                MenuItem item = new MenuItem();
                item.setName(req.getParameter("name"));
                item.setDescription(req.getParameter("description"));
                item.setPrice(Double.parseDouble(req.getParameter("price")));
                item.setMealPeriod(req.getParameter("meal_period"));
                item.setImageUrl(req.getParameter("image_url"));
                item.setAvailable(req.getParameter("is_available") != null);
                dao.insertMenuItem(item);
                req.getSession().setAttribute("successMsg", "Menu item added successfully!");

            } else if ("edit".equals(action)) {
                MenuItem item = new MenuItem();
                item.setMenuId(Integer.parseInt(req.getParameter("menu_id")));
                item.setName(req.getParameter("name"));
                item.setDescription(req.getParameter("description"));
                item.setPrice(Double.parseDouble(req.getParameter("price")));
                item.setMealPeriod(req.getParameter("meal_period"));
                item.setImageUrl(req.getParameter("image_url"));
                item.setAvailable(req.getParameter("is_available") != null);
                dao.updateMenuItem(item);
                req.getSession().setAttribute("successMsg", "Menu item updated successfully!");

            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("menu_id"));
                MenuItem item = dao.getMenuItemById(id);
                if (item != null) {
                    item.setAvailable(false);
                    dao.updateMenuItem(item);
                    req.getSession().setAttribute("successMsg", "Menu item marked as unavailable!");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "An error occurred while processing the menu item.");
        }

        resp.sendRedirect(req.getContextPath() + "/AdminMenuServlet");
    }
}
