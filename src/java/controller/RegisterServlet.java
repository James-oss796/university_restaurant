package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.PasswordUtil;
import model.User;
import model.dao.UserDAO;

public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String studentId = getValue(req.getParameter("studentId"));
        String name = getValue(req.getParameter("name"));
        String email = getValue(req.getParameter("email")).toLowerCase();
        String password = getValue(req.getParameter("password"));
        String role = getValue(req.getParameter("role")).toLowerCase();

        req.setAttribute("studentIdValue", studentId);
        req.setAttribute("nameValue", name);
        req.setAttribute("emailValue", email);
        req.setAttribute("roleValue", role);

        if (name.isEmpty() || email.isEmpty() || password.isEmpty() || role.isEmpty()) {
            req.setAttribute("error", "All fields are required.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        if (!"student".equals(role) && !"cashier".equals(role) && !"admin".equals(role)) {
            req.setAttribute("error", "Select a valid role.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            req.setAttribute("error", "Enter a valid email address.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        if (password.length() < 6) {
            req.setAttribute("error", "Password must be at least 6 characters.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        if ("student".equals(role) && studentId.isEmpty()) {
            req.setAttribute("error", "Student ID is required for student accounts.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        UserDAO dao = new UserDAO();
        if (dao.findByEmail(email) != null) {
            req.setAttribute("error", "That email is already registered.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        User newUser = new User();
        newUser.setStudentId(studentId);
        newUser.setName(name);
        newUser.setEmail(email);
        newUser.setPasswordHash(PasswordUtil.hashPassword(password));
        newUser.setRole(role);
        newUser.setActive(true);

        boolean success = dao.insertUser(newUser);

        if (success) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet?registered=1");
            return;
        }

        req.setAttribute("error", "Registration failed. Try again.");
        req.getRequestDispatcher("register.jsp").forward(req, resp);
    }

    private String getValue(String value) {
        return value == null ? "" : value.trim();
    }
}
