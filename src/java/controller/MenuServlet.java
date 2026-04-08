package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.MenuItem;
import model.User;
import model.dao.MenuItemDAO;

public class MenuServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;

        if (user == null || !"student".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        MenuItemDAO dao = new MenuItemDAO();
        List<MenuItem> items = dao.getAllMenuItems();
        req.setAttribute("menuItems", items);
        req.getRequestDispatcher("menu.jsp").forward(req, resp);
    }
}
