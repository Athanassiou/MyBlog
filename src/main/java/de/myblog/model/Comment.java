package de.myblog.model;

import java.time.LocalDateTime;

public class Comment {
    public int           id;
    public int           articleId;
    public int           authorId;
    public Integer       parentId;
    public String        body;
    public LocalDateTime createdAt;
    // joined from users:
    public String        authorUsername;
    public String        authorDisplayName;
}
