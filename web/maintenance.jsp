<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Maintenance | University Restaurant</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
</head>
<body>
    <main class="system-shell">
        <section class="card system-card">
            <div class="system-code">503</div>
            <h2 class="section-title">System Under Maintenance</h2>
            <p class="auth-intro">
                The University Restaurant system is temporarily unavailable while updates are being applied.
                Please try again later.
            </p>
            <div class="actions" style="justify-content:center;">
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/LoginServlet">Try Again Later</a>
            </div>
        </section>
    </main>
</body>
</html>
