package de.myblog.servlet;

import de.myblog.model.User;
import de.myblog.service.BlogService;
import de.myblog.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * /admin/              → Benutzerübersicht
 * /admin/users/new     → Benutzer anlegen
 * /admin/members       → Blog-Mitglieder verwalten
 * /admin/members/add   → Mitglied hinzufügen (POST)
 * /admin/members/{id}/role   → Rolle ändern (POST)
 * /admin/members/{id}/remove → Mitglied entfernen (POST)
 */
public class AdminServlet extends HttpServlet {

    private static final int BLOG_ID = 1;

    private final UserService userService = new UserService();
    private final BlogService blogService = new BlogService();

    // ─── Auth-Guard: nur owner und admin ──────────────────────────

    private boolean isAdmin(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("userId") == null) return false;
        String role = (String) s.getAttribute("userRole");
        return "owner".equals(role) || "admin".equals(role);
    }

    // ─── GET ──────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isAdmin(req)) { resp.sendError(403); return; }

        String sub = subPath(req);

        try {
            if (sub.isEmpty() || sub.equals("users")) {
                req.setAttribute("users", userService.listAll());
                req.setAttribute("members", blogService.listMembers(BLOG_ID));
                req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);

            } else if (sub.equals("users/new")) {
                req.getRequestDispatcher("/WEB-INF/views/admin/user-form.jsp").forward(req, resp);

            } else if (sub.equals("members")) {
                req.setAttribute("members", blogService.listMembers(BLOG_ID));
                req.setAttribute("allUsers", userService.listAll());
                req.getRequestDispatcher("/WEB-INF/views/admin/members.jsp").forward(req, resp);

            } else {
                resp.sendError(404);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ─── POST ─────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isAdmin(req)) { resp.sendError(403); return; }

        String sub = subPath(req);

        try {
            if (sub.equals("users/new")) {
                handleCreateUser(req, resp);

            } else if (sub.equals("members/add")) {
                int    userId = Integer.parseInt(req.getParameter("userId"));
                String role   = req.getParameter("role");
                blogService.addMember(BLOG_ID, userId, role);
                resp.sendRedirect(req.getContextPath() + "/admin/members");

            } else if (sub.matches("members/\\d+/role")) {
                int    userId = Integer.parseInt(sub.split("/")[1]);
                String role   = req.getParameter("role");
                // owner-Rolle darf nicht geändert werden
                String current = userService.getRoleInBlog(userId, BLOG_ID);
                if (!"owner".equals(current)) {
                    blogService.updateMemberRole(BLOG_ID, userId, role);
                }
                resp.sendRedirect(req.getContextPath() + "/admin/members");

            } else if (sub.matches("members/\\d+/remove")) {
                int userId = Integer.parseInt(sub.split("/")[1]);
                String current = userService.getRoleInBlog(userId, BLOG_ID);
                if (!"owner".equals(current)) {
                    blogService.removeMember(BLOG_ID, userId);
                }
                resp.sendRedirect(req.getContextPath() + "/admin/members");

            } else {
                resp.sendError(404);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ─── Handler ──────────────────────────────────────────────────

    private void handleCreateUser(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String username    = req.getParameter("username");
        String displayName = req.getParameter("displayName");
        String email       = req.getParameter("email");
        String password    = req.getParameter("password");
        String role        = req.getParameter("role");

        if (username == null || username.isBlank() || password == null || password.isBlank()) {
            req.setAttribute("error", "Benutzername und Passwort sind Pflichtfelder.");
            req.getRequestDispatcher("/WEB-INF/views/admin/user-form.jsp").forward(req, resp);
            return;
        }

        User created = userService.create(username.trim(), displayName, email, password);
        if (created == null) {
            req.setAttribute("error", "Benutzername oder E-Mail bereits vergeben.");
            req.getRequestDispatcher("/WEB-INF/views/admin/user-form.jsp").forward(req, resp);
            return;
        }

        if (role != null && !role.isBlank()) {
            blogService.addMember(BLOG_ID, created.id, role);
        }

        resp.sendRedirect(req.getContextPath() + "/admin/");
    }

    // ─── Hilfsmethoden ───────────────────────────────────────────

    private String subPath(HttpServletRequest req) {
        String info = req.getPathInfo();
        if (info == null || info.equals("/")) return "";
        return info.replaceFirst("^/", "").replaceFirst("/$", "");
    }
}
