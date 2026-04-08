<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Error | University Restaurant</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
</head>
<body>
    <main class="system-shell">
        <section class="card system-card">
            <div class="system-code">500</div>
            <h2 class="section-title">Something Went Wrong</h2>
            <p class="auth-intro">
                The system encountered an unexpected problem while processing your request.
                Please try again, or contact the administrator if the issue continues.
            </p>
            <div class="actions" style="justify-content:center;">
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/LoginServlet">Return To Login</a>
            </div>
        </section>
    </main>
</body>
</html>
