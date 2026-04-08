<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.Payment" %>
<%@ page import="model.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null || !"cashier".equals(sessionUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }

    String paymentSuccess = (String) request.getAttribute("paymentSuccess");
    String errorMsg = (String) request.getAttribute("error");
    String warningMsg = (String) request.getAttribute("warning");
    String prefilledOrderId = request.getAttribute("prefilledOrderId") == null ? null : String.valueOf(request.getAttribute("prefilledOrderId"));

    Number revenueTodayValue = (Number) request.getAttribute("revenueToday");
    double revenueToday = revenueTodayValue != null ? revenueTodayValue.doubleValue() : 0.0;
    Number averageTicketValue = (Number) request.getAttribute("averageTicketToday");
    double averageTicket = averageTicketValue != null ? averageTicketValue.doubleValue() : 0.0;

    List<Map<String, Object>> queueOverview = (List<Map<String, Object>>) request.getAttribute("queueOverview");
    List<Payment> recentPayments = (List<Payment>) request.getAttribute("recentPayments");
    List<Payment> paymentHistory = (List<Payment>) request.getAttribute("paymentHistory");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Process Payment | University Restaurant</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
</head>
<body>
    <jsp:include page="layout.jsp" />

    <main class="page-shell stack">
        <% if (paymentSuccess != null) { %><div class="alert alert-success"><%= paymentSuccess %></div><% } %>
        <% if (errorMsg != null) { %><div class="alert alert-error"><%= errorMsg %></div><% } %>
        <% if (warningMsg != null) { %><div class="alert alert-info"><%= warningMsg %></div><% } %>

        <section class="card">
            <h2 class="section-title">Cashier Workbench</h2>
            <p class="section-subtitle">Track today's takings, clear the live payment line, and jump straight into the next order.</p>

            <div class="metrics">
                <article class="metric">
                    <p class="metric-label">Payments Today</p>
                    <p class="metric-value">${requestScope.paymentsToday}</p>
                </article>
                <article class="metric">
                    <p class="metric-label">Revenue Today</p>
                    <p class="metric-value">KES <%= String.format("%.2f", revenueToday) %></p>
                </article>
                <article class="metric">
                    <p class="metric-label">Average Ticket</p>
                    <p class="metric-value">KES <%= String.format("%.2f", averageTicket) %></p>
                </article>
                <article class="metric">
                    <p class="metric-label">Awaiting Payment</p>
                    <p class="metric-value">${requestScope.activeQueueCount}</p>
                </article>
            </div>

            <div class="dashboard-grid two-up">
                <article class="compact-card surface-card">
                    <h3 class="section-title">Queue To Clear</h3>
                    <div class="info-list">
                        <div class="info-row"><span class="info-label">Average Wait</span><strong>${requestScope.averageQueueWait} min</strong></div>
                        <div class="info-row"><span class="info-label">Next Queue Number</span><strong>#${requestScope.nextQueueNumber}</strong></div>
                        <div class="info-row"><span class="info-label">Cash Payments</span><strong>${requestScope.cashPaymentsToday}</strong></div>
                        <div class="info-row"><span class="info-label">M-Pesa Payments</span><strong>${requestScope.mobilePaymentsToday}</strong></div>
                    </div>

                    <% if (queueOverview == null || queueOverview.isEmpty()) { %>
                        <div class="empty-state">No unpaid tickets are waiting right now.</div>
                    <% } else { %>
                        <div class="activity-list">
                            <% for (Map<String, Object> ticket : queueOverview) {
                                   pageContext.setAttribute("ticket", ticket);
                                   Number totalAmount = (Number) ticket.get("totalAmount");
                            %>
                                <div class="activity-item">
                                    <div>
                                        <strong>Queue #${ticket.queueNumber} for ${ticket.customerName}</strong>
                                        <p>Order #${ticket.orderId} - KES <%= String.format("%.2f", totalAmount != null ? totalAmount.doubleValue() : 0.0) %> - waiting ${ticket.waitingMinutes} min</p>
                                    </div>
                                    <a class="btn btn-light btn-compact" href="${pageContext.request.contextPath}/PaymentServlet?orderId=${ticket.orderId}">Process</a>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </article>

                <article class="compact-card surface-card">
                    <h3 class="section-title">Recent Confirmations</h3>
                    <% if (recentPayments == null || recentPayments.isEmpty()) { %>
                        <div class="empty-state">Confirmed payments will show here.</div>
                    <% } else { %>
                        <div class="activity-list">
                            <% for (Payment payment : recentPayments) {
                                   pageContext.setAttribute("payment", payment);
                            %>
                                <div class="activity-item">
                                    <div>
                                        <strong>Payment #${payment.paymentId} for Order #${payment.orderId}</strong>
                                        <p>${payment.paymentMethodLabel} - ${payment.paymentDate} ${payment.paymentTime}</p>
                                    </div>
                                    <span class="status-pill">KES <%= String.format("%.2f", payment.getAmount()) %></span>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </article>
            </div>
        </section>

        <% if (paymentHistory == null) { %>
            <section class="card">
                <h2 class="section-title">Process Payment</h2>

                <% if (prefilledOrderId != null && errorMsg == null && warningMsg == null) { %>
                    <div class="alert alert-info">
                        Order #<%= prefilledOrderId %> is ready for payment.
                        <% if (request.getAttribute("prefilledAmount") != null) { %>
                            Amount due: <strong>KES ${prefilledAmount}</strong>.
                        <% } %>
                    </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/PaymentServlet" method="post" id="paymentForm" novalidate>
                    <div class="field">
                        <label for="orderId">Order ID</label>
                        <input type="number" id="orderId" name="orderId" min="1" value="${prefilledOrderId}" placeholder="Enter the order number" required>
                        <span class="hint">Ask the student for their order ID or queue ticket.</span>
                    </div>

                    <div class="field">
                        <label for="amount">Amount (KES)</label>
                        <input type="number" id="amount" name="amount" min="0.01" step="0.01" value="${prefilledAmount}" placeholder="0.00" required>
                    </div>

                    <div class="field">
                        <label for="paymentMethod">Payment Method</label>
                        <select id="paymentMethod" name="paymentMethod" onchange="toggleReference(this.value)">
                            <option value="cash" ${selectedMethod eq 'cash' or empty selectedMethod ? 'selected="selected"' : ''}>Cash</option>
                            <option value="mobile_money" ${selectedMethod eq 'mobile_money' ? 'selected="selected"' : ''}>Mobile Money (M-Pesa)</option>
                        </select>
                    </div>

                    <div class="field" id="refGroup" style="display:none;">
                        <label for="transactionReference">M-Pesa Transaction Reference</label>
                        <input type="text" id="transactionReference" name="transactionReference" value="${transactionReference}" placeholder="e.g. QA12B3C4D5" maxlength="100">
                        <span class="hint">Required only for mobile money payments.</span>
                    </div>

                    <div class="actions">
                        <button type="submit" class="btn btn-primary">Confirm Payment</button>
                        <a href="${pageContext.request.contextPath}/PaymentServlet?action=history" class="btn btn-secondary">View History</a>
                        <a href="${pageContext.request.contextPath}/PaymentServlet" class="btn btn-light">Clear Form</a>
                    </div>
                </form>
            </section>
        <% } else { %>
            <section class="card table-card">
                <h2 class="section-title">Payment History</h2>
                <p class="section-subtitle">Latest cashier confirmations across the restaurant.</p>

                <div class="actions">
                    <a href="${pageContext.request.contextPath}/PaymentServlet" class="btn btn-primary">New Payment</a>
                </div>

                <% if (paymentHistory.isEmpty()) { %>
                    <div class="empty-state">No payments recorded yet.</div>
                <% } else { %>
                    <table>
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Payment ID</th>
                                <th>Order ID</th>
                                <th>Amount</th>
                                <th>Method</th>
                                <th>Reference</th>
                                <th>Cashier</th>
                                <th>Date</th>
                                <th>Time</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% int count = 1;
                               for (Payment payment : paymentHistory) {
                                   pageContext.setAttribute("payment", payment);
                            %>
                                <tr>
                                    <td><%= count++ %></td>
                                    <td>#${payment.paymentId}</td>
                                    <td>#${payment.orderId}</td>
                                    <td>KES <%= String.format("%.2f", payment.getAmount()) %></td>
                                    <td>${payment.paymentMethodLabel}</td>
                                    <td><%= payment.getTransactionReference() == null || payment.getTransactionReference().isEmpty() ? "-" : payment.getTransactionReference() %></td>
                                    <td><%= payment.getCashierName() == null || payment.getCashierName().isEmpty() ? "-" : payment.getCashierName() %></td>
                                    <td>${payment.paymentDate}</td>
                                    <td>${payment.paymentTime}</td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </section>
        <% } %>
    </main>

    <script>
        function toggleReference(method) {
            var refGroup = document.getElementById('refGroup');
            var refInput = document.getElementById('transactionReference');
            if (method === 'mobile_money') {
                refGroup.style.display = 'block';
                refInput.required = true;
            } else {
                refGroup.style.display = 'none';
                refInput.required = false;
                refInput.value = '';
            }
        }

        (function () {
            var sel = document.getElementById('paymentMethod');
            if (sel) {
                toggleReference(sel.value);
            }

            var form = document.getElementById('paymentForm');
            if (!form) return;

            form.addEventListener('submit', function (e) {
                var orderId = document.getElementById('orderId').value.trim();
                var amount = document.getElementById('amount').value.trim();
                var method = document.getElementById('paymentMethod').value;
                var ref = document.getElementById('transactionReference').value.trim();

                if (!orderId || parseInt(orderId, 10) <= 0) {
                    alert('Please enter a valid Order ID.');
                    e.preventDefault();
                    return;
                }
                if (!amount || parseFloat(amount) <= 0) {
                    alert('Please enter a valid amount greater than zero.');
                    e.preventDefault();
                    return;
                }
                if (method === 'mobile_money' && ref === '') {
                    alert('Please enter the M-Pesa transaction reference for Mobile Money payments.');
                    e.preventDefault();
                }
            });
        })();
    </script>
</body>
</html>
