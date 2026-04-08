<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.DailyReport" %>
<%@ page import="model.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null || !"admin".equals(sessionUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }

    List<DailyReport> reports = (List<DailyReport>) request.getAttribute("reports");
    DailyReport latestReport = reports != null && !reports.isEmpty() ? reports.get(0) : null;
    if (latestReport != null) {
        pageContext.setAttribute("latestReport", latestReport);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports | University Restaurant</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
</head>
<body>
    <jsp:include page="layout.jsp" />

    <main class="page-shell stack">
        <section class="card">
            <h2 class="section-title">Daily Reports Dashboard</h2>
            <p class="section-subtitle">Review totals, payment split, meal activity, and average waiting time.</p>

            <% if (latestReport != null) { %>
                <div class="metrics">
                    <article class="metric">
                        <p class="metric-label">Latest Date</p>
                        <p class="metric-value">${latestReport.reportDate}</p>
                    </article>
                    <article class="metric">
                        <p class="metric-label">Total Orders</p>
                        <p class="metric-value">${latestReport.totalOrders}</p>
                    </article>
                    <article class="metric">
                        <p class="metric-label">Revenue</p>
                        <p class="metric-value">KES <%= String.format("%.2f", latestReport.getTotalRevenue()) %></p>
                    </article>
                    <article class="metric">
                        <p class="metric-label">Avg Wait</p>
                        <p class="metric-value">${latestReport.avgWaitTime} min</p>
                    </article>
                </div>
            <% } %>
        </section>

        <section class="card table-card">
            <h2 class="section-title">Report History</h2>

            <% if (reports == null || reports.isEmpty()) { %>
                <div class="empty-state">
                    No daily reports are stored yet. Insert report records into <code>daily_reports</code> to populate this dashboard.
                </div>
            <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Total Orders</th>
                            <th>Total Revenue</th>
                            <th>Cash</th>
                            <th>Mobile Money</th>
                            <th>Breakfast</th>
                            <th>Lunch</th>
                            <th>Dinner</th>
                            <th>Avg Wait</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (DailyReport report : reports) {
                               pageContext.setAttribute("report", report);
                        %>
                            <tr>
                                <td><strong>${report.reportDate}</strong></td>
                                <td>${report.totalOrders}</td>
                                <td>KES <%= String.format("%.2f", report.getTotalRevenue()) %></td>
                                <td>KES <%= String.format("%.2f", report.getCashPayments()) %></td>
                                <td>KES <%= String.format("%.2f", report.getMobileMoneyPayments()) %></td>
                                <td>${report.breakfastOrders}</td>
                                <td>${report.lunchOrders}</td>
                                <td>${report.dinnerOrders}</td>
                                <td>${report.avgWaitTime} min</td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </section>
    </main>
</body>
</html>
