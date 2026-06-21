package de.myblog.servlet;

import de.myblog.model.Article;
import de.myblog.service.ArticleService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * Handles /MyBlog/ (platform home) and /MyBlog/{slug}/{article-slug} (article view).
 * Stufe 1: single-blog mode, blogId=1 hardcoded.
 */
public class BlogPlatformServlet extends HttpServlet {

    private static final int BLOG_ID = 1;

    private final ArticleService articleService = new ArticleService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Bei Mapping auf "/" liefert getPathInfo() immer null — getServletPath() verwenden
        String path = req.getServletPath();
        if (path == null || path.isEmpty() || path.equals("/")) {
            showIndex(req, resp);
            return;
        }

        // /MyBlog/{article-slug}
        String articleSlug = path.replaceFirst("^/", "").replaceFirst("/$", "");
        try {
            Article article = articleService.findBySlug(BLOG_ID, articleSlug);
            if (article == null || !"published".equals(article.status)) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            req.setAttribute("article", article);
            req.getRequestDispatcher("/WEB-INF/views/article.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void showIndex(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            List<Article> articles = articleService.listByBlog(BLOG_ID);
            articles.removeIf(a -> !"published".equals(a.status));
            req.setAttribute("articles", articles);
            req.getRequestDispatcher("/WEB-INF/views/index.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
