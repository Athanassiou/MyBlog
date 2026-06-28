package de.myblog.service;

import de.myblog.model.Blog;
import de.myblog.model.BlogMember;
import de.myblog.model.User;
import de.myblog.util.DB;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BlogService {

    // ─── Blog-Abfragen ───────────────────────────────────────────

    public Blog findBySlug(String slug) throws SQLException {
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT id,slug,name,description,default_accent_color,cover_image,visibility,owner_id,created_at,show_platform_header " +
                     "FROM blogs WHERE slug=?")) {
            ps.setString(1, slug);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapBlog(rs) : null;
            }
        }
    }

    public Blog findById(int id) throws SQLException {
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT id,slug,name,description,default_accent_color,cover_image,visibility,owner_id,created_at,show_platform_header " +
                     "FROM blogs WHERE id=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapBlog(rs) : null;
            }
        }
    }

    /** Alle Blogs (für Admin-Ansicht), neueste zuerst. */
    public List<Blog> listAll() throws SQLException {
        List<Blog> list = new ArrayList<>();
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT id,slug,name,description,default_accent_color,cover_image,visibility,owner_id,created_at,show_platform_header " +
                     "FROM blogs ORDER BY created_at DESC")) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapBlog(rs));
            }
        }
        return list;
    }

    /** Alle öffentlichen Blogs, neueste zuerst. */
    public List<Blog> listPublic() throws SQLException {
        List<Blog> list = new ArrayList<>();
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT id,slug,name,description,default_accent_color,cover_image,visibility,owner_id,created_at,show_platform_header " +
                     "FROM blogs WHERE visibility='public' ORDER BY created_at DESC")) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapBlog(rs));
            }
        }
        return list;
    }

    /** Blogs in denen der User Mitglied ist, mit seiner Rolle. */
    public List<Blog> listForUser(int userId) throws SQLException {
        List<Blog> list = new ArrayList<>();
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT b.id,b.slug,b.name,b.description,b.default_accent_color,b.cover_image," +
                     "b.visibility,b.owner_id,b.created_at,b.show_platform_header,bm.role " +
                     "FROM blogs b JOIN blog_members bm ON b.id=bm.blog_id " +
                     "WHERE bm.user_id=? ORDER BY b.name")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Blog b = mapBlog(rs);
                    b.userRole = rs.getString("role");
                    list.add(b);
                }
            }
        }
        return list;
    }

    public Blog create(String slug, String name, String description,
                       String accentColor, int ownerId) throws SQLException {
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "INSERT INTO blogs (slug,name,description,default_accent_color,owner_id) " +
                     "VALUES (?,?,?,?,?) RETURNING id")) {
            ps.setString(1, slug);
            ps.setString(2, name);
            ps.setString(3, description);
            ps.setString(4, accentColor != null ? accentColor : "#e5a00d");
            ps.setInt(5, ownerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                int newId = rs.getInt(1);
                // Ersteller wird automatisch Owner
                addMember(newId, ownerId, "owner");
                return findById(newId);
            }
        }
    }

    public void update(int blogId, String name, String description,
                       String accentColor, String visibility,
                       boolean showPlatformHeader) throws SQLException {
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "UPDATE blogs SET name=?,description=?,default_accent_color=?,visibility=?,show_platform_header=? WHERE id=?")) {
            ps.setString(1, name);
            ps.setString(2, description);
            ps.setString(3, accentColor);
            ps.setString(4, visibility);
            ps.setBoolean(5, showPlatformHeader);
            ps.setInt(6, blogId);
            ps.executeUpdate();
        }
    }

    public void delete(int blogId) throws SQLException {
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement("DELETE FROM blogs WHERE id=?")) {
            ps.setInt(1, blogId);
            ps.executeUpdate();
        }
    }

    private Blog mapBlog(ResultSet rs) throws SQLException {
        Blog b = new Blog();
        b.id                 = rs.getInt("id");
        b.slug               = rs.getString("slug");
        b.name               = rs.getString("name");
        b.description        = rs.getString("description");
        b.defaultAccentColor = rs.getString("default_accent_color");
        b.coverImage         = rs.getString("cover_image");
        b.visibility         = rs.getString("visibility");
        b.ownerId             = rs.getInt("owner_id");
        b.showPlatformHeader  = rs.getBoolean("show_platform_header");
        Timestamp ts          = rs.getTimestamp("created_at");
        if (ts != null) b.createdAt = ts.toLocalDateTime();
        return b;
    }

    // ─── Mitglieder-Verwaltung ────────────────────────────────────

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
