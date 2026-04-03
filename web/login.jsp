<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
</head>
<body>
    <div>
        <h2>Login</h2>

        <p>${message}</p>
        <p>${error}</p>

        <form action="${pageContext.request.contextPath}/LoginServlet" method="post">
            <label for="email">Email</label><br/>
            <input id="email" type="email" name="email" value="${emailValue}" /><br/>

            <label for="password">Password</label><br/>
            <input id="password" type="password" name="password" /><br/>

            <input type="submit" value="Login" />
        </form>

        <p>
            Do not have an account?
            <a href="${pageContext.request.contextPath}/RegisterServlet">Register here</a>
        </p>
    </div>
</body>
</html>
