package de.myblog.servlet;

import de.myblog.model.Article;
import de.myblog.model.Block;
import de.myblog.model.Blog;
import de.myblog.service.ArticleService;
import de.myblog.service.BlogService;
import de.myblog.service.TagService;
import de.myblog.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * /dashboard/                     → Meine Blogs
 * /dashboard/{blog-slug}/         → Artikelliste
 * /dashboard/{blog-slug}/new      → Neuer Artikel (GET: Dialog, POST: Anlegen)
 * /dashboard/{blog-slug}/settings → Blog-Einstellungen (GET/POST)
 * /dashboard/{blog-slug}/{id}     → Editor (GET: laden, POST: speichern)
 * /dashboard/{blog-slug}/{id}/publish|unpublish|delete  → Aktionen (POST)
 */
public class DashboardServlet extends HttpServlet {

    private final BlogService    blogService    = new BlogService();
    private final ArticleService articleService = new ArticleService();
    private final TagService     tagService     = new TagService();
    private final UserService    userService    = new UserService();

    // ─── Auth ─────────────────────────────────────────────────────

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && s.getAttribute("userId") != null;
    }

    private int userId(HttpServletRequest req) {
        return (int) req.getSession().getAttribute("userId");
    }

    /** Lädt die Rolle des Users in diesem Blog frisch aus der DB. */
    private String roleIn(int blogId, HttpServletRequest req) {
        try { return userService.getRoleInBlog(userId(req), blogId); }
        catch (Exception e) { return null; }
    }

    private boolean canPublish(String role) {
        return "owner".equals(role) || "admin".equals(role) || "author".equals(role);
    }

    private boolean canManage(String role) {
        return "owner".equals(role) || "admin".equals(role);
    }

    // ─── GET ──────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/login?next=" + req.getRequestURI());
            return;
        }

        String[] parts = splitPath(req);   // [] | [slug] | [slug,"new"] | [slug,id] | …

        try {
            if (parts.length == 0) {
                showMyBlogs(req, resp);

            } else if (parts.length == 1) {
                showBlogDashboard(req, resp, parts[0]);

            } else {
                String blogSlug = parts[0];
                String sub      = parts[1];

                Blog blog = requireBlogAccess(blogSlug, req, resp);
                if (blog == null) return;

                if ("new".equals(sub)) {
                    req.setAttribute("blog", blog);
                    req.setAttribute("role", roleIn(blog.id, req));
                    req.getRequestDispatcher("/WEB-INF/views/dashboard/editor.jsp").forward(req, resp);

                } else if ("settings".equals(sub)) {
                    req.setAttribute("blog", blog);
                    req.setAttribute("role", roleIn(blog.id, req));
                    req.getRequestDispatcher("/WEB-INF/views/dashboard/blog-settings.jsp").forward(req, resp);

                } else {
                    // /{id} oder /{id}/...  — nur erste Zahl nehmen
                    int id = Integer.parseInt(sub.split("/")[0]);
                    Article article = articleService.findById(id);
                    if (article == null || article.blogId != blog.id) { resp.sendError(404); return; }
                    article.tags = tagService.listByArticle(article.id);
                    String role = roleIn(blog.id, req);
                    req.setAttribute("blog",         blog);
                    req.setAttribute("article",      article);
                    req.setAttribute("role",         role);
                    req.setAttribute("canPublish",   canPublish(role));
                    req.setAttribute("canManage",    canManage(role));
                    req.setAttribute("blogTagNames", tagService.listNamesByBlog(blog.id));
                    req.getRequestDispatcher("/WEB-INF/views/dashboard/editor.jsp").forward(req, resp);
                }
            }
        } catch (NumberFormatException e) {
            resp.sendError(404);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ─── POST ─────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isLoggedIn(req)) { resp.sendError(403); return; }

        String[] parts = splitPath(req);

        try {
            // POST /dashboard/  → neuen Blog anlegen
            if (parts.length == 0) {
                handleCreateBlog(req, resp);
                return;
            }

            String blogSlug = parts[0];
            Blog blog = requireBlogAccess(blogSlug, req, resp);
            if (blog == null) return;

            String role = roleIn(blog.id, req);
            String sub  = parts.length > 1 ? parts[1] : "";

            if ("new".equals(sub)) {
                handleNewArticle(req, resp, blog);

            } else if ("settings".equals(sub)) {
                if (!canManage(role)) { resp.sendError(403); return; }
                handleBlogSettings(req, resp, blog);

            } else if (sub.matches("\\d+")) {
                handleSaveArticle(req, resp, blog, Integer.parseInt(sub));

            } else if (sub.matches("\\d+/publish")) {
                if (!canPublish(role)) { resp.sendError(403); return; }
                articleService.publish(Integer.parseInt(sub.split("/")[0]));
                resp.sendRedirect(req.getContextPath() + "/dashboard/" + blogSlug + "/");

            } else if (sub.matches("\\d+/unpublish")) {
                if (!canPublish(role)) { resp.sendError(403); return; }
                articleService.unpublish(Integer.parseInt(sub.split("/")[0]));
                resp.sendRedirect(req.getContextPath() + "/dashboard/" + blogSlug + "/");

            } else if (sub.matches("\\d+/delete")) {
                if (!canManage(role)) { resp.sendError(403); return; }
                articleService.delete(Integer.parseInt(sub.split("/")[0]));
                resp.sendRedirect(req.getContextPath() + "/dashboard/" + blogSlug + "/");

            } else {
                resp.sendError(404);
            }
        } catch (NumberFormatException e) {
            resp.sendError(404);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ─── Handler ──────────────────────────────────────────────────

    private void showMyBlogs(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        List<Blog> blogs = blogService.listForUser(userId(req));
        req.setAttribute("blogs", blogs);
        req.getRequestDispatcher("/WEB-INF/views/dashboard/my-blogs.jsp").forward(req, resp);
    }

    private void showBlogDashboard(HttpServletRequest req, HttpServletResponse resp,
                                   String blogSlug) throws Exception {
        Blog blog = requireBlogAccess(blogSlug, req, resp);
        if (blog == null) return;
        String role = roleIn(blog.id, req);
        List<Article> articles = articleService.listByBlog(blog.id);
        req.setAttribute("blog", blog);
        req.setAttribute("articles", articles);
        req.setAttribute("role", role);
        req.setAttribute("canPublish", canPublish(role));
        req.setAttribute("canManage",  canManage(role));
        req.getRequestDispatcher("/WEB-INF/views/dashboard/list.jsp").forward(req, resp);
    }

    private void handleCreateBlog(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String slug        = req.getParameter("slug");
        String name        = req.getParameter("name");
        String description = req.getParameter("description");
        String accent      = req.getParameter("accentColor");
        Blog blog = blogService.create(slug, name, description, accent, userId(req));
        resp.sendRedirect(req.getContextPath() + "/dashboard/" + blog.slug + "/");
    }

    private void handleNewArticle(HttpServletRequest req, HttpServletResponse resp,
                                  Blog blog) throws Exception {
        String title  = req.getParameter("title");
        String slug   = req.getParameter("slug");
        String accent = req.getParameter("accentColor");
        Article created = articleService.create(blog.id, userId(req), title, slug, accent);
        resp.sendRedirect(req.getContextPath() + "/dashboard/" + blog.slug + "/" + created.id);
    }

    private void handleSaveArticle(HttpServletRequest req, HttpServletResponse resp,
                                   Blog blog, int articleId) throws Exception {
        articleService.updateMeta(articleId,
                req.getParameter("title"),
                req.getParameter("subtitle"),
                req.getParameter("slug"),
                req.getParameter("accentColor"));

        String blocksJson = req.getParameter("blocks");
        if (blocksJson != null && !blocksJson.isBlank()) {
            articleService.saveBlocks(articleId, parseBlocks(articleId, blocksJson));
        }
        tagService.saveArticleTags(articleId, blog.id, req.getParameter("tags"));
        resp.sendRedirect(req.getContextPath() + "/dashboard/" + blog.slug + "/" + articleId);
    }

    private void handleBlogSettings(HttpServletRequest req, HttpServletResponse resp,
                                    Blog blog) throws Exception {
        blogService.update(blog.id,
                req.getParameter("name"),
                req.getParameter("description"),
                req.getParameter("accentColor"),
                req.getParameter("visibility"));
        resp.sendRedirect(req.getContextPath() + "/dashboard/" + blog.slug + "/");
    }

    // ─── Hilfsmethoden ───────────────────────────────────────────

    /**
     * Prüft ob der eingeloggte User Zugang zu diesem Blog hat.
     * Gibt null zurück und sendet 403/404 wenn nicht.
     */
    private Blog requireBlogAccess(String blogSlug, HttpServletRequest req,
                                   HttpServletResponse resp) throws Exception {
        Blog blog = blogService.findBySlug(blogSlug);
        if (blog == null) { resp.sendError(404); return null; }
        String role = roleIn(blog.id, req);
        if (role == null) { resp.sendError(403, "Kein Zugang zu diesem Blog"); return null; }
        return blog;
    }

    /** Zerlegt getPathInfo() in Segmente: "/main/42/publish" → ["main","42/publish"] */
    private String[] splitPath(HttpServletRequest req) {
        String info = req.getPathInfo();
        if (info == null || info.equals("/")) return new String[0];
        String trimmed = info.replaceAll("^/+", "").replaceAll("/+$", "");
        if (trimmed.isEmpty()) return new String[0];
        return trimmed.split("/", 2);
    }

    private List<Block> parseBlocks(int articleId, String json) {
        JSONObject root = new JSONObject(json);
        JSONArray arr   = root.optJSONArray("blocks");
        List<Block> list = new ArrayList<>();
        if (arr == null) return list;
        for (int i = 0; i < arr.length(); i++) {
            JSONObject e = arr.getJSONObject(i);
            Block b = new Block();
            b.articleId = articleId;
            b.position  = i;
            b.type      = e.getString("type");
            b.data      = e.optJSONObject("data") != null ? e.getJSONObject("data").toString() : "{}";
            list.add(b);
        }
        return list;
    }
}
