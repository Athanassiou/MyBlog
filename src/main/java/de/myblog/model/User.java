package de.myblog.model;

import java.time.LocalDateTime;

public class User {
    public int id;
    public String username;
    public String displayName;
    public String email;
    public String passwordHash;
    public String avatarUrl;
    public LocalDateTime createdAt;
}
