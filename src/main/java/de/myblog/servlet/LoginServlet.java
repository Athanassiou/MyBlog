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
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("userId") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard/");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        try {
            User user = userService.authenticate(username, password);
            if (user == null) {
                req.setAttribute("error", "Benutzername oder Passwort falsch.");
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
                return;
            }
            HttpSession session = req.getSession(true);
            session.setAttribute("userId", user.id);
            session.setAttribute("username", user.username);
            session.setAttribute("displayName", user.displayName);

            String next = req.getParameter("next");
            resp.sendRedirect(next != null && next.startsWith("/") ? next
                    : req.getContextPath() + "/dashboard/");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
