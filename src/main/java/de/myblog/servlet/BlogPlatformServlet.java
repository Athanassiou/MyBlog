package de.myblog.servlet;

import de.myblog.model.Article;
import de.myblog.model.Blog;
import de.myblog.model.Comment;
import de.myblog.model.Tag;
import de.myblog.service.ArticleService;
import de.myblog.service.BlogService;
import de.myblog.service.CommentService;
import de.myblog.service.TagService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

/**
 * GET  /                           → Platform-Home
 * GET  /{blog-slug}/               → Blog-Index  (?q= Suche)
 * GET  /{blog-slug}/feed           → RSS 2.0
 * GET  /{blog-slug}/tag/{name}     → Tag-Filter
 * GET  /{blog-slug}/{article}      → Artikel-Ansicht
 * POST /{blog-slug}/{article}      → Kommentar abschicken / löschen
 */
public class BlogPlatformServlet extends HttpServlet {

    private final BlogService    blogService    = new BlogService();
    private final ArticleService articleService = new ArticleService();
    private final CommentService commentService = new CommentService();
    private final TagService     tagService     = new TagService();

    private static final DateTimeFormatter RSS_FMT =
            DateTimeFormatter.ofPattern("EEE, dd MMM yyyy HH:mm:ss Z",
                    java.util.Locale.ENGLISH);

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
                String q = req.getParameter("q");
                if (q != null && !q.isBlank())
                    showSearch(req, resp, parts[0], q.trim());
                else
                    showBlogHome(req, resp, parts[0]);

            } else {
                String blogSlug = parts[0];
                String sub      = parts[1];   // "feed" | "list" | "tag/xyz" | article-slug

                if ("feed".equals(sub)) {
                    showRss(req, resp, blogSlug);
                } else if ("home".equals(sub)) {
                    resp.sendRedirect(req.getContextPath() + "/" + blogSlug + "/");
                } else if ("list".equals(sub)) {
                    showBlogIndex(req, resp, blogSlug);
                } else if (sub.startsWith("tag/")) {
                    showTagFilter(req, resp, blogSlug, sub.substring(4));
                } else {
                    showArticle(req, resp, blogSlug, sub);
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ─── POST (Kommentare) ────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login?next=" + req.getRequestURI());
            return;
        }
        int userId = (int) s.getAttribute("userId");

        String[] parts = splitPath(req.getServletPath());
        if (parts.length < 2) { resp.sendError(404); return; }

        try {
            Blog    blog    = blogService.findBySlug(parts[0]);
            if (blog == null) { resp.sendError(404); return; }
            Article article = articleService.findBySlug(blog.id, parts[1]);
            if (article == null || !"published".equals(article.status)) {
                resp.sendError(404); return;
            }

            String action   = req.getParameter("_action");
            String redirect = req.getContextPath() + "/" + parts[0] + "/" + parts[1] + "#comments";

            if ("delete".equals(action)) {
                String idStr = req.getParameter("commentId");
                if (idStr != null) commentService.delete(Integer.parseInt(idStr), userId);
            } else {
                String  body      = req.getParameter("body");
                String  parentStr = req.getParameter("parentId");
                Integer parentId  = (parentStr != null && !parentStr.isBlank())
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
        Blog blog = findPublicBlog(blogSlug, resp); if (blog == null) return;

        List<Article> articles = articleService.listByBlog(blog.id);
        articles.removeIf(a -> !"published".equals(a.status));

        Map<Integer, List<Tag>> tagMap = tagService.mapByBlog(blog.id);
        articles.forEach(a -> a.tags = tagMap.getOrDefault(a.id, java.util.Collections.emptyList()));

        req.setAttribute("blog", blog);
        req.setAttribute("articles", articles);
        req.setAttribute("tagNames", tagService.listNamesByBlog(blog.id));
        req.getRequestDispatcher("/WEB-INF/views/blog-index.jsp").forward(req, resp);
    }

    private void showBlogHome(HttpServletRequest req, HttpServletResponse resp, String blogSlug)
            throws Exception {
        Blog blog = findPublicBlog(blogSlug, resp); if (blog == null) return;

        List<Article> articles = articleService.listByBlog(blog.id);
        articles.removeIf(a -> !"published".equals(a.status));
        articles.sort((a, b) -> {
            if (a.publishedAt == null) return 1;
            if (b.publishedAt == null) return -1;
            return b.publishedAt.compareTo(a.publishedAt);
        });

        int split = Math.min(6, articles.size());
        List<Article> recent = articles.subList(0, split);
        List<Article> older  = articles.subList(split, articles.size());

        java.util.List<Integer> ids = new java.util.ArrayList<>();
        for (Article a : articles) ids.add(a.id);
        java.util.Map<Integer,String> images = articleService.findFirstImages(ids);

        req.setAttribute("blog",    blog);
        req.setAttribute("recent",  recent);
        req.setAttribute("older",   older);
        req.setAttribute("images",  images);
        req.getRequestDispatcher("/WEB-INF/views/blog-home.jsp").forward(req, resp);
    }

    private void showSearch(HttpServletRequest req, HttpServletResponse resp,
                            String blogSlug, String query) throws Exception {
        Blog blog = findPublicBlog(blogSlug, resp); if (blog == null) return;

        List<Article> articles = articleService.search(blog.id, query);
        Map<Integer, List<Tag>> tagMap = tagService.mapByBlog(blog.id);
        articles.forEach(a -> a.tags = tagMap.getOrDefault(a.id, java.util.Collections.emptyList()));

        req.setAttribute("blog", blog);
        req.setAttribute("articles", articles);
        req.setAttribute("searchQuery", query);
        req.setAttribute("tagNames", tagService.listNamesByBlog(blog.id));
        req.getRequestDispatcher("/WEB-INF/views/blog-index.jsp").forward(req, resp);
    }

    private void showTagFilter(HttpServletRequest req, HttpServletResponse resp,
                               String blogSlug, String tagName) throws Exception {
        Blog blog = findPublicBlog(blogSlug, resp); if (blog == null) return;

        // Artikel mit diesem Tag holen
        List<Article> articles;
        try (java.sql.Connection c = de.myblog.util.DB.get();
             java.sql.PreparedStatement ps = c.prepareStatement(
                     "SELECT DISTINCT a.id,a.blog_id,a.author_id,a.slug,a.title,a.subtitle," +
                     "a.accent_color,a.status,a.created_at,a.published_at,0 AS comment_count " +
                     "FROM articles a " +
                     "JOIN article_tags at ON at.article_id=a.id " +
                     "JOIN tags t ON t.id=at.tag_id " +
                     "WHERE a.blog_id=? AND a.status='published' " +
                     "AND lower(t.name)=lower(?) " +
                     "ORDER BY a.published_at DESC NULLS LAST")) {
            ps.setInt(1, blog.id);
            ps.setString(2, tagName);
            articles = new java.util.ArrayList<>();
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                // use reflection-free approach: re-use ArticleService mapArticle via listByBlog filter
                // actually we need direct mapping — inline it here
                while (rs.next()) {
                    Article a = new Article();
                    a.id          = rs.getInt("id");
                    a.blogId      = rs.getInt("blog_id");
                    a.authorId    = rs.getInt("author_id");
                    a.slug        = rs.getString("slug");
                    a.title       = rs.getString("title");
                    a.subtitle    = rs.getString("subtitle");
                    a.accentColor = rs.getString("accent_color");
                    a.status      = rs.getString("status");
                    java.sql.Timestamp ca = rs.getTimestamp("created_at");
                    if (ca != null) a.createdAt = ca.toLocalDateTime();
                    java.sql.Timestamp pa = rs.getTimestamp("published_at");
                    if (pa != null) a.publishedAt = pa.toLocalDateTime();
                    articles.add(a);
                }
            }
        }
        Map<Integer, List<Tag>> tagMap = tagService.mapByBlog(blog.id);
        articles.forEach(a -> a.tags = tagMap.getOrDefault(a.id, java.util.Collections.emptyList()));

        req.setAttribute("blog",        blog);
        req.setAttribute("articles",    articles);
        req.setAttribute("filterTag",   tagName);
        req.setAttribute("tagNames",    tagService.listNamesByBlog(blog.id));
        req.getRequestDispatcher("/WEB-INF/views/blog-index.jsp").forward(req, resp);
    }

    private void showArticle(HttpServletRequest req, HttpServletResponse resp,
                             String blogSlug, String articleSlug) throws Exception {
        Blog blog = findPublicBlog(blogSlug, resp); if (blog == null) return;

        Article article = articleService.findBySlug(blog.id, articleSlug);
        if (article == null || !"published".equals(article.status)) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND); return;
        }
        List<Comment> comments = commentService.listByArticle(article.id);
        List<Tag>     tags     = tagService.listByArticle(article.id);
        article.tags = tags;
        Article[] neighbours = articleService.findNeighbours(blog.id, article.publishedAt, article.id);

        req.setAttribute("blog",     blog);
        req.setAttribute("article",  article);
        req.setAttribute("comments", comments);
        req.setAttribute("prevArticle", neighbours[0]);
        req.setAttribute("nextArticle", neighbours[1]);
        req.getRequestDispatcher("/WEB-INF/views/article.jsp").forward(req, resp);
    }

    private void showRss(HttpServletRequest req, HttpServletResponse resp,
                         String blogSlug) throws Exception {
        Blog blog = findPublicBlog(blogSlug, resp); if (blog == null) return;

        List<Article> articles = articleService.listByBlog(blog.id);
        articles.removeIf(a -> !"published".equals(a.status));

        String base = req.getScheme() + "://" + req.getServerName()
                + (req.getServerPort() == 80 || req.getServerPort() == 443 ? ""
                   : ":" + req.getServerPort())
                + req.getContextPath();
        String blogUrl = base + "/" + blogSlug + "/";

        resp.setContentType("application/rss+xml;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
        out.println("<rss version=\"2.0\" xmlns:atom=\"http://www.w3.org/2005/Atom\">");
        out.println("<channel>");
        out.println("<title>" + esc(blog.name) + "</title>");
        out.println("<link>" + blogUrl + "</link>");
        out.println("<atom:link href=\"" + base + "/" + blogSlug + "/feed\" rel=\"self\" type=\"application/rss+xml\"/>");
        if (blog.description != null) out.println("<description>" + esc(blog.description) + "</description>");
        out.println("<language>de</language>");
        for (Article a : articles) {
            out.println("<item>");
            out.println("<title>" + esc(a.title) + "</title>");
            out.println("<link>" + base + "/" + blogSlug + "/" + a.slug + "</link>");
            out.println("<guid isPermaLink=\"true\">" + base + "/" + blogSlug + "/" + a.slug + "</guid>");
            if (a.subtitle != null) out.println("<description>" + esc(a.subtitle) + "</description>");
            if (a.publishedAt != null) out.println("<pubDate>" +
                    a.publishedAt.atOffset(ZoneOffset.UTC).format(RSS_FMT) + "</pubDate>");
            out.println("</item>");
        }
        out.println("</channel></rss>");
    }

    // ─── Hilfsmethoden ───────────────────────────────────────────

    private Blog findPublicBlog(String slug, HttpServletResponse resp)
            throws Exception {
        Blog blog = blogService.findBySlug(slug);
        if (blog == null || "private".equals(blog.visibility)) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND); return null;
        }
        return blog;
    }

    private String[] splitPath(String path) {
        String trimmed = path.replaceAll("^/+", "").replaceAll("/+$", "");
        if (trimmed.isEmpty()) return new String[0];
        return trimmed.split("/", 2);
    }

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;");
    }
}
