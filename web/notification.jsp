<!-- Member D (Payments & Notifications) should implement this file -->

<%@ page import="java.util.List, model.Notification, model.User, model.dao.NotificationDAO" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"student".equals(user.getRole())) {
        response.sendRedirect("LoginServlet");
        return;
    }

    NotificationDAO dao = new NotificationDAO();
    List<Notification> notifications = dao.getNotificationsByUser(user.getUserId());
%>
<html>
<head>
    <title>Notifications</title>
</head>
<body>
    <h2>Your Notifications</h2>
    <ul>
        <% for(Notification n : notifications) { %>
            <li>
                <strong><%= n.getType() %></strong>: <%= n.getMessage() %> 
                (Sent at: <%= n.getSentAt() %>)
            </li>
        <% } %>
    </ul>
</body>
</html>
