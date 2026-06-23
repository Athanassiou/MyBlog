package de.myblog.servlet;

import de.myblog.model.User;
import de.myblog.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;

public class LoginServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (req.getUserPrincipal() != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard/");
            return;
        }
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String next     = req.getParameter("next");

        try {
            req.login(username, password);

            User user = userService.findByUsername(username);
            if (user != null) {
                HttpSession s = req.getSession(true);
                s.setAttribute("userId",      user.id);
                s.setAttribute("username",    user.username);
                s.setAttribute("displayName", user.displayName);
            }

            resp.sendRedirect(next != null && next.startsWith("/") ? next
                    : req.getContextPath() + "/dashboard/");

        } catch (Exception e) {
            req.setAttribute("error", "Benutzername oder Passwort falsch.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }
}
