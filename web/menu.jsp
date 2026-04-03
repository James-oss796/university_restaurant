<!-- Member C (Orders & Queue Management) should implement this file -->

<%@ page import="java.util.List, model.MenuItem, model.User, model.dao.MenuItemDAO" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"student".equals(user.getRole())) {
        response.sendRedirect("LoginServlet");
        return;
    }

    MenuItemDAO dao = new MenuItemDAO();
    List<MenuItem> items = dao.getAllMenuItems();
%>
<html>
<head>
    <title>Menu</title>
</head>
<body>
    <h2>Available Menu</h2>
    <form action="OrderServlet" method="post">
        <table border="1">
            <tr>
                <th>Name</th><th>Description</th><th>Price</th><th>Meal Period</th><th>Select</th>
            </tr>
            <% for(MenuItem item : items) { %>
                <tr>
                    <td><%= item.getName() %></td>
                    <td><%= item.getDescription() %></td>
                    <td>$<%= item.getPrice() %></td>
                    <td><%= item.getMealPeriod() %></td>
                    <td>
                        <input type="checkbox" name="menuId" value="<%= item.getMenuId() %>" />
                    </td>
                </tr>
            <% } %>
        </table>
        <input type="submit" value="Place Order" />
    </form>
</body>
</html>
