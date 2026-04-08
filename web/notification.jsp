<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Notification" %>
<%@ page import="model.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null || !"student".equals(sessionUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }

    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
    if (notifications == null) {
        response.sendRedirect(request.getContextPath() + "/NotificationServlet");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notifications | University Restaurant</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
</head>
<body>
    <jsp:include page="layout.jsp" />

    <main class="page-shell stack">
        <section class="card">
            <div style="display:flex; align-items:center; justify-content:space-between; gap:12px; flex-wrap:wrap; margin-bottom:18px;">
                <div>
                    <h2 class="section-title">Your Notifications</h2>
                    <p class="section-subtitle">Updates about queue position, payment confirmation, and order status.</p>
                </div>

                <% if (!notifications.isEmpty()) { %>
                    <form action="${pageContext.request.contextPath}/NotificationServlet" method="post">
                        <input type="hidden" name="action" value="markAllRead">
                        <button type="submit" class="btn btn-light">Mark All Read</button>
                    </form>
                <% } %>
            </div>

            <% if (notifications.isEmpty()) { %>
                <div class="empty-state">
                    No notifications yet. This page will show queue and payment updates when they are available.
                </div>
            <% } else { %>
                <div class="stack">
                    <% for (Notification notification : notifications) {
                           pageContext.setAttribute("notification", notification);
                    %>
                        <div class="card" style="padding:18px 20px;">
                            <div style="display:flex; justify-content:space-between; gap:14px; align-items:flex-start; flex-wrap:wrap;">
                                <div>
                                    <p style="margin:0 0 8px; font-weight:700; color:#163f5e;">
                                        ${notification.typeLabel}
                                    </p>
                                    <p style="margin:0 0 8px; line-height:1.6;">${notification.message}</p>
                                    <p class="hint" style="margin:0;">
                                        <% if (notification.getOrderId() > 0) { %>
                                            Order #${notification.orderId}
                                        <% } %>
                                        <% if (notification.getOrderId() > 0 && notification.getSentAt() != null && !notification.getSentAt().isEmpty()) { %>
                                            -
                                        <% } %>
                                        ${notification.sentAt}
                                    </p>
                                </div>

                                <% if (!notification.isRead()) { %>
                                    <form action="${pageContext.request.contextPath}/NotificationServlet" method="post">
                                        <input type="hidden" name="action" value="markRead">
                                        <input type="hidden" name="id" value="${notification.notificationId}">
                                        <button type="submit" class="btn btn-primary">Mark Read</button>
                                    </form>
                                <% } %>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </section>
    </main>
</body>
</html>
