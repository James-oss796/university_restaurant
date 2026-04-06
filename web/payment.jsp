<%-- Member D (Payments & Notifications) - notification.jsp
     Student notification inbox.

     Access: student role only. Redirect to login if not a student.

     Data flow:
       GET /NotificationServlet → fetches notifications → forwards here
           (Servlet sets request attribute "notifications" and "unreadCount")

     Alternatively, if the page is accessed directly (without going through
     the servlet), it fetches the data itself as a fallback.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List, java.util.ArrayList, model.Notification, model.User, model.dao.NotificationDAO" %>
<%
    /* ── Session guard ─────────────────────────────────────────────── */
    User user = (User) session.getAttribute("user");
    if (user == null || !"student".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }

    /* ── Fetch notifications if not already loaded by servlet ───────── */
    List<Notification> notifications =
        (List<Notification>) request.getAttribute("notifications");

    if (notifications == null) {
        // Fallback: page accessed directly (not via servlet)
        NotificationDAO dao = new NotificationDAO();
        notifications = dao.getNotificationsByUser(user.getUserId());
        // Mark all as read since the student is viewing them
        dao.markAllAsRead(user.getUserId());
    }

    /* ── Count unread for display ──────────────────────────────────── */
    int unreadCount = 0;
    for (Notification n : notifications) {
        if (!n.isRead()) unreadCount++;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Notifications – University Restaurant</title>
    <style>
        /* ── Base ─────────────────────────────────────────── */
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body   { font-family: Arial, Helvetica, sans-serif; background: #f4f6f8; color: #333; }
        header { background: #2c3e50; color: #fff; padding: 14px 24px; display: flex;
                 align-items: center; justify-content: space-between; }
        header h1 { font-size: 1.2rem; }
        header nav a { color: #ecf0f1; text-decoration: none; margin-left: 18px;
                       font-size: 0.9rem; }
        header nav a:hover { text-decoration: underline; }

        .page-wrap { max-width: 800px; margin: 32px auto; padding: 0 16px; }

        /* ── Card ────────────────────────────────────────── */
        .card { background: #fff; border-radius: 8px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.10); padding: 28px 32px; }
        .card-header { display: flex; align-items: center; justify-content: space-between;
                       margin-bottom: 20px; border-bottom: 2px solid #3498db;
                       padding-bottom: 10px; }
        .card-header h2 { font-size: 1.3rem; color: #2c3e50; }
        .badge-count { background: #e74c3c; color: #fff; border-radius: 12px;
                       padding: 3px 9px; font-size: 0.82rem; font-weight: bold; }

        /* ── Buttons ──────────────────────────────────────── */
        .btn { display: inline-block; padding: 8px 18px; border: none; border-radius: 5px;
               cursor: pointer; font-size: 0.88rem; text-decoration: none; }
        .btn-outline { background: transparent; border: 1px solid #3498db; color: #3498db; }
        .btn-outline:hover { background: #3498db; color: #fff; }
        .btn-sm { padding: 5px 12px; font-size: 0.8rem; }

        /* ── Notification items ───────────────────────────── */
        .notif-list { list-style: none; }
        .notif-item {
            display: flex; align-items: flex-start; gap: 14px;
            padding: 14px 0; border-bottom: 1px solid #f0f0f0;
            transition: background .15s;
        }
        .notif-item:last-child { border-bottom: none; }
        .notif-item.unread { background: #eaf4fb; border-radius: 6px;
                             padding-left: 10px; padding-right: 10px; }

        /* Icon circle */
        .notif-icon {
            flex-shrink: 0; width: 40px; height: 40px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.1rem;
        }
        .notif-order  .notif-icon { background: #d4edda; }
        .notif-queue  .notif-icon { background: #cce5ff; }
        .notif-promo  .notif-icon { background: #fff3cd; }
        .notif-default .notif-icon { background: #e2e3e5; }

        /* Text block */
        .notif-body { flex: 1; }
        .notif-message { font-size: 0.95rem; line-height: 1.45; }
        .notif-meta { font-size: 0.78rem; color: #888; margin-top: 4px; }
        .notif-meta .type-label {
            display: inline-block; padding: 2px 8px; border-radius: 10px;
            font-size: 0.72rem; font-weight: bold; margin-right: 6px;
        }
        .notif-order .type-label { background: #d4edda; color: #155724; }
        .notif-queue .type-label { background: #cce5ff; color: #004085; }
        .notif-promo .type-label { background: #fff3cd; color: #856404; }
        .notif-default .type-label { background: #e2e3e5; color: #555; }

        /* Unread dot */
        .unread-dot { width: 8px; height: 8px; border-radius: 50%;
                      background: #3498db; flex-shrink: 0; margin-top: 6px; }

        /* Empty state */
        .empty-state { text-align: center; padding: 48px 0; color: #aaa; }
        .empty-state .emoji { font-size: 2.5rem; display: block; margin-bottom: 12px; }

        footer { text-align: center; padding: 18px; color: #888; font-size: 0.8rem;
                 margin-top: 24px; }
    </style>
</head>
<body>

<!-- ── Header / Nav ─────────────────────────────────────────────────── -->
<header>
    <h1>🏫 University Restaurant System</h1>
    <nav>
        <a href="<%= request.getContextPath() %>/menu.jsp">Menu</a>
        <a href="<%= request.getContextPath() %>/order.jsp">My Orders</a>
        <a href="<%= request.getContextPath() %>/queue.jsp">Queue</a>
        <a href="<%= request.getContextPath() %>/NotificationServlet">🔔 Notifications</a>
        <%@ include file="layout.jsp" %>
    </nav>
</header>

<div class="page-wrap">
    <div class="card">

        <!-- ── Card header with unread badge ──────────────────────── -->
        <div class="card-header">
            <h2>🔔 Your Notifications</h2>
            <div>
                <% if (unreadCount > 0) { %>
                    <span class="badge-count"><%= unreadCount %> unread</span>
                <% } %>

                <% if (!notifications.isEmpty()) { %>
                    <form action="<%= request.getContextPath() %>/NotificationServlet"
                          method="post" style="display:inline; margin-left:10px">
                        <input type="hidden" name="action" value="markAllRead" />
                        <button type="submit" class="btn btn-outline btn-sm">
                            ✔ Mark all as read
                        </button>
                    </form>
                <% } %>
            </div>
        </div>

        <!-- ── Notification list ──────────────────────────────────── -->
        <% if (notifications.isEmpty()) { %>
            <div class="empty-state">
                <span class="emoji">📭</span>
                <p>No notifications yet.</p>
                <p style="font-size:0.85rem; margin-top:6px">
                    Notifications will appear here when your order status changes,
                    a payment is confirmed, or there are promotions.
                </p>
            </div>
        <% } else { %>
            <ul class="notif-list">
                <% for (Notification n : notifications) {
                       String cssClass = n.getTypeCssClass();
                       String iconEmoji;
                       switch (n.getType() == null ? "" : n.getType()) {
                           case Notification.TYPE_ORDER_STATUS: iconEmoji = "🍽️"; break;
                           case Notification.TYPE_QUEUE_UPDATE: iconEmoji = "🔢"; break;
                           case Notification.TYPE_PROMOTION:    iconEmoji = "🎉"; break;
                           default:                             iconEmoji = "📢"; break;
                       }
                %>
                <li class="notif-item <%= cssClass %> <%= !n.isRead() ? "unread" : "" %>">

                    <!-- Unread indicator dot -->
                    <% if (!n.isRead()) { %>
                        <div class="unread-dot" title="Unread"></div>
                    <% } else { %>
                        <div style="width:8px; flex-shrink:0;"></div>
                    <% } %>

                    <!-- Icon -->
                    <div class="notif-icon"><%= iconEmoji %></div>

                    <!-- Body -->
                    <div class="notif-body">
                        <p class="notif-message"><%= n.getMessage() %></p>
                        <p class="notif-meta">
                            <span class="type-label"><%= n.getTypeLabel() %></span>
                            <% if (n.getOrderId() > 0) { %>
                                Order #<%= n.getOrderId() %> &bull;
                            <% } %>
                            <%= n.getSentAt() != null ? n.getSentAt() : "" %>
                        </p>
                    </div>

                    <!-- Mark as read button (only for unread) -->
                    <% if (!n.isRead()) { %>
                        <form action="<%= request.getContextPath() %>/NotificationServlet"
                              method="post">
                            <input type="hidden" name="action" value="markRead" />
                            <input type="hidden" name="id" value="<%= n.getNotificationId() %>" />
                            <button type="submit" class="btn btn-sm btn-outline"
                                    title="Mark as read">✔</button>
                        </form>
                    <% } %>

                </li>
                <% } %>
            </ul>
        <% } %>

    </div><!-- /.card -->
</div><!-- /.page-wrap -->

<footer>&copy; 2026 University Restaurant Management System</footer>
</body>
</html>
