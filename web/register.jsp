<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String errorMsg = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register | University Restaurant</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
</head>
<body class="auth-page register-page">
    <main class="auth-shell auth-shell-center">
        <section class="card auth-card auth-wide">
            <div class="auth-form-wrap">
                <h2 class="section-title">Register</h2>
                <p class="auth-intro">
                    Fill in all required fields carefully. Invalid entries will be rejected.
                </p>

                <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
                    <div class="alert alert-error"><%= errorMsg %></div>
                <% } %>

                <form action="${pageContext.request.contextPath}/RegisterServlet" method="post" id="registerForm">
                    <div class="register-role-layout">
                        <div class="field">
                            <label for="role">Role</label>
                            <select id="role"
                                    name="role"
                                    required
                                    data-required-message="Select a role before registering.">
                                <option value="">-- Select role --</option>
                                <option value="student" ${roleValue eq 'student' ? 'selected="selected"' : ''}>Student</option>
                                <option value="cashier" ${roleValue eq 'cashier' ? 'selected="selected"' : ''}>Cashier</option>
                                <option value="admin" ${roleValue eq 'admin' ? 'selected="selected"' : ''}>Admin</option>
                            </select>
                        </div>

                        <aside class="role-spotlight" id="roleSpotlight">
                            <p class="role-spotlight-label">Account Workflow</p>
                            <h3 class="role-spotlight-title" id="roleSpotlightTitle">Choose who is signing in</h3>
                            <p class="role-spotlight-text" id="roleSpotlightText">
                                Student accounts need a student ID. Cashiers process payments, and admins supervise reports and operations.
                            </p>
                        </aside>
                    </div>

                    <div class="student-id-panel ${roleValue eq 'student' ? 'is-active' : ''}" id="studentIdField" aria-hidden="${roleValue eq 'student' ? 'false' : 'true'}">
                        <div class="field">
                            <label for="studentId">Student ID</label>
                            <input id="studentId"
                                   type="text"
                                   name="studentId"
                                   value="${studentIdValue}"
                                   pattern="^[A-Za-z0-9/_-]{4,20}$"
                                   ${roleValue ne 'student' ? 'disabled="disabled"' : ''}
                                   data-required-message="Student ID is required for student accounts."
                                   data-invalid-message="Student ID must be 4 to 20 characters and may use letters, numbers, /, _ or -.">
                            <span class="hint" id="studentIdHint">Student ID is required for students only.</span>
                        </div>
                    </div>

                    <div class="grid-two">
                        <div class="field">
                            <label for="name">Full Name</label>
                            <input id="name"
                                   type="text"
                                   name="name"
                                   value="${nameValue}"
                                   required
                                   pattern="^[A-Za-z][A-Za-z .'-]*$"
                                   data-required-message="Full name is required."
                                   data-invalid-message="Full name must contain letters only. Numbers are not allowed.">
                            <span class="hint">Letters, spaces, apostrophes, dots, or hyphens only.</span>
                        </div>

                        <div class="field">
                            <label for="phoneNumber">Phone Number</label>
                            <input id="phoneNumber"
                                   type="text"
                                   name="phoneNumber"
                                   value="${phoneNumberValue}"
                                   required
                                   pattern="^\+?[0-9]{10,15}$"
                                   data-required-message="Phone number is required."
                                   data-invalid-message="Phone number must contain 10 to 15 digits.">
                            <span class="hint">Example: <code>0712345678</code> or <code>+254712345678</code>.</span>
                        </div>
                    </div>

                    <div class="grid-two">
                        <div class="field">
                            <label for="email">Email Address</label>
                            <input id="email"
                                   type="email"
                                   name="email"
                                   value="${emailValue}"
                                   required
                                   data-required-message="Email address is required."
                                   data-invalid-message="Enter a valid email address that includes @.">
                            <span class="hint">Email must include <strong>@</strong>.</span>
                        </div>

                        <div class="field">
                            <label for="password">Password</label>
                            <div class="input-with-toggle">
                                <input id="password"
                                       type="password"
                                       name="password"
                                       required
                                       pattern="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$"
                                       data-required-message="Password is required."
                                       data-invalid-message="Password must be at least 8 characters and include uppercase, lowercase, and a number.">
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
                            <span class="hint">At least 8 characters with uppercase, lowercase, and a number.</span>
                        </div>
                    </div>

                    <div class="actions">
                        <button class="btn btn-primary" type="submit">Create Account</button>
                        <a class="btn btn-light" href="${pageContext.request.contextPath}/LoginServlet">Back to Login</a>
                    </div>
                </form>
            </div>
        </section>
    </main>
    <script>
        (function () {
            var form = document.getElementById('registerForm');
            if (!form) return;

            var role = document.getElementById('role');
            var studentId = document.getElementById('studentId');
            var studentIdField = document.getElementById('studentIdField');
            var studentIdHint = document.getElementById('studentIdHint');
            var roleSpotlightTitle = document.getElementById('roleSpotlightTitle');
            var roleSpotlightText = document.getElementById('roleSpotlightText');
            var controls = form.querySelectorAll('input, select, textarea');
            var toggleButtons = form.querySelectorAll('[data-password-target]');
            var roleDescriptions = {
                '': {
                    title: 'Choose who is signing in',
                    text: 'Student accounts need a student ID. Cashiers process payments, and admins supervise reports and operations.'
                },
                student: {
                    title: 'Student flow selected',
                    text: 'Students place food orders, receive queue numbers, and track payment and pickup updates.'
                },
                cashier: {
                    title: 'Cashier flow selected',
                    text: 'Cashiers verify order totals, confirm payments, and keep the service line moving.'
                },
                admin: {
                    title: 'Admin flow selected',
                    text: 'Admins monitor demand, review reports, and keep user access and queue operations healthy.'
                }
            };

            function syncStudentIdRequirement() {
                var isStudent = role.value === 'student';
                var description = roleDescriptions[role.value] || roleDescriptions[''];
                studentIdField.classList.toggle('is-active', isStudent);
                studentIdField.setAttribute('aria-hidden', isStudent ? 'false' : 'true');
                studentId.disabled = !isStudent;
                studentId.required = isStudent;
                studentIdHint.textContent = isStudent
                    ? 'Student ID is required for students.'
                    : 'Student ID is only used for student accounts.';
                roleSpotlightTitle.textContent = description.title;
                roleSpotlightText.textContent = description.text;
                if (!isStudent) {
                    studentId.value = '';
                    studentId.setCustomValidity('');
                }
            }

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

            role.addEventListener('change', function () {
                syncStudentIdRequirement();
                role.setCustomValidity('');
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

            syncStudentIdRequirement();
        })();
    </script>
</body>
</html>
