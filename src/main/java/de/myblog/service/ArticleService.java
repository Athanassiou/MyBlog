package de.myblog.service;

import de.myblog.model.Article;
import de.myblog.model.Block;
import de.myblog.util.DB;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ArticleService {

    // ─── Lesen ───────────────────────────────────────────────────

    /** Volltextsuche auf Titel, Untertitel und Tag-Namen. */
    public List<Article> search(int blogId, String query) throws SQLException {
        String like = "%" + query.toLowerCase() + "%";
        List<Article> list = new ArrayList<>();
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT DISTINCT a.id,a.blog_id,a.author_id,a.slug,a.title,a.subtitle," +
                     "a.accent_color,a.status,a.created_at,a.published_at,0 AS comment_count " +
                     "FROM articles a " +
                     "LEFT JOIN article_tags at ON at.article_id=a.id " +
                     "LEFT JOIN tags t ON t.id=at.tag_id " +
                     "WHERE a.blog_id=? AND a.status='published' " +
                     "AND (lower(a.title) LIKE ? OR lower(coalesce(a.subtitle,'')) LIKE ? " +
                     "     OR lower(coalesce(t.name,'')) LIKE ?) " +
                     "ORDER BY a.published_at DESC NULLS LAST")) {
            ps.setInt(1, blogId);
            ps.setString(2, like);
            ps.setString(3, like);
            ps.setString(4, like);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapArticle(rs));
            }
        }
        return list;
    }

    public List<Article> listByBlog(int blogId) throws SQLException {
        List<Article> list = new ArrayList<>();
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT a.id,a.blog_id,a.author_id,a.slug,a.title,a.subtitle," +
                     "a.accent_color,a.status,a.created_at,a.published_at," +
                     "COUNT(cm.id) AS comment_count " +
                     "FROM articles a LEFT JOIN comments cm ON cm.article_id=a.id " +
                     "WHERE a.blog_id=? GROUP BY a.id ORDER BY a.created_at DESC")) {
            ps.setInt(1, blogId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Article a = mapArticle(rs);
                    a.commentCount = rs.getInt("comment_count");
                    list.add(a);
                }
            }
        }
        return list;
    }

    public Article findBySlug(int blogId, String slug) throws SQLException {
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT id,blog_id,author_id,slug,title,subtitle,accent_color,status,created_at,published_at " +
                     "FROM articles WHERE blog_id=? AND slug=?")) {
            ps.setInt(1, blogId);
            ps.setString(2, slug);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Article a = mapArticle(rs);
                a.blocks = loadBlocks(c, a.id);
                return a;
            }
        }
    }

    public Article findById(int id) throws SQLException {
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT id,blog_id,author_id,slug,title,subtitle,accent_color,status,created_at,published_at " +
                     "FROM articles WHERE id=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Article a = mapArticle(rs);
                a.blocks = loadBlocks(c, a.id);
                return a;
            }
        }
    }

    // ─── Schreiben ───────────────────────────────────────────────

    public Article create(int blogId, int authorId, String title, String slug, String accentColor) throws SQLException {
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "INSERT INTO articles (blog_id,author_id,title,slug,accent_color,status) VALUES (?,?,?,?,?,'draft') RETURNING id")) {
            ps.setInt(1, blogId);
            ps.setInt(2, authorId);
            ps.setString(3, title);
            ps.setString(4, slug);
            ps.setString(5, accentColor != null ? accentColor : "#e5a00d");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return findById(rs.getInt(1));
            }
        }
        return null;
    }

    /** Ersetzt alle Blöcke eines Artikels (beim Speichern aus dem Editor). */
    public void saveBlocks(int articleId, List<Block> blocks) throws SQLException {
        try (Connection c = DB.get()) {
            c.setAutoCommit(false);
            try {
                try (PreparedStatement del = c.prepareStatement("DELETE FROM blocks WHERE article_id=?")) {
                    del.setInt(1, articleId);
                    del.executeUpdate();
                }
                try (PreparedStatement ins = c.prepareStatement(
                        "INSERT INTO blocks (article_id,position,type,data) VALUES (?,?,?,?::jsonb)")) {
                    for (int i = 0; i < blocks.size(); i++) {
                        Block b = blocks.get(i);
                        ins.setInt(1, articleId);
                        ins.setInt(2, i);
                        ins.setString(3, b.type);
                        ins.setString(4, b.data);
                        ins.addBatch();
                    }
                    ins.executeBatch();
                }
                c.commit();
            } catch (SQLException e) {
                c.rollback();
                throw e;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    public void updateMeta(int articleId, String title, String subtitle, String slug, String accentColor) throws SQLException {
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "UPDATE articles SET title=?,subtitle=?,slug=?,accent_color=? WHERE id=?")) {
            ps.setString(1, title);
            ps.setString(2, subtitle);
            ps.setString(3, slug);
            ps.setString(4, accentColor);
            ps.setInt(5, articleId);
            ps.executeUpdate();
        }
    }

    public void publish(int articleId) throws SQLException {
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "UPDATE articles SET status='published', published_at=NOW() WHERE id=?")) {
            ps.setInt(1, articleId);
            ps.executeUpdate();
        }
    }

    public void unpublish(int articleId) throws SQLException {
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "UPDATE articles SET status='draft', published_at=NULL WHERE id=?")) {
            ps.setInt(1, articleId);
            ps.executeUpdate();
        }
    }

    public void delete(int articleId) throws SQLException {
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement("DELETE FROM articles WHERE id=?")) {
            ps.setInt(1, articleId);
            ps.executeUpdate();
        }
    }

    // ─── Hilfsmethoden ───────────────────────────────────────────

    private List<Block> loadBlocks(Connection c, int articleId) throws SQLException {
        List<Block> blocks = new ArrayList<>();
        try (PreparedStatement ps = c.prepareStatement(
                "SELECT id,article_id,position,type,data::text FROM blocks WHERE article_id=? ORDER BY position")) {
            ps.setInt(1, articleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Block b = new Block();
                    b.id        = rs.getInt("id");
                    b.articleId = rs.getInt("article_id");
                    b.position  = rs.getInt("position");
                    b.type      = rs.getString("type");
                    b.data      = rs.getString("data");
                    blocks.add(b);
                }
            }
        }
        return blocks;
    }

    private Article mapArticle(ResultSet rs) throws SQLException {
        Article a = new Article();
        a.id          = rs.getInt("id");
        a.blogId      = rs.getInt("blog_id");
        a.authorId    = rs.getInt("author_id");
        a.slug        = rs.getString("slug");
        a.title       = rs.getString("title");
        a.subtitle    = rs.getString("subtitle");
        a.accentColor = rs.getString("accent_color");
        a.status      = rs.getString("status");
        Timestamp ca  = rs.getTimestamp("created_at");
        Timestamp pa  = rs.getTimestamp("published_at");
        if (ca != null) a.createdAt   = ca.toLocalDateTime();
        if (pa != null) a.publishedAt = pa.toLocalDateTime();
        return a;
    }
}
