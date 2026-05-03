package filter;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.User;
import model.dao.UserDAO;

public class SessionFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        String path = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length());

        // Define public paths
        boolean isPublicPath = path.equals("/") || path.equals("/index.jsp") || 
                               path.equals("/menu.jsp") ||
                               path.equals("/LoginServlet") || path.equals("/login.jsp") || 
                               path.equals("/RegisterServlet") || path.equals("/register.jsp") ||
                               path.startsWith("/assets/") || path.startsWith("/css/") || path.startsWith("/js/") || path.startsWith("/images/");

        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // Attempt auto-login via cookie if no session
        if (user == null && !isPublicPath) {
            Cookie[] cookies = httpRequest.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("remember_me".equals(cookie.getName())) {
                        String email = cookie.getValue();
                        UserDAO dao = new UserDAO();
                        user = dao.findByEmail(email);
                        if (user != null) {
                            session = httpRequest.getSession(true);
                            session.setAttribute("user", user);
                        }
                        break;
                    }
                }
            }
        }

        // Access Control
        if (user == null) {
            if (!isPublicPath) {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/login.jsp");
                return;
            }
        } else {
            // Role-based authorization
            String role = user.getRole().toLowerCase();
            
            if (path.contains("report") || path.contains("Admin")) {
                if (!"admin".equals(role)) {
                    httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Admin Only");
                    return;
                }
            } else if (path.contains("payment")) {
                if (!"cashier".equals(role) && !"admin".equals(role)) {
                    httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Cashier Only");
                    return;
                }
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
