<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="model.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null || !"student".equals(sessionUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }

    Object displayQueueNumber = request.getAttribute("queueNumber") != null ? request.getAttribute("queueNumber") : session.getAttribute("queueNumber");
    Object displayOrderId = request.getAttribute("lastOrderId") != null ? request.getAttribute("lastOrderId") : session.getAttribute("lastOrderId");
    Object displayQueuePosition = request.getAttribute("queuePosition") != null ? request.getAttribute("queuePosition") : session.getAttribute("queuePosition");
    Object displayEstimatedWaitMinutes = request.getAttribute("estimatedWaitMinutes") != null ? request.getAttribute("estimatedWaitMinutes") : session.getAttribute("estimatedWaitMinutes");
    Object displayLastOrderTotal = request.getAttribute("lastOrderTotal") != null ? request.getAttribute("lastOrderTotal") : session.getAttribute("lastOrderTotal");
    Object displayOrderStatus = request.getAttribute("orderStatus") != null ? request.getAttribute("orderStatus") : "pending";

    pageContext.setAttribute("displayQueueNumber", displayQueueNumber);
    pageContext.setAttribute("displayOrderId", displayOrderId);
    pageContext.setAttribute("displayQueuePosition", displayQueuePosition);
    pageContext.setAttribute("displayEstimatedWaitMinutes", displayEstimatedWaitMinutes);
    pageContext.setAttribute("displayLastOrderTotal", displayLastOrderTotal);
    pageContext.setAttribute("displayOrderStatus", displayOrderStatus);

    double orderTotal = displayLastOrderTotal instanceof Number ? ((Number) displayLastOrderTotal).doubleValue() : 0.0;
    int queuePosition = displayQueuePosition instanceof Number ? ((Number) displayQueuePosition).intValue() : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Queue Status | University Restaurant</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
</head>
<body>
    <jsp:include page="layout.jsp" />

    <main class="page-shell stack">
        <% if (displayOrderId != null) { %>
            <section class="card">
                <h2 class="section-title">Your Order Is In The Queue</h2>
                <p class="section-subtitle">Keep this screen or note the queue number for payment and pickup. Waiting time updates from the current unpaid line.</p>

                <div class="metrics">
                    <article class="metric">
                        <p class="metric-label">Queue Number</p>
                        <p class="metric-value"><%= displayQueueNumber != null ? displayQueueNumber : "Pending" %></p>
                    </article>
                    <article class="metric">
                        <p class="metric-label">Order ID</p>
                        <p class="metric-value">${displayOrderId}</p>
                    </article>
                    <article class="metric">
                        <p class="metric-label">Position</p>
                        <p class="metric-value"><%= queuePosition > 0 ? displayQueuePosition : "Paid" %></p>
                    </article>
                    <article class="metric">
                        <p class="metric-label">Est. Wait</p>
                        <p class="metric-value">${displayEstimatedWaitMinutes} min</p>
                    </article>
                </div>

                <% if (request.getAttribute("activeQueueCount") != null) { %>
                    <p class="queue-live-note">
                        <strong>${requestScope.activeQueueCount}</strong> active payment ticket(s) are currently in line.
                    </p>
                <% } %>

                <div class="card" style="margin-top: 24px;">
                    <h3 class="section-title" style="font-size: 1.2rem;">Order Summary</h3>
                    <p><strong>Order ID:</strong> ${displayOrderId}</p>
                    <p><strong>Total Amount:</strong> KES <%= String.format("%.2f", orderTotal) %></p>
                    <p><strong>Status:</strong> <span class="status-pill">${displayOrderStatus}</span></p>
                </div>

                <div class="actions">
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/MenuServlet">Place Another Order</a>
                    <a class="btn btn-light" href="${pageContext.request.contextPath}/NotificationServlet">Check Notifications</a>
                </div>
            </section>
        <% } else { %>
            <section class="card">
                <h2 class="section-title">No Queue Assigned Yet</h2>
                <div class="empty-state">
                    Place an order first, then confirm it to receive a queue number.
                </div>
                <div class="actions">
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/MenuServlet">Go To Menu</a>
                </div>
            </section>
        <% } %>
    </main>
</body>
</html>
