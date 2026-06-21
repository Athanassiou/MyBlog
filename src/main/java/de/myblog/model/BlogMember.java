package de.myblog.model;

public class BlogMember {
    public int    blogId;
    public User   user;
    public String role;   // 'owner'|'admin'|'author'|'contributor'
}
