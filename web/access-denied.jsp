<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied | University Restaurant</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
</head>
<body>
    <main class="system-shell">
        <section class="card system-card">
            <div class="system-code">403</div>
            <h2 class="section-title">Access Denied</h2>
            <p class="auth-intro">
                You do not have permission to open this page with the current account.
                Sign in with the correct role and try again.
            </p>
            <div class="actions" style="justify-content:center;">
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/LoginServlet">Back To Login</a>
            </div>
        </section>
    </main>
</body>
</html>
