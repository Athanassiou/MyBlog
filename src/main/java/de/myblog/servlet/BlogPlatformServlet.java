package de.myblog.servlet;

import de.myblog.model.Article;
import de.myblog.model.Blog;
import de.myblog.service.ArticleService;
import de.myblog.service.BlogService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * Default-Servlet (/) — routet alle öffentlichen Seiten.
 *
 * /                         → Platform-Home (alle öffentlichen Blogs)
 * /{blog-slug}/             → Blog-Index (Artikelliste)
 * /{blog-slug}/{article}    → Artikel-Ansicht
 *
 * Explizit gemappte Servlets (/login, /dashboard/*, /api/*, /admin/*, /upload, /files/*)
 * werden von Tomcat vorrangig bedient und kommen hier nie an.
 */
public class BlogPlatformServlet extends HttpServlet {

    private final BlogService    blogService    = new BlogService();
    private final ArticleService articleService = new ArticleService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // getServletPath() liefert den vollständigen Pfad nach dem Context-Root
        String path = req.getServletPath();
        if (path == null) path = "/";

        // Pfad in Segmente zerlegen, leere Teile ignorieren
        String[] parts = splitPath(path);   // z.B. [] | ["main"] | ["main","artikel-slug"]

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

    // ─── Platform-Home ────────────────────────────────────────────

    private void showPlatformHome(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        List<Blog> blogs = blogService.listPublic();
        req.setAttribute("blogs", blogs);
        req.getRequestDispatcher("/WEB-INF/views/index.jsp").forward(req, resp);
    }

    // ─── Blog-Index ───────────────────────────────────────────────

    private void showBlogIndex(HttpServletRequest req, HttpServletResponse resp, String blogSlug)
            throws Exception {
        Blog blog = blogService.findBySlug(blogSlug);
        if (blog == null || "private".equals(blog.visibility)) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        List<Article> articles = articleService.listByBlog(blog.id);
        articles.removeIf(a -> !"published".equals(a.status));
        req.setAttribute("blog", blog);
        req.setAttribute("articles", articles);
        req.getRequestDispatcher("/WEB-INF/views/blog-index.jsp").forward(req, resp);
    }

    // ─── Artikel-Ansicht ──────────────────────────────────────────

    private void showArticle(HttpServletRequest req, HttpServletResponse resp,
                             String blogSlug, String articleSlug)
            throws Exception {
        Blog blog = blogService.findBySlug(blogSlug);
        if (blog == null || "private".equals(blog.visibility)) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        Article article = articleService.findBySlug(blog.id, articleSlug);
        if (article == null || !"published".equals(article.status)) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        req.setAttribute("blog", blog);
        req.setAttribute("article", article);
        req.getRequestDispatcher("/WEB-INF/views/article.jsp").forward(req, resp);
    }

    // ─── Hilfsmethoden ───────────────────────────────────────────

    private String[] splitPath(String path) {
        // "/" → []  "/main/" → ["main"]  "/main/artikel" → ["main","artikel"]
        String trimmed = path.replaceAll("^/+", "").replaceAll("/+$", "");
        if (trimmed.isEmpty()) return new String[0];
        return trimmed.split("/", 2);
    }
}
