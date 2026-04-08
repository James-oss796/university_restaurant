<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.Payment" %>
<%@ page import="model.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null || !"admin".equals(sessionUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }

    Number revenueTodayValue = (Number) request.getAttribute("revenueToday");
    double revenueToday = revenueTodayValue != null ? revenueTodayValue.doubleValue() : 0.0;

    Map<String, Integer> roleCounts = (Map<String, Integer>) request.getAttribute("roleCounts");
    int studentCount = roleCounts != null && roleCounts.get("student") != null ? roleCounts.get("student") : 0;
    int cashierCount = roleCounts != null && roleCounts.get("cashier") != null ? roleCounts.get("cashier") : 0;
    int adminCount = roleCounts != null && roleCounts.get("admin") != null ? roleCounts.get("admin") : 0;

    List<Map<String, Object>> queueOverview = (List<Map<String, Object>>) request.getAttribute("queueOverview");
    List<Map<String, Object>> recentOrders = (List<Map<String, Object>>) request.getAttribute("recentOrders");
    List<Payment> recentPayments = (List<Payment>) request.getAttribute("recentPayments");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | University Restaurant</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
</head>
<body>
    <jsp:include page="layout.jsp" />

    <main class="page-shell stack">
        <section class="card">
            <h2 class="section-title">Admin Dashboard</h2>
            <p class="section-subtitle">Live operations overview for orders, payments, queue pressure, and account activity.</p>

            <div class="metrics">
                <article class="metric">
                    <p class="metric-label">Orders Today</p>
                    <p class="metric-value">${requestScope.todayOrders}</p>
                </article>
                <article class="metric">
                    <p class="metric-label">Revenue Today</p>
                    <p class="metric-value">KES <%= String.format("%.2f", revenueToday) %></p>
                </article>
                <article class="metric">
                    <p class="metric-label">Active Queue</p>
                    <p class="metric-value">${requestScope.activeQueueCount}</p>
                </article>
                <article class="metric">
                    <p class="metric-label">Users</p>
                    <p class="metric-value">${requestScope.totalUsers}</p>
                </article>
            </div>

            <div class="actions">
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/ReportServlet">Open Reports</a>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/RegisterServlet">Create Or Review Users</a>
                <a class="btn btn-light" href="${pageContext.request.contextPath}/AdminServlet">Refresh Dashboard</a>
            </div>
        </section>

        <section class="dashboard-grid two-up">
            <article class="card compact-card">
                <h3 class="section-title">System Health</h3>
                <div class="info-list">
                    <div class="info-row"><span class="info-label">Pending Orders</span><strong>${requestScope.pendingOrders}</strong></div>
                    <div class="info-row"><span class="info-label">Preparing Orders</span><strong>${requestScope.preparingOrders}</strong></div>
                    <div class="info-row"><span class="info-label">Payments Today</span><strong>${requestScope.paymentsToday}</strong></div>
                    <div class="info-row"><span class="info-label">Longest Queue Wait</span><strong>${requestScope.longestQueueWait} min</strong></div>
                    <div class="info-row"><span class="info-label">Next Queue Number</span><strong>#${requestScope.nextQueueNumber}</strong></div>
                </div>
            </article>

            <article class="card compact-card">
                <h3 class="section-title">Team Mix</h3>
                <div class="info-list">
                    <div class="info-row"><span class="info-label">Students</span><strong><%= studentCount %></strong></div>
                    <div class="info-row"><span class="info-label">Cashiers</span><strong><%= cashierCount %></strong></div>
                    <div class="info-row"><span class="info-label">Admins</span><strong><%= adminCount %></strong></div>
                    <div class="info-row"><span class="info-label">Active Accounts</span><strong>${requestScope.activeUsers}</strong></div>
                    <div class="info-row"><span class="info-label">Cash Payments Today</span><strong>${requestScope.cashPaymentsToday}</strong></div>
                    <div class="info-row"><span class="info-label">M-Pesa Payments Today</span><strong>${requestScope.mobilePaymentsToday}</strong></div>
                </div>
            </article>
        </section>

        <section class="card compact-card">
            <h3 class="section-title">Queue Watch</h3>
            <p class="section-subtitle">Students currently waiting for payment, shown in service order.</p>
            <% if (queueOverview == null || queueOverview.isEmpty()) { %>
                <div class="empty-state">No unpaid tickets are waiting right now.</div>
            <% } else { %>
                <div class="table-scroll">
                    <table class="mini-table">
                        <thead>
                            <tr>
                                <th>Queue</th>
                                <th>Order</th>
                                <th>Student</th>
                                <th>Status</th>
                                <th>Wait</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, Object> ticket : queueOverview) {
                                   pageContext.setAttribute("ticket", ticket);
                            %>
                                <tr>
                                    <td>#${ticket.queueNumber}</td>
                                    <td>#${ticket.orderId}</td>
                                    <td>${ticket.customerName}</td>
                                    <td>${ticket.status}</td>
                                    <td>${ticket.waitingMinutes} min</td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </section>

        <section class="card table-card">
            <h3 class="section-title">Recent Orders</h3>
            <% if (recentOrders == null || recentOrders.isEmpty()) { %>
                <div class="empty-state">Orders will appear here once students start checking out.</div>
            <% } else { %>
                <div class="table-scroll">
                    <table>
                        <thead>
                            <tr>
                                <th>Order</th>
                                <th>Student</th>
                                <th>Queue</th>
                                <th>Status</th>
                                <th>Payment</th>
                                <th>Total</th>
                                <th>Created</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, Object> order : recentOrders) {
                                   pageContext.setAttribute("order", order);
                                   Number queueNumber = (Number) order.get("queueNumber");
                                   Number totalAmount = (Number) order.get("totalAmount");
                            %>
                                <tr>
                                    <td>#${order.orderId}</td>
                                    <td>${order.customerName}</td>
                                    <td><%= queueNumber != null && queueNumber.intValue() > 0 ? "#" + queueNumber.intValue() : "-" %></td>
                                    <td><span class="status-pill">${order.status}</span></td>
                                    <td>${order.paymentState}</td>
                                    <td>KES <%= String.format("%.2f", totalAmount != null ? totalAmount.doubleValue() : 0.0) %></td>
                                    <td>${order.createdAt}</td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </section>

        <section class="card table-card">
            <h3 class="section-title">Recent Payments</h3>
            <% if (recentPayments == null || recentPayments.isEmpty()) { %>
                <div class="empty-state">Payments will appear here once cashiers begin confirming orders.</div>
            <% } else { %>
                <div class="table-scroll">
                    <table>
                        <thead>
                            <tr>
                                <th>Payment</th>
                                <th>Order</th>
                                <th>Cashier</th>
                                <th>Method</th>
                                <th>Amount</th>
                                <th>Date</th>
                                <th>Time</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Payment payment : recentPayments) {
                                   pageContext.setAttribute("payment", payment);
                            %>
                                <tr>
                                    <td>#${payment.paymentId}</td>
                                    <td>#${payment.orderId}</td>
                                    <td>${payment.cashierName}</td>
                                    <td>${payment.paymentMethodLabel}</td>
                                    <td>KES <%= String.format("%.2f", payment.getAmount()) %></td>
                                    <td>${payment.paymentDate}</td>
                                    <td>${payment.paymentTime}</td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </section>
    </main>
</body>
</html>
