<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Register</title>
</head>
<body>
    <div>
        <h2>Register</h2>

        <p>${error}</p>

        <form action="${pageContext.request.contextPath}/RegisterServlet" method="post">
            <label for="studentId">Student ID</label><br/>
            <input id="studentId" type="text" name="studentId" value="${studentIdValue}" /><br/>

            <label for="name">Full Name</label><br/>
            <input id="name" type="text" name="name" value="${nameValue}" /><br/>

            <label for="email">Email</label><br/>
            <input id="email" type="email" name="email" value="${emailValue}" /><br/>

            <label for="password">Password</label><br/>
            <input id="password" type="password" name="password" /><br/>

            <label for="role">Role</label><br/>
            <select id="role" name="role">
                <option value="">-- Select role --</option>
                <option value="student" ${roleValue eq 'student' ? 'selected="selected"' : ''}>Student</option>
                <option value="cashier" ${roleValue eq 'cashier' ? 'selected="selected"' : ''}>Cashier</option>
                <option value="admin" ${roleValue eq 'admin' ? 'selected="selected"' : ''}>Admin</option>
            </select><br/>

            <input type="submit" value="Register" />
        </form>

        <p>Student ID is required for student accounts.</p>
        <p>
            Already have an account?
            <a href="${pageContext.request.contextPath}/LoginServlet">Login here</a>
        </p>
    </div>
</body>
</html>
