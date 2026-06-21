package de.myblog.service;

import de.myblog.model.BlogMember;
import de.myblog.model.User;
import de.myblog.util.DB;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BlogService {

    public List<BlogMember> listMembers(int blogId) throws SQLException {
        List<BlogMember> list = new ArrayList<>();
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT u.id,u.username,u.display_name,u.email,u.avatar_url,u.created_at,bm.role " +
                     "FROM blog_members bm JOIN users u ON u.id=bm.user_id " +
                     "WHERE bm.blog_id=? ORDER BY bm.role,u.username")) {
            ps.setInt(1, blogId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BlogMember m = new BlogMember();
                    m.blogId = blogId;
                    m.role   = rs.getString("role");
                    User u   = new User();
                    u.id          = rs.getInt("id");
                    u.username    = rs.getString("username");
                    u.displayName = rs.getString("display_name");
                    u.email       = rs.getString("email");
                    u.avatarUrl   = rs.getString("avatar_url");
                    Timestamp ts  = rs.getTimestamp("created_at");
                    if (ts != null) u.createdAt = ts.toLocalDateTime();
                    m.user = u;
                    list.add(m);
                }
            }
        }
        return list;
    }

    public void addMember(int blogId, int userId, String role) throws SQLException {
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "INSERT INTO blog_members (blog_id,user_id,role) VALUES (?,?,?) " +
                     "ON CONFLICT (blog_id,user_id) DO UPDATE SET role=EXCLUDED.role")) {
            ps.setInt(1, blogId);
            ps.setInt(2, userId);
            ps.setString(3, role);
            ps.executeUpdate();
        }
    }

    public void updateMemberRole(int blogId, int userId, String role) throws SQLException {
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "UPDATE blog_members SET role=? WHERE blog_id=? AND user_id=?")) {
            ps.setString(1, role);
            ps.setInt(2, blogId);
            ps.setInt(3, userId);
            ps.executeUpdate();
        }
    }

    public void removeMember(int blogId, int userId) throws SQLException {
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "DELETE FROM blog_members WHERE blog_id=? AND user_id=?")) {
            ps.setInt(1, blogId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }
}
