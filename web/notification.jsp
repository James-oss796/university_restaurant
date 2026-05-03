<%-- notification.jsp – Student notification inbox --%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List, java.util.ArrayList, model.Notification, model.User, model.dao.NotificationDAO" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"student".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
    if (notifications == null) {
        NotificationDAO dao = new NotificationDAO();
        notifications = dao.getNotificationsByUser(user.getUserId());
        dao.markAllAsRead(user.getUserId());
    }
    int unreadCount = 0;
    for (Notification n : notifications) { if (!n.isRead()) unreadCount++; }
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Notifications – UniEats</title>
  <link rel="preload" as="style" href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;900&family=Nunito:wght@400;600;700;800&display=swap" onload="this.rel='stylesheet'" />
  <noscript><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;900&family=Nunito:wght@400;600;700;800&display=swap" /></noscript>
  <link rel="stylesheet" href="<%= ctx %>/css/styles.css" />
  <style>
    .notif-item { display:flex;gap:16px;align-items:flex-start;padding:18px 20px;border-bottom:1px solid #f0ece6;transition:background .2s; }
    .notif-item:last-child { border-bottom:none; }
    .notif-item.unread { background:#fff8f0;border-left:4px solid var(--red); }
    .notif-item:hover { background:var(--cream); }
    .notif-icon { width:40px;height:40px;border-radius:50%;background:linear-gradient(135deg,var(--red),var(--orange));display:flex;align-items:center;justify-content:center;font-size:1.1rem;flex-shrink:0; }
    .notif-item.unread .notif-icon { background:linear-gradient(135deg,var(--amber),var(--yellow)); }
    .notif-title { font-weight:700;color:var(--dark);margin-bottom:4px;font-size:.95rem; }
    .notif-msg   { font-size:.875rem;color:var(--mid); }
    .notif-time  { font-size:.75rem;color:#aaa;margin-top:6px; }
    .notif-badge { display:inline-block;background:var(--red);color:white;font-size:.7rem;font-weight:800;padding:2px 8px;border-radius:50px;margin-left:8px;vertical-align:middle; }
    .empty-state { text-align:center;padding:60px 24px;color:var(--mid); }
  </style>
</head>
<body>
<nav class="navbar">
  <a class="navbar-brand" href="<%= ctx %>/"><div class="logo-icon">🍗</div><div class="logo-text">Uni<span>Eats</span></div></a>
  <ul class="navbar-links">
    <li><a href="<%= ctx %>/">Home</a></li>
    <li><a href="<%= ctx %>/menu.jsp">Menu</a></li>
    <li><a href="<%= ctx %>/OrderServlet">My Orders</a></li>
    <li><a href="<%= ctx %>/QueueServlet">Queue</a></li>
    <li><a href="<%= ctx %>/NotificationServlet" class="active">Notifications<% if(unreadCount>0){%><span class="notif-badge"><%= unreadCount %></span><%}%></a></li>
  </ul>
  <div class="navbar-user">
    <span>👤 <span class="user-name"><%= user.getName() %></span></span>
    <a href="<%= ctx %>/LogoutServlet" class="btn btn-outline btn-sm">Logout</a>
  </div>
</nav>
<div class="page-wrap"><div class="container" style="max-width:800px">
  <div class="page-header"><h1>🔔 Notifications</h1><p><% if(unreadCount>0){%><%= unreadCount %> unread<%}else{%>All caught up!<%}%></p></div>
  <div class="table-wrap">
    <% if(notifications==null||notifications.isEmpty()){%>
      <div class="empty-state"><div style="font-size:3rem">📭</div><h3 style="font-family:'Playfair Display',serif;margin:12px 0">No Notifications Yet</h3><p>Place an order and we'll update you here.</p><a href="<%= ctx %>/menu.jsp" class="btn btn-primary" style="margin-top:20px">Browse Menu</a></div>
    <%}else{for(Notification n:notifications){boolean unread=!n.isRead();%>
      <div class="notif-item <%= unread?"unread":"" %>">
        <div class="notif-icon"><%= unread?"🔔":"✔" %></div>
        <div>
          <div class="notif-title"><%= n.getTitle()!=null?n.getTitle():"Order Update" %><% if(unread){%><span class="notif-badge">NEW</span><%}%></div>
          <div class="notif-msg"><%= n.getMessage() %></div>
          <div class="notif-time"><%= n.getCreatedAt()!=null?n.getCreatedAt().toString():"" %></div>
        </div>
      </div>
    <%}}%>
  </div>
</div></div>
<footer class="footer"><p>&copy; 2025 <span>UniEats University Restaurant</span></p></footer>
</body></html>
