package de.myblog.servlet;

import de.myblog.model.User;
import de.myblog.service.UserService;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.security.Principal;

/**
 * Läuft nach Tomcat-Authentifizierung und befüllt Session-Attribute
 * (userId, username, displayName) aus dem Tomcat-Principal.
 */
public class SessionFilter implements Filter {

    private final UserService userService = new UserService();

    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  httpReq  = (HttpServletRequest)  req;
        HttpServletResponse httpResp = (HttpServletResponse) resp;

        Principal principal = httpReq.getUserPrincipal();
        if (principal != null) {
            HttpSession session = httpReq.getSession(false);
            if (session == null || session.getAttribute("userId") == null) {
                try {
                    User user = userService.findByUsername(principal.getName());
                    if (user != null) {
                        HttpSession s = httpReq.getSession(true);
                        s.setAttribute("userId",      user.id);
                        s.setAttribute("username",    user.username);
                        s.setAttribute("displayName", user.displayName);
                    }
                } catch (Exception ignored) {}
            }
        }

        chain.doFilter(req, resp);
    }
}
