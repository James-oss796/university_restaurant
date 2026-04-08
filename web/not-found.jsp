<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Not Found | University Restaurant</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
</head>
<body>
    <main class="system-shell">
        <section class="card system-card">
            <div class="system-code">404</div>
            <h2 class="section-title">Page Not Found</h2>
            <p class="auth-intro">
                The page you requested does not exist or may have been moved.
                Use the button below to return to the main login page.
            </p>
            <div class="actions" style="justify-content:center;">
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/LoginServlet">Go To Login</a>
            </div>
        </section>
    </main>
</body>
</html>
