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

    private static final String NAME_PATTERN = "^[A-Za-z][A-Za-z .'-]*$";
    private static final String PHONE_PATTERN = "^\\+?[0-9]{10,15}$";
    private static final String EMAIL_PATTERN = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$";
    private static final String STUDENT_ID_PATTERN = "^[A-Za-z0-9/_-]{4,20}$";
    private static final String PASSWORD_PATTERN = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$";

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
        String phoneNumber = getValue(req.getParameter("phoneNumber"));
        String email = getValue(req.getParameter("email")).toLowerCase();
        String password = getValue(req.getParameter("password"));
        String role = getValue(req.getParameter("role")).toLowerCase();

        req.setAttribute("studentIdValue", studentId);
        req.setAttribute("nameValue", name);
        req.setAttribute("phoneNumberValue", phoneNumber);
        req.setAttribute("emailValue", email);
        req.setAttribute("roleValue", role);

        if (name.isEmpty() || phoneNumber.isEmpty() || email.isEmpty() || password.isEmpty() || role.isEmpty()) {
            req.setAttribute("error", "All required fields must be filled.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        if (!name.matches(NAME_PATTERN)) {
            req.setAttribute("error", "Full name must contain letters only. Numbers are not allowed.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        if (!"student".equals(role) && !"cashier".equals(role) && !"admin".equals(role)) {
            req.setAttribute("error", "Select a valid role.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        if (!"student".equals(role)) {
            studentId = "";
            req.setAttribute("studentIdValue", "");
        }

        if (!phoneNumber.matches(PHONE_PATTERN)) {
            req.setAttribute("error", "Enter a valid phone number with 10 to 15 digits.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        if (!email.matches(EMAIL_PATTERN)) {
            req.setAttribute("error", "Enter a valid email address that includes @.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        if (!password.matches(PASSWORD_PATTERN)) {
            req.setAttribute("error", "Password must be at least 8 characters and include uppercase, lowercase, and a number.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        if ("student".equals(role) && studentId.isEmpty()) {
            req.setAttribute("error", "Student ID is required for student accounts.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        if (!studentId.isEmpty() && !studentId.matches(STUDENT_ID_PATTERN)) {
            req.setAttribute("error", "Student ID may only contain letters, numbers, /, _, and -.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        UserDAO dao = new UserDAO();
        if (dao.findByEmail(email) != null) {
            req.setAttribute("error", "That email is already registered.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        if (dao.hasError()) {
            log("Registration lookup failed: " + dao.getLastErrorMessage());
            req.setAttribute("error", dao.getLastErrorMessage());
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        User newUser = new User();
        newUser.setStudentId(studentId);
        newUser.setName(name);
        newUser.setPhoneNumber(phoneNumber);
        newUser.setEmail(email);
        newUser.setPasswordHash(PasswordUtil.hashPassword(password));
        newUser.setRole(role);
        newUser.setActive(true);

        boolean success = dao.insertUser(newUser);

        if (success) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet?registered=1");
            return;
        }

        if (dao.hasError()) {
            log("Registration insert failed: " + dao.getLastErrorMessage());
            req.setAttribute("error", dao.getLastErrorMessage());
        } else {
            req.setAttribute("error", "Registration failed. Try again.");
        }
        req.getRequestDispatcher("register.jsp").forward(req, resp);
    }

    private String getValue(String value) {
        return value == null ? "" : value.trim();
    }
}
