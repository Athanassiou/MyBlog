package de.myblog.servlet;

import de.myblog.model.Article;
import de.myblog.model.Block;
import de.myblog.service.ArticleService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * /dashboard/             → Artikelliste
 * /dashboard/new          → neuer Artikel
 * /dashboard/{id}         → Artikel bearbeiten
 * /dashboard/{id}/publish → veröffentlichen / zurückziehen
 * /dashboard/{id}/delete  → löschen
 */
public class DashboardServlet extends HttpServlet {

    private static final int BLOG_ID = 1;

    private final ArticleService articleService = new ArticleService();

    // ─── Auth- und Rollen-Guards ──────────────────────────────────

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && s.getAttribute("userId") != null;
    }

    private String role(HttpServletRequest req) {
        Object r = req.getSession(false).getAttribute("userRole");
        return r != null ? (String) r : "";
    }

    /** owner, admin, author dürfen veröffentlichen */
    private boolean canPublish(HttpServletRequest req) {
        String r = role(req);
        return "owner".equals(r) || "admin".equals(r) || "author".equals(r);
    }

    /** owner und admin dürfen löschen und Mitglieder verwalten */
    private boolean canManage(HttpServletRequest req) {
        String r = role(req);
        return "owner".equals(r) || "admin".equals(r);
    }

    private void requireLogin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/login?next=" + req.getRequestURI());
    }

    // ─── GET ──────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isLoggedIn(req)) { requireLogin(req, resp); return; }

        String sub = subPath(req);   // "" | "new" | "123" | "123/publish" | …

        try {
            if (sub.isEmpty()) {
                showList(req, resp);
            } else if (sub.equals("new")) {
                req.getRequestDispatcher("/WEB-INF/views/dashboard/editor.jsp").forward(req, resp);
            } else {
                int id = Integer.parseInt(sub.split("/")[0]);
                Article article = articleService.findById(id);
                if (article == null) { resp.sendError(404); return; }
                req.setAttribute("article", article);
                req.getRequestDispatcher("/WEB-INF/views/dashboard/editor.jsp").forward(req, resp);
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

        String sub = subPath(req);

        try {
            if (sub.equals("new")) {
                handleNew(req, resp);
            } else if (sub.matches("\\d+")) {
                handleSave(req, resp, Integer.parseInt(sub));
            } else if (sub.matches("\\d+/publish")) {
                if (!canPublish(req)) { resp.sendError(403, "Keine Berechtigung zum Veröffentlichen"); return; }
                int id = Integer.parseInt(sub.split("/")[0]);
                articleService.publish(id);
                resp.sendRedirect(req.getContextPath() + "/dashboard/");
            } else if (sub.matches("\\d+/unpublish")) {
                if (!canPublish(req)) { resp.sendError(403, "Keine Berechtigung"); return; }
                int id = Integer.parseInt(sub.split("/")[0]);
                articleService.unpublish(id);
                resp.sendRedirect(req.getContextPath() + "/dashboard/");
            } else if (sub.matches("\\d+/delete")) {
                if (!canManage(req)) { resp.sendError(403, "Keine Berechtigung zum Löschen"); return; }
                int id = Integer.parseInt(sub.split("/")[0]);
                articleService.delete(id);
                resp.sendRedirect(req.getContextPath() + "/dashboard/");
            } else {
                resp.sendError(404);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ─── Handler ──────────────────────────────────────────────────

    private void showList(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        List<Article> articles = articleService.listByBlog(BLOG_ID);
        req.setAttribute("articles", articles);
        req.setAttribute("canPublish", canPublish(req));
        req.setAttribute("canManage",  canManage(req));
        req.getRequestDispatcher("/WEB-INF/views/dashboard/list.jsp").forward(req, resp);
    }

    private void handleNew(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        int userId = (int) req.getSession().getAttribute("userId");
        String title       = req.getParameter("title");
        String slug        = req.getParameter("slug");
        String accentColor = req.getParameter("accentColor");

        Article created = articleService.create(BLOG_ID, userId, title, slug, accentColor);
        resp.sendRedirect(req.getContextPath() + "/dashboard/" + created.id);
    }

    private void handleSave(HttpServletRequest req, HttpServletResponse resp, int articleId)
            throws Exception {
        String title       = req.getParameter("title");
        String subtitle    = req.getParameter("subtitle");
        String slug        = req.getParameter("slug");
        String accentColor = req.getParameter("accentColor");
        String blocksJson  = req.getParameter("blocks");   // EditorJS output JSON

        articleService.updateMeta(articleId, title, subtitle, slug, accentColor);

        if (blocksJson != null && !blocksJson.isBlank()) {
            List<Block> blocks = parseEditorJsBlocks(articleId, blocksJson);
            articleService.saveBlocks(articleId, blocks);
        }

        resp.sendRedirect(req.getContextPath() + "/dashboard/" + articleId);
    }

    // ─── Hilfsmethoden ───────────────────────────────────────────

    private String subPath(HttpServletRequest req) {
        String info = req.getPathInfo();
        if (info == null || info.equals("/")) return "";
        return info.replaceFirst("^/", "").replaceFirst("/$", "");
    }

    private List<Block> parseEditorJsBlocks(int articleId, String json) {
        JSONObject root = new JSONObject(json);
        JSONArray arr   = root.optJSONArray("blocks");
        List<Block> list = new ArrayList<>();
        if (arr == null) return list;
        for (int i = 0; i < arr.length(); i++) {
            JSONObject entry = arr.getJSONObject(i);
            Block b = new Block();
            b.articleId = articleId;
            b.position  = i;
            b.type      = entry.getString("type");
            b.data      = entry.optJSONObject("data") != null
                          ? entry.getJSONObject("data").toString()
                          : "{}";
            list.add(b);
        }
        return list;
    }
}
