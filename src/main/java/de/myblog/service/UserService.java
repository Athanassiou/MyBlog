package de.myblog.service;

import de.myblog.model.User;
import de.myblog.util.DB;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.*;

public class UserService {

    public User findByUsername(String username) throws SQLException {
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT id,username,display_name,email,password_hash,avatar_url,created_at FROM users WHERE username=?")) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public User findById(int id) throws SQLException {
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT id,username,display_name,email,password_hash,avatar_url,created_at FROM users WHERE id=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    /** Gibt den User zurück wenn Passwort stimmt, sonst null. */
    public User authenticate(String username, String rawPassword) throws SQLException {
        User user = findByUsername(username);
        if (user == null) return null;
        return BCrypt.checkpw(rawPassword, user.passwordHash) ? user : null;
    }

    public User create(String username, String displayName, String email, String rawPassword) throws SQLException {
        String hash = BCrypt.hashpw(rawPassword, BCrypt.gensalt(12));
        try (Connection c = DB.get();
             PreparedStatement ps = c.prepareStatement(
                     "INSERT INTO users (username,display_name,email,password_hash) VALUES (?,?,?,?) RETURNING id",
                     Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, username);
            ps.setString(2, displayName);
            ps.setString(3, email);
            ps.setString(4, hash);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return findById(rs.getInt(1));
            }
        }
        return null;
    }

    private User map(ResultSet rs) throws SQLException {
        User u = new User();
        u.id          = rs.getInt("id");
        u.username    = rs.getString("username");
        u.displayName = rs.getString("display_name");
        u.email       = rs.getString("email");
        u.passwordHash= rs.getString("password_hash");
        u.avatarUrl   = rs.getString("avatar_url");
        Timestamp ts  = rs.getTimestamp("created_at");
        if (ts != null) u.createdAt = ts.toLocalDateTime();
        return u;
    }
}
