<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String message = (String) request.getAttribute("message");
    String errorMsg = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | University Restaurant</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
</head>
<body class="auth-page login-page">
    <main class="auth-shell auth-shell-center">
        <section class="card auth-card">
            <div class="auth-form-wrap">
                <h2 class="section-title">Login</h2>
                <p class="auth-intro">Use your registered email and password to continue.</p>

                <% if (message != null && !message.isEmpty()) { %>
                    <div class="alert alert-success"><%= message %></div>
                <% } %>
                <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
                    <div class="alert alert-error"><%= errorMsg %></div>
                <% } %>

                <form action="${pageContext.request.contextPath}/LoginServlet" method="post" id="loginForm">
                    <div class="field">
                        <label for="email">Email Address</label>
                        <input id="email"
                               type="email"
                               name="email"
                               value="${emailValue}"
                               required
                               data-required-message="Email address is required."
                               data-invalid-message="Enter a valid email address that includes @.">
                        <span class="hint">The email must include <strong>@</strong>.</span>
                    </div>

                    <div class="field">
                        <label for="password">Password</label>
                        <div class="input-with-toggle">
                            <input id="password"
                                   type="password"
                                   name="password"
                                   required
                                   data-required-message="Password is required.">
                            <button class="password-toggle"
                                    type="button"
                                    data-password-target="password"
                                    aria-controls="password"
                                    aria-label="Show password">
                                <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                                    <path d="M2 12s3.5-6 10-6 10 6 10 6-3.5 6-10 6-10-6-10-6z"></path>
                                    <circle cx="12" cy="12" r="3"></circle>
                                </svg>
                                <span class="sr-only">Show password</span>
                            </button>
                        </div>
                        <span class="hint">This field must be filled before login.</span>
                    </div>

                    <div class="actions">
                        <button class="btn btn-primary" type="submit">Login</button>
                        <a class="btn btn-light" href="${pageContext.request.contextPath}/RegisterServlet">Create Account</a>
                    </div>
                </form>
            </div>
        </section>
    </main>
    <script>
        (function () {
            var form = document.getElementById('loginForm');
            if (!form) return;

            var controls = form.querySelectorAll('input, select, textarea');
            var toggleButtons = form.querySelectorAll('[data-password-target]');
            controls.forEach(function (control) {
                control.addEventListener('invalid', function () {
                    if (control.validity.valueMissing && control.dataset.requiredMessage) {
                        control.setCustomValidity(control.dataset.requiredMessage);
                    } else if ((control.validity.typeMismatch || control.validity.patternMismatch) &&
                               control.dataset.invalidMessage) {
                        control.setCustomValidity(control.dataset.invalidMessage);
                    } else {
                        control.setCustomValidity('');
                    }
                });

                control.addEventListener('input', function () {
                    control.setCustomValidity('');
                });
            });

            toggleButtons.forEach(function (button) {
                button.addEventListener('click', function () {
                    var input = document.getElementById(button.dataset.passwordTarget);
                    if (!input) return;

                    var showing = input.type === 'text';
                    input.type = showing ? 'password' : 'text';
                    button.classList.toggle('is-visible', !showing);
                    button.setAttribute('aria-label', showing ? 'Show password' : 'Hide password');
                    var label = button.querySelector('.sr-only');
                    if (label) {
                        label.textContent = showing ? 'Show password' : 'Hide password';
                    }
                });
            });
        })();
    </script>
</body>
</html>
