<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    String userRole = sessionUser != null ? sessionUser.getRole() : null;
%>
<header class="site-header">
    <div class="brand-block">
        <p class="brand-meta">University Restaurant</p>
        <h1>Ordering &amp; Queue Portal</h1>
    </div>

    <nav class="top-nav">
        <% if (sessionUser == null) { %>
                <a href="${pageContext.request.contextPath}/LoginServlet">
                    <span class="nav-link-inner">
                        <svg class="nav-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M10 17l5-5-5-5"></path><path d="M15 12H4"></path><path d="M20 4v16"></path></svg>
                        <span>Login</span>
                    </span>
                </a>
                <a href="${pageContext.request.contextPath}/RegisterServlet">
                    <span class="nav-link-inner">
                        <svg class="nav-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 5v14"></path><path d="M5 12h14"></path></svg>
                    <span>Register</span>
                </span>
            </a>
        <% } else if ("student".equals(userRole)) { %>
                <a href="${pageContext.request.contextPath}/MenuServlet">
                    <span class="nav-link-inner">
                        <svg class="nav-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M4 6h16"></path><path d="M4 12h16"></path><path d="M4 18h10"></path></svg>
                        <span>Menu</span>
                    </span>
                </a>
                <a href="${pageContext.request.contextPath}/OrderServlet">
                    <span class="nav-link-inner">
                        <svg class="nav-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M7 4h10"></path><path d="M7 8h10"></path><path d="M7 12h6"></path><rect x="5" y="3" width="14" height="18" rx="2"></rect></svg>
                        <span>Order Review</span>
                    </span>
                </a>
                <a href="${pageContext.request.contextPath}/QueueServlet">
                    <span class="nav-link-inner">
                        <svg class="nav-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M8 7h12"></path><path d="M4 12h16"></path><path d="M10 17h10"></path></svg>
                        <span>Queue</span>
                    </span>
                </a>
                <a href="${pageContext.request.contextPath}/NotificationServlet">
                    <span class="nav-link-inner">
                        <svg class="nav-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 17h12"></path><path d="M8 17V11a4 4 0 118 0v6"></path><path d="M10 20a2 2 0 004 0"></path></svg>
                        <span>Notifications</span>
                    </span>
                </a>
                <span class="nav-user">${sessionScope.user.name}</span>
                <a href="${pageContext.request.contextPath}/LogoutServlet">
                    <span class="nav-link-inner">
                        <svg class="nav-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M10 17l5-5-5-5"></path><path d="M15 12H3"></path><path d="M20 4v16"></path></svg>
                    <span>Logout</span>
                </span>
            </a>
        <% } else if ("cashier".equals(userRole)) { %>
                <a href="${pageContext.request.contextPath}/PaymentServlet">
                    <span class="nav-link-inner">
                        <svg class="nav-icon" viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="6" width="18" height="12" rx="2"></rect><path d="M3 10h18"></path></svg>
                        <span>Payments</span>
                    </span>
                </a>
                <a href="${pageContext.request.contextPath}/PaymentServlet?action=history">
                    <span class="nav-link-inner">
                        <svg class="nav-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 7v5l3 3"></path><circle cx="12" cy="12" r="8"></circle></svg>
                        <span>History</span>
                    </span>
                </a>
                <span class="nav-user">${sessionScope.user.name}</span>
                <a href="${pageContext.request.contextPath}/LogoutServlet">
                    <span class="nav-link-inner">
                        <svg class="nav-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M10 17l5-5-5-5"></path><path d="M15 12H3"></path><path d="M20 4v16"></path></svg>
                    <span>Logout</span>
                </span>
            </a>
        <% } else { %>
                <a href="${pageContext.request.contextPath}/AdminServlet">
                    <span class="nav-link-inner">
                        <svg class="nav-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M5 19V9"></path><path d="M12 19V5"></path><path d="M19 19v-8"></path></svg>
                        <span>Dashboard</span>
                    </span>
                </a>
                <a href="${pageContext.request.contextPath}/ReportServlet">
                    <span class="nav-link-inner">
                        <svg class="nav-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 18V8"></path><path d="M12 18V5"></path><path d="M18 18v-6"></path></svg>
                        <span>Reports</span>
                    </span>
                </a>
                <a href="${pageContext.request.contextPath}/RegisterServlet">
                    <span class="nav-link-inner">
                        <svg class="nav-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 12a4 4 0 100-8 4 4 0 000 8z"></path><path d="M4 20a8 8 0 0116 0"></path></svg>
                        <span>Users</span>
                    </span>
                </a>
                <span class="nav-user">${sessionScope.user.name}</span>
                <a href="${pageContext.request.contextPath}/LogoutServlet">
                    <span class="nav-link-inner">
                        <svg class="nav-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M10 17l5-5-5-5"></path><path d="M15 12H3"></path><path d="M20 4v16"></path></svg>
                    <span>Logout</span>
                </span>
            </a>
        <% } %>
    </nav>
</header>
