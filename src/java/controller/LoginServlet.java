package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.PasswordUtil;
import model.User;
import model.dao.UserDAO;

public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            redirectByRole((User) session.getAttribute("user"), req, resp);
            return;
        }

        if ("1".equals(req.getParameter("registered"))) {
            req.setAttribute("message", "Registration successful. Please log in.");
        }

        if ("1".equals(req.getParameter("logout"))) {
            req.setAttribute("message", "You have logged out successfully.");
        }

        req.getRequestDispatcher("login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String email = getValue(req.getParameter("email")).toLowerCase();
        String password = getValue(req.getParameter("password"));
        req.setAttribute("emailValue", email);

        if (email.isEmpty() || password.isEmpty()) {
            req.setAttribute("error", "Email and password are required.");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
            return;
        }

        UserDAO dao = new UserDAO();
        User user = dao.findByEmail(email);

        if (user == null || !PasswordUtil.matches(password, user.getPasswordHash())) {
            req.setAttribute("error", "Invalid email or password.");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
            return;
        }

        if (!user.isActive()) {
            req.setAttribute("error", "This account is inactive.");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
            return;
        }

        user.setPasswordHash(null);

        HttpSession session = req.getSession();
        session.setAttribute("user", user);
        session.setMaxInactiveInterval(30 * 60);

        redirectByRole(user, req, resp);
    }

    private String getValue(String value) {
        return value == null ? "" : value.trim();
    }

    private void redirectByRole(User user, HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String contextPath = req.getContextPath();

        if ("student".equals(user.getRole())) {
            resp.sendRedirect(contextPath + "/menu.jsp");
            return;
        }
        if ("cashier".equals(user.getRole())) {
            resp.sendRedirect(contextPath + "/payment.jsp");
            return;
        }
        if ("admin".equals(user.getRole())) {
            resp.sendRedirect(contextPath + "/report.jsp");
            return;
        }

        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        resp.sendRedirect(contextPath + "/LoginServlet");
    }
}
