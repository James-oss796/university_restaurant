<!-- Member C (Orders & Queue Management) should implement this file -->

<%@ page import="java.util.Map, java.util.Map.Entry, model.MenuItem, model.User, model.dao.MenuItemDAO" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"student".equals(user.getRole())) {
        response.sendRedirect("LoginServlet");
        return;
    }

    Map<Integer, Integer> cart = (Map<Integer, Integer>) session.getAttribute("cart");
    MenuItemDAO dao = new MenuItemDAO();
%>
<html>
<head>
    <title>Order Review</title>
</head>
<body>
    <h2>Your Cart</h2>
    <table border="1">
        <tr>
            <th>Item</th><th>Quantity</th><th>Price</th><th>Subtotal</th>
        </tr>
        <%
        double total = 0;
        if (cart != null) {
            for (Entry<Integer, Integer> entry : cart.entrySet()) {
                MenuItem item = dao.getAllMenuItems().stream()
                                   .filter(m -> m.getMenuId() == entry.getKey())
                                   .findFirst().orElse(null);
                if (item != null) {
                    int qty = entry.getValue();
                    double subtotal = qty * item.getPrice();
                    total += subtotal;
        %>
        <tr>
            <td><%= item.getName() %></td>
            <td><%= qty %></td>
            <td>$<%= item.getPrice() %></td>
            <td>$<%= subtotal %></td>
        </tr>
        <%
                }
            }
        }
        %>
        <tr>
            <td colspan="3"><strong>Total</strong></td>
            <td><strong>$<%= total %></strong></td>
        </tr>
    </table>

    <form action="QueueServlet" method="post">
        <input type="submit" value="Checkout & Assign Queue" />
    </form>
</body>
</html>
