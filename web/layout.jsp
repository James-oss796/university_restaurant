<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%
    User user = (User) session.getAttribute("user");
%>

<% if (user != null) { %>
    <p>Logged in as: <%= user.getName() %> (<%= user.getRole() %>)</p>

    <% if ("student".equals(user.getRole())) { %>
        <a href="menu.jsp">Menu</a>
        <a href="order.jsp">Orders</a>
        <a href="queue.jsp">Queue</a>
        <a href="notification.jsp">Notifications</a>
    <% } else if ("cashier".equals(user.getRole())) { %>
        <a href="payment.jsp">Payments</a>
    <% } else if ("admin".equals(user.getRole())) { %>
        <a href="report.jsp">Reports</a>
    <% } %>

    <a href="LogoutServlet">Logout</a>
<% } else { %>
    <a href="LoginServlet">Login</a>
    <a href="RegisterServlet">Register</a>
<% } %>
