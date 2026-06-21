package de.myblog.servlet;

import de.myblog.model.Article;
import de.myblog.model.Blog;
import de.myblog.model.Comment;
import de.myblog.service.ArticleService;
import de.myblog.service.BlogService;
import de.myblog.service.CommentService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * Default-Servlet (/) — routet alle öffentlichen Seiten.
 *
 * GET  /                         → Platform-Home
 * GET  /{blog-slug}/             → Blog-Index
 * GET  /{blog-slug}/{article}    → Artikel-Ansicht
 * POST /{blog-slug}/{article}    → Kommentar abschicken / löschen
 */
public class BlogPlatformServlet extends HttpServlet {

    private final BlogService    blogService    = new BlogService();
    private final ArticleService articleService = new ArticleService();
    private final CommentService commentService = new CommentService();

    // ─── GET ──────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getServletPath();
        if (path == null) path = "/";
        String[] parts = splitPath(path);

        try {
            if (parts.length == 0) {
                showPlatformHome(req, resp);
            } else if (parts.length == 1) {
                showBlogIndex(req, resp, parts[0]);
            } else {
                showArticle(req, resp, parts[0], parts[1]);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ─── POST (Kommentare) ────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Login erforderlich
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login?next=" + req.getRequestURI());
            return;
        }
        int userId = (int) s.getAttribute("userId");

        String path  = req.getServletPath();
        String[] parts = splitPath(path);
        if (parts.length < 2) { resp.sendError(404); return; }

        String blogSlug    = parts[0];
        String articleSlug = parts[1];

        try {
            Blog blog = blogService.findBySlug(blogSlug);
            if (blog == null) { resp.sendError(404); return; }

            Article article = articleService.findBySlug(blog.id, articleSlug);
            if (article == null || !"published".equals(article.status)) {
                resp.sendError(404); return;
            }

            String action   = req.getParameter("_action");
            String redirect = req.getContextPath() + "/" + blogSlug + "/" + articleSlug + "#comments";

            if ("delete".equals(action)) {
                String idStr = req.getParameter("commentId");
                if (idStr != null) commentService.delete(Integer.parseInt(idStr), userId);

            } else {
                String body      = req.getParameter("body");
                String parentStr = req.getParameter("parentId");
                Integer parentId = (parentStr != null && !parentStr.isBlank())
                        ? Integer.parseInt(parentStr) : null;
                if (body != null && !body.isBlank())
                    commentService.create(article.id, userId, body.trim(), parentId);
            }

            resp.sendRedirect(redirect);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ─── Handler ──────────────────────────────────────────────────

    private void showPlatformHome(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        req.setAttribute("blogs", blogService.listPublic());
        req.getRequestDispatcher("/WEB-INF/views/index.jsp").forward(req, resp);
    }

    private void showBlogIndex(HttpServletRequest req, HttpServletResponse resp, String blogSlug)
            throws Exception {
        Blog blog = blogService.findBySlug(blogSlug);
        if (blog == null || "private".equals(blog.visibility)) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND); return;
        }
        List<Article> articles = articleService.listByBlog(blog.id);
        articles.removeIf(a -> !"published".equals(a.status));
        req.setAttribute("blog", blog);
        req.setAttribute("articles", articles);
        req.getRequestDispatcher("/WEB-INF/views/blog-index.jsp").forward(req, resp);
    }

    private void showArticle(HttpServletRequest req, HttpServletResponse resp,
                             String blogSlug, String articleSlug) throws Exception {
        Blog blog = blogService.findBySlug(blogSlug);
        if (blog == null || "private".equals(blog.visibility)) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND); return;
        }
        Article article = articleService.findBySlug(blog.id, articleSlug);
        if (article == null || !"published".equals(article.status)) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND); return;
        }
        List<Comment> comments = commentService.listByArticle(article.id);
        req.setAttribute("blog",     blog);
        req.setAttribute("article",  article);
        req.setAttribute("comments", comments);
        req.getRequestDispatcher("/WEB-INF/views/article.jsp").forward(req, resp);
    }

    // ─── Hilfsmethoden ───────────────────────────────────────────

    private String[] splitPath(String path) {
        String trimmed = path.replaceAll("^/+", "").replaceAll("/+$", "");
        if (trimmed.isEmpty()) return new String[0];
        return trimmed.split("/", 2);
    }
}
