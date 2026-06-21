package de.myblog.service;

import de.myblog.model.Tag;
import de.myblog.util.DB;

import java.sql.*;
import java.util.*;

public class TagService {

    /** Alle Tags eines Artikels. */
    public List<Tag> listByArticle(int articleId) throws SQLException {
        List<Tag> list = new ArrayList<>();
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT t.id, t.blog_id, t.name FROM tags t " +
                     "JOIN article_tags at ON at.tag_id = t.id " +
                     "WHERE at.article_id = ? ORDER BY t.name")) {
            ps.setInt(1, articleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    /**
     * Tags aller Artikel eines Blogs — Map: articleId → Tag-Liste.
     * Einmalige Abfrage statt N+1.
     */
    public Map<Integer, List<Tag>> mapByBlog(int blogId) throws SQLException {
        Map<Integer, List<Tag>> result = new LinkedHashMap<>();
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT at.article_id, t.id, t.blog_id, t.name FROM tags t " +
                     "JOIN article_tags at ON at.tag_id = t.id " +
                     "WHERE t.blog_id = ? ORDER BY at.article_id, t.name")) {
            ps.setInt(1, blogId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int aid = rs.getInt("article_id");
                    result.computeIfAbsent(aid, k -> new ArrayList<>()).add(map(rs));
                }
            }
        }
        return result;
    }

    /** Alle Tag-Namen eines Blogs (für Autocomplete). */
    public List<String> listNamesByBlog(int blogId) throws SQLException {
        List<String> names = new ArrayList<>();
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT name FROM tags WHERE blog_id=? ORDER BY name")) {
            ps.setInt(1, blogId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) names.add(rs.getString(1));
            }
        }
        return names;
    }

    /**
     * Setzt die Tags eines Artikels neu (löscht alte, fügt neue ein).
     * Tag-Namen werden als Komma-getrennte Zeichenkette übergeben.
     */
    public void saveArticleTags(int articleId, int blogId, String rawTags) throws SQLException {
        try (Connection c = DB.get()) {
            // Alte Verknüpfungen löschen
            try (PreparedStatement del = c.prepareStatement(
                    "DELETE FROM article_tags WHERE article_id = ?")) {
                del.setInt(1, articleId);
                del.executeUpdate();
            }
            if (rawTags == null || rawTags.isBlank()) return;

            for (String name : rawTags.split(",")) {
                name = name.strip();
                if (name.isEmpty()) continue;
                int tagId = findOrCreate(c, blogId, name);
                try (PreparedStatement ins = c.prepareStatement(
                        "INSERT INTO article_tags (article_id, tag_id) VALUES (?,?) ON CONFLICT DO NOTHING")) {
                    ins.setInt(1, articleId);
                    ins.setInt(2, tagId);
                    ins.executeUpdate();
                }
            }
        }
    }

    // ─── Hilfsmethoden ───────────────────────────────────────────

    private int findOrCreate(Connection c, int blogId, String name) throws SQLException {
        try (PreparedStatement sel = c.prepareStatement(
                "SELECT id FROM tags WHERE blog_id=? AND lower(name)=lower(?)")) {
            sel.setInt(1, blogId);
            sel.setString(2, name);
            try (ResultSet rs = sel.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        try (PreparedStatement ins = c.prepareStatement(
                "INSERT INTO tags (blog_id, name) VALUES (?,?) RETURNING id")) {
            ins.setInt(1, blogId);
            ins.setString(2, name);
            try (ResultSet rs = ins.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    private Tag map(ResultSet rs) throws SQLException {
        Tag t = new Tag();
        t.id     = rs.getInt("id");
        t.blogId = rs.getInt("blog_id");
        t.name   = rs.getString("name");
        return t;
    }
}
