package de.myblog.service;

import de.myblog.model.Comment;
import de.myblog.util.DB;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CommentService {

    public List<Comment> listByArticle(int articleId) throws SQLException {
        List<Comment> list = new ArrayList<>();
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT cm.id, cm.article_id, cm.author_id, cm.parent_id, cm.body, cm.created_at, " +
                     "u.username, u.display_name " +
                     "FROM comments cm LEFT JOIN users u ON u.id = cm.author_id " +
                     "WHERE cm.article_id = ? ORDER BY cm.created_at ASC")) {
            ps.setInt(1, articleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Comment cm = new Comment();
                    cm.id          = rs.getInt("id");
                    cm.articleId   = rs.getInt("article_id");
                    cm.authorId    = rs.getInt("author_id");
                    int pid = rs.getInt("parent_id");
                    cm.parentId    = rs.wasNull() ? null : pid;
                    cm.body        = rs.getString("body");
                    Timestamp ts   = rs.getTimestamp("created_at");
                    if (ts != null) cm.createdAt = ts.toLocalDateTime();
                    cm.authorUsername    = rs.getString("username");
                    cm.authorDisplayName = rs.getString("display_name");
                    list.add(cm);
                }
            }
        }
        return list;
    }

    public void create(int articleId, int authorId, String body, Integer parentId) throws SQLException {
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "INSERT INTO comments (article_id, author_id, parent_id, body) VALUES (?,?,?,?)")) {
            ps.setInt(1, articleId);
            ps.setInt(2, authorId);
            if (parentId != null) ps.setInt(3, parentId); else ps.setNull(3, Types.INTEGER);
            ps.setString(4, body);
            ps.executeUpdate();
        }
    }

    /** Löscht nur eigene Kommentare (author_id muss übereinstimmen). */
    public void delete(int commentId, int requestingUserId) throws SQLException {
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "DELETE FROM comments WHERE id = ? AND author_id = ?")) {
            ps.setInt(1, commentId);
            ps.setInt(2, requestingUserId);
            ps.executeUpdate();
        }
    }
}
