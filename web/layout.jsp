<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%
    User user = (User) session.getAttribute("user");
    String ctx = request.getContextPath();
%>
<%-- Shared navigation fragment – include this inside your <nav> element --%>
<% if (user != null) { %>
  <span style="color:#aaa;font-size:0.85rem">
    👤 <strong style="color:#F39C12"><%= user.getName() %></strong>
    &nbsp;(<%= user.getRole() %>)
  </span>

  <% if ("student".equals(user.getRole())) { %>
    <a href="<%= ctx %>/menu.jsp">Menu</a>
    <a href="<%= ctx %>/OrderServlet">Orders</a>
    <a href="<%= ctx %>/QueueServlet">Queue</a>
    <a href="<%= ctx %>/NotificationServlet">Notifications</a>
  <% } else if ("cashier".equals(user.getRole())) { %>
    <a href="<%= ctx %>/PaymentServlet">Payments</a>
  <% } else if ("admin".equals(user.getRole())) { %>
    <a href="<%= ctx %>/ReportServlet">Reports</a>
  <% } %>
  <a href="<%= ctx %>/LogoutServlet" class="btn btn-outline btn-sm">Logout</a>
<% } else { %>
  <a href="<%= ctx %>/LoginServlet" class="btn btn-outline btn-sm">Login</a>
  <a href="<%= ctx %>/RegisterServlet" class="btn btn-primary btn-sm">Sign Up</a>
<% } %>
