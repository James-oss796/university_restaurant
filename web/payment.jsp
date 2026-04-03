<!-- Member D (Payments & Notifications) should implement this file -->

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"cashier".equals(user.getRole())) {
        response.sendRedirect("LoginServlet");
        return;
    }
%>
<html>
<head>
    <title>Payment</title>
</head>
<body>
    <h2>Process Payment</h2>
    <form action="PaymentServlet" method="post">
        Amount: <input type="text" name="amount" required /><br/>
        Payment Method:
        <select name="paymentMethod">
            <option value="cash">Cash</option>
            <option value="mobile_money">Mobile Money</option>
        </select><br/>
        Transaction Reference (if mobile money): 
        <input type="text" name="transactionReference" /><br/>
        <input type="submit" value="Confirm Payment" />
    </form>

    <% if (request.getAttribute("error") != null) { %>
        <p style="color:red;"><%= request.getAttribute("error") %></p>
    <% } %>
</body>
</html>
