<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.MenuItem" %>
<%@ page import="model.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null || !"student".equals(sessionUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }

    Map<Integer, Integer> cart = (Map<Integer, Integer>) session.getAttribute("cart");
    List<MenuItem> selectedItems = (List<MenuItem>) session.getAttribute("selectedItems");
    String errorMsg = (String) request.getAttribute("error");
    double cartTotal = session.getAttribute("cartTotal") instanceof Number
            ? ((Number) session.getAttribute("cartTotal")).doubleValue() : 0.0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Review | University Restaurant</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
</head>
<body>
    <jsp:include page="layout.jsp" />

    <main class="page-shell">
        <% if (cart == null || cart.isEmpty() || selectedItems == null || selectedItems.isEmpty()) { %>
            <section class="card">
                <h2 class="section-title">No Order Ready Yet</h2>
                <div class="empty-state">
                    Start from the menu, choose items, and your order summary will appear here.
                </div>
                <div class="actions">
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/MenuServlet">Back to Menu</a>
                </div>
            </section>
        <% } else { %>
            <section class="order-review-layout">
                <div class="card order-review-main">
                    <h2 class="section-title">Review Your Order</h2>
                    <p class="section-subtitle">Confirm the quantities and total below before placing the order.</p>

                    <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
                        <div class="alert alert-error"><%= errorMsg %></div>
                    <% } %>

                    <div class="card table-card">
                        <table>
                            <thead>
                                <tr>
                                    <th>Item</th>
                                    <th>Quantity</th>
                                    <th>Unit Price</th>
                                    <th>Subtotal</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (MenuItem item : selectedItems) {
                                       Integer quantity = cart.get(item.getMenuId());
                                       if (quantity != null) {
                                           pageContext.setAttribute("item", item);
                                           pageContext.setAttribute("qty", quantity);
                                %>
                                    <tr>
                                        <td><strong>${item.name}</strong></td>
                                        <td>${qty}</td>
                                        <td>KES <%= String.format("%.2f", item.getPrice()) %></td>
                                        <td class="price-tag">KES <%= String.format("%.2f", item.getPrice() * quantity) %></td>
                                    </tr>
                                <%     }
                                   }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <aside class="card order-review-side">
                    <h2 class="section-title">Order Total</h2>
                    <p class="section-subtitle">This summary is what will be saved when you place the order.</p>

                    <div class="summary-stat">
                        <span>Menu Items</span>
                        <strong><%= selectedItems.size() %></strong>
                    </div>
                    <div class="summary-stat total">
                        <span>Total Amount</span>
                        <strong>KES <%= String.format("%.2f", cartTotal) %></strong>
                    </div>
                    <div class="summary-stat">
                        <span>Queue Ticket</span>
                        <strong>Generated after order</strong>
                    </div>

                    <div class="actions actions-column">
                        <form action="${pageContext.request.contextPath}/QueueServlet" method="post">
                            <button class="btn btn-primary" type="submit">Place Order</button>
                        </form>
                        <a class="btn btn-light" href="${pageContext.request.contextPath}/MenuServlet">Back to Menu</a>
                    </div>
                </aside>
            </section>
        <% } %>
    </main>
</body>
</html>
