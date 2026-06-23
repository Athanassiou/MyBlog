package de.myblog.servlet;

import de.myblog.model.Article;
import de.myblog.model.Block;
import de.myblog.service.ArticleService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

/**
 * JSON API für EditorJS.
 *
 * GET  /api/article/{id}/blocks   → Blöcke laden
 * POST /api/article/{id}/blocks   → Blöcke speichern (EditorJS-JSON im Body)
 */
public class ApiServlet extends HttpServlet {

    private final ArticleService articleService = new ArticleService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String[] parts = req.getPathInfo().replaceFirst("^/", "").split("/");
        // /api/session
        if (parts.length == 1 && parts[0].equals("session")) {
            HttpSession s = req.getSession(false);
            if (s != null && s.getAttribute("userId") != null) {
                json(resp, 200, new JSONObject()
                        .put("loggedIn", true)
                        .put("displayName", s.getAttribute("displayName"))
                        .put("username", s.getAttribute("username"))
                        .toString());
            } else {
                json(resp, 200, new JSONObject().put("loggedIn", false).toString());
            }
            return;
        }
        // /api/article/{id}/blocks
        if (parts.length == 3 && parts[0].equals("article") && parts[2].equals("blocks")) {
            try {
                int id = Integer.parseInt(parts[1]);
                Article a = articleService.findById(id);
                if (a == null) { jsonError(resp, 404, "Nicht gefunden"); return; }
                JSONArray arr = new JSONArray();
                if (a.blocks != null) {
                    for (Block b : a.blocks) {
                        arr.put(new JSONObject()
                                .put("type", b.type)
                                .put("data", new JSONObject(b.data)));
                    }
                }
                json(resp, 200, new JSONObject().put("blocks", arr).toString());
            } catch (NumberFormatException e) {
                jsonError(resp, 400, "Ungültige ID");
            } catch (Exception e) {
                throw new ServletException(e);
            }
        } else {
            jsonError(resp, 404, "Unbekannte Route");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isLoggedIn(req)) { jsonError(resp, 403, "Nicht angemeldet"); return; }

        String[] parts = req.getPathInfo().replaceFirst("^/", "").split("/");
        if (parts.length == 3 && parts[0].equals("article") && parts[2].equals("blocks")) {
            try {
                int id = Integer.parseInt(parts[1]);
                String body = new String(req.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
                JSONObject root = new JSONObject(body);
                JSONArray arr   = root.optJSONArray("blocks");
                List<Block> blocks = new ArrayList<>();
                if (arr != null) {
                    for (int i = 0; i < arr.length(); i++) {
                        JSONObject entry = arr.getJSONObject(i);
                        Block b = new Block();
                        b.articleId = id;
                        b.position  = i;
                        b.type      = entry.getString("type");
                        b.data      = entry.optJSONObject("data") != null
                                      ? entry.getJSONObject("data").toString() : "{}";
                        blocks.add(b);
                    }
                }
                articleService.saveBlocks(id, blocks);
                json(resp, 200, "{\"ok\":true}");
            } catch (NumberFormatException e) {
                jsonError(resp, 400, "Ungültige ID");
            } catch (Exception e) {
                throw new ServletException(e);
            }
        } else {
            jsonError(resp, 404, "Unbekannte Route");
        }
    }

    // ─── Hilfsmethoden ───────────────────────────────────────────

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && s.getAttribute("userId") != null;
    }

    private void json(HttpServletResponse resp, int status, String body) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write(body);
    }

    private void jsonError(HttpServletResponse resp, int status, String msg) throws IOException {
        json(resp, status, new JSONObject().put("error", msg).toString());
    }
}
