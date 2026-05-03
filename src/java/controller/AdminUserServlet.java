package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.User;
import model.dao.UserDAO;
import model.PasswordUtil;

public class AdminUserServlet extends HttpServlet {

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

        UserDAO dao = new UserDAO();
        List<User> users = dao.getAllUsers();

        req.setAttribute("usersList", users);
        req.getRequestDispatcher("adminUsers.jsp").forward(req, resp);
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
        UserDAO dao = new UserDAO();

        try {
            if ("add".equals(action)) {
                User newUser = new User();
                newUser.setName(req.getParameter("name"));
                newUser.setEmail(req.getParameter("email"));
                newUser.setPhoneNumber(req.getParameter("phone_number"));
                newUser.setRole(req.getParameter("role"));
                newUser.setActive(req.getParameter("is_active") != null);
                
                String rawPassword = req.getParameter("password");
                newUser.setPasswordHash(PasswordUtil.hashPassword(rawPassword));

                dao.insertUser(newUser);
                req.getSession().setAttribute("successMsg", "User created successfully!");

            } else if ("edit".equals(action)) {
                int targetUserId = Integer.parseInt(req.getParameter("user_id"));
                
                // We need to fetch the user first to keep the password intact unless we're updating it
                List<User> allUsers = dao.getAllUsers();
                User targetUser = null;
                for (User u : allUsers) {
                    if (u.getUserId() == targetUserId) {
                        targetUser = u;
                        break;
                    }
                }
                
                if (targetUser != null) {
                    targetUser.setName(req.getParameter("name"));
                    targetUser.setEmail(req.getParameter("email"));
                    targetUser.setPhoneNumber(req.getParameter("phone_number"));
                    targetUser.setRole(req.getParameter("role"));
                    targetUser.setActive(req.getParameter("is_active") != null);
                    
                    dao.updateUser(targetUser);
                    req.getSession().setAttribute("successMsg", "User updated successfully!");
                }

            } else if ("deactivate".equals(action)) {
                int targetUserId = Integer.parseInt(req.getParameter("user_id"));
                List<User> allUsers = dao.getAllUsers();
                User targetUser = null;
                for (User u : allUsers) {
                    if (u.getUserId() == targetUserId) {
                        targetUser = u;
                        break;
                    }
                }
                
                if (targetUser != null && targetUserId != user.getUserId()) { // prevent self-deactivation
                    targetUser.setActive(false);
                    dao.updateUser(targetUser);
                    req.getSession().setAttribute("successMsg", "User deactivated successfully!");
                }
            } else if ("activate".equals(action)) {
                int targetUserId = Integer.parseInt(req.getParameter("user_id"));
                List<User> allUsers = dao.getAllUsers();
                User targetUser = null;
                for (User u : allUsers) {
                    if (u.getUserId() == targetUserId) {
                        targetUser = u;
                        break;
                    }
                }
                
                if (targetUser != null) {
                    targetUser.setActive(true);
                    dao.updateUser(targetUser);
                    req.getSession().setAttribute("successMsg", "User activated successfully!");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "An error occurred while processing the user.");
        }

        resp.sendRedirect(req.getContextPath() + "/AdminUserServlet");
    }
}
