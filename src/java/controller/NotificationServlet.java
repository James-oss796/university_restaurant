package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

import model.Notification;
import model.User;
import model.dao.NotificationDAO;

/**
 * NotificationServlet — handles student notification page requests.
 *
 * GET:
 *   - Fetches all notifications for the logged-in student.
 *   - Automatically marks all as read when the page is visited.
 *   - Forwards to notification.jsp with the list as request attribute.
 *
 * POST (action=markRead):
 *   - Marks a single notification as read by notification_id.
 *   - Redirects back to GET.
 *
 * POST (action=markAllRead):
 *   - Marks all notifications for the current user as read.
 *   - Redirects back to GET.
 */
public class NotificationServlet extends HttpServlet {

    // GET — fetch and display notifications

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // 1. Enforce student-only access
        User user = getSessionUser(req);
        if (!isStudent(user)) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        // 2. Fetch all notifications for this student
        NotificationDAO dao = new NotificationDAO();
        List<Notification> notifications = dao.getNotificationsByUser(user.getUserId());

        // 3. Auto-mark all as read when the page is opened
        //    (keeps the unread badge at 0 after the student views the page)
        dao.markAllAsRead(user.getUserId());

        // 4. Attach data to request and forward
        req.setAttribute("notifications", notifications);
        req.setAttribute("unreadCount", 0); // page was just opened; all are now read
        req.getRequestDispatcher("notification.jsp").forward(req, resp);
    }

    // POST — mark-read actions

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        // 1. Enforce student-only access
        User user = getSessionUser(req);
        if (!isStudent(user)) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        String action = getValue(req.getParameter("action"));
        NotificationDAO dao = new NotificationDAO();

        if ("markRead".equals(action)) {
            // Mark a single notification as read
            String idParam = getValue(req.getParameter("id"));
            try {
                int notifId = Integer.parseInt(idParam);
                dao.markAsRead(notifId);
            } catch (NumberFormatException e) {
                // Invalid id — ignore silently and redirect
            }

        } else if ("markAllRead".equals(action)) {
            // Mark all notifications for this user as read
            dao.markAllAsRead(user.getUserId());
        }

        // Redirect to GET (Post-Redirect-Get pattern prevents form re-submission)
        resp.sendRedirect(req.getContextPath() + "/NotificationServlet");
    }

    // Private helpers

    private User getSessionUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        Object obj = session.getAttribute("user");
        return (obj instanceof User) ? (User) obj : null;
    }

    private boolean isStudent(User user) {
        return user != null && "student".equals(user.getRole());
    }

    private String getValue(String param) {
        return param == null ? "" : param.trim();
    }
}
