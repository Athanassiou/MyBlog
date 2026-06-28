package de.myblog.servlet;

import de.myblog.model.Blog;
import de.myblog.model.User;
import de.myblog.service.BlogService;
import de.myblog.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * /admin/                       → Benutzerübersicht
 * /admin/users/new              → Benutzer anlegen
 * /admin/blogs/                 → Alle Blogs
 * /admin/blogs/new              → Blog anlegen
 * /admin/blogs/{id}/edit        → Blog bearbeiten
 * /admin/members/{blogId}       → Mitglieder eines Blogs
 * /admin/members/{blogId}/add   → Mitglied hinzufügen (POST)
 * /admin/members/{blogId}/{uid}/role   → Rolle ändern (POST)
 * /admin/members/{blogId}/{uid}/remove → Entfernen (POST)
 */
public class AdminServlet extends HttpServlet {

    private final UserService userService = new UserService();
    private final BlogService blogService = new BlogService();

    // ─── Auth-Guard ───────────────────────────────────────────────
    // Platform-Admin = eingeloggt (jeder kann eigene Blogs verwalten).
    // Spezielle Blog-Operationen prüfen Rolle per DB.

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && s.getAttribute("userId") != null;
    }

    private int userId(HttpServletRequest req) {
        return (int) req.getSession().getAttribute("userId");
    }

    private boolean hasRoleInBlog(int blogId, HttpServletRequest req, String... allowed) {
        try {
            String role = userService.getRoleInBlog(userId(req), blogId);
            if (role == null) return false;
            for (String a : allowed) if (a.equals(role)) return true;
            return false;
        } catch (Exception e) { return false; }
    }

    // ─── GET ──────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isLoggedIn(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String sub = subPath(req);

        try {
            if (sub.isEmpty() || sub.equals("users")) {
                req.setAttribute("users", userService.listAll());
                req.setAttribute("blogs", blogService.listPublic());
                req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);

            } else if (sub.equals("users/new")) {
                req.setAttribute("blogs", blogService.listPublic());
                req.getRequestDispatcher("/WEB-INF/views/admin/user-form.jsp").forward(req, resp);

            } else if (sub.equals("blogs") || sub.equals("blogs/")) {
                req.setAttribute("blogs", blogService.listAll());
                req.getRequestDispatcher("/WEB-INF/views/admin/blogs.jsp").forward(req, resp);

            } else if (sub.equals("blogs/new")) {
                req.getRequestDispatcher("/WEB-INF/views/admin/blog-form.jsp").forward(req, resp);

            } else if (sub.matches("blogs/\\d+/edit")) {
                int id = Integer.parseInt(sub.split("/")[1]);
                Blog blog = blogService.findById(id);
                if (blog == null) { resp.sendError(404); return; }
                req.setAttribute("blog", blog);
                req.getRequestDispatcher("/WEB-INF/views/admin/blog-form.jsp").forward(req, resp);

            } else if (sub.matches("members/\\d+")) {
                int blogId = Integer.parseInt(sub.split("/")[1]);
                if (!hasRoleInBlog(blogId, req, "owner", "admin")) { resp.sendError(403); return; }
                req.setAttribute("blog", blogService.findById(blogId));
                req.setAttribute("members", blogService.listMembers(blogId));
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

        if (!isLoggedIn(req)) { resp.sendError(403); return; }

        String sub = subPath(req);

        try {
            if (sub.equals("users/new")) {
                handleCreateUser(req, resp);

            } else if (sub.equals("blogs/new")) {
                handleCreateBlog(req, resp);

            } else if (sub.matches("blogs/\\d+/edit")) {
                int id = Integer.parseInt(sub.split("/")[1]);
                if (!hasRoleInBlog(id, req, "owner", "admin")) { resp.sendError(403); return; }
                blogService.update(id,
                        req.getParameter("name"),
                        req.getParameter("description"),
                        req.getParameter("accentColor"),
                        req.getParameter("visibility"),
                        "on".equals(req.getParameter("showPlatformHeader")));
                resp.sendRedirect(req.getContextPath() + "/admin/blogs/");

            } else if (sub.matches("members/\\d+/add")) {
                int blogId = Integer.parseInt(sub.split("/")[1]);
                if (!hasRoleInBlog(blogId, req, "owner", "admin")) { resp.sendError(403); return; }
                blogService.addMember(blogId, Integer.parseInt(req.getParameter("userId")), req.getParameter("role"));
                resp.sendRedirect(req.getContextPath() + "/admin/members/" + blogId);

            } else if (sub.matches("members/\\d+/\\d+/role")) {
                String[] p = sub.split("/");
                int blogId = Integer.parseInt(p[1]), memberId = Integer.parseInt(p[2]);
                if (!hasRoleInBlog(blogId, req, "owner", "admin")) { resp.sendError(403); return; }
                String current = userService.getRoleInBlog(memberId, blogId);
                if (!"owner".equals(current))
                    blogService.updateMemberRole(blogId, memberId, req.getParameter("role"));
                resp.sendRedirect(req.getContextPath() + "/admin/members/" + blogId);

            } else if (sub.matches("members/\\d+/\\d+/remove")) {
                String[] p = sub.split("/");
                int blogId = Integer.parseInt(p[1]), memberId = Integer.parseInt(p[2]);
                if (!hasRoleInBlog(blogId, req, "owner", "admin")) { resp.sendError(403); return; }
                String current = userService.getRoleInBlog(memberId, blogId);
                if (!"owner".equals(current))
                    blogService.removeMember(blogId, memberId);
                resp.sendRedirect(req.getContextPath() + "/admin/members/" + blogId);

            } else {
                resp.sendError(404);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ─── Handler ──────────────────────────────────────────────────

    private void handleCreateUser(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        if (username == null || username.isBlank() || password == null || password.isBlank()) {
            req.setAttribute("error", "Benutzername und Passwort sind Pflichtfelder.");
            req.setAttribute("blogs", blogService.listPublic());
            req.getRequestDispatcher("/WEB-INF/views/admin/user-form.jsp").forward(req, resp);
            return;
        }
        User created = userService.create(username.trim(), req.getParameter("displayName"),
                req.getParameter("email"), password);
        if (created == null) {
            req.setAttribute("error", "Benutzername oder E-Mail bereits vergeben.");
            req.setAttribute("blogs", blogService.listPublic());
            req.getRequestDispatcher("/WEB-INF/views/admin/user-form.jsp").forward(req, resp);
            return;
        }
        String role   = req.getParameter("role");
        String blogIdStr = req.getParameter("blogId");
        if (role != null && !role.isBlank() && blogIdStr != null && !blogIdStr.isBlank()) {
            blogService.addMember(Integer.parseInt(blogIdStr), created.id, role);
        }
        resp.sendRedirect(req.getContextPath() + "/admin/");
    }

    private void handleCreateBlog(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String slug   = req.getParameter("slug");
        String name   = req.getParameter("name");
        if (slug == null || slug.isBlank() || name == null || name.isBlank()) {
            req.setAttribute("error", "Slug und Name sind Pflichtfelder.");
            req.getRequestDispatcher("/WEB-INF/views/admin/blog-form.jsp").forward(req, resp);
            return;
        }
        Blog blog = blogService.create(slug.trim(), name.trim(),
                req.getParameter("description"), req.getParameter("accentColor"), userId(req));
        resp.sendRedirect(req.getContextPath() + "/admin/blogs/");
    }

    // ─── Hilfsmethoden ───────────────────────────────────────────

    private String subPath(HttpServletRequest req) {
        String info = req.getPathInfo();
        if (info == null || info.equals("/")) return "";
        return info.replaceFirst("^/", "").replaceFirst("/$", "");
    }
}
