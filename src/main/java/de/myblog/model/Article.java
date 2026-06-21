package de.myblog.model;

import java.time.LocalDateTime;
import java.util.List;
import de.myblog.model.Tag;

public class Article {
    public int id;
    public int blogId;
    public int authorId;
    public String slug;
    public String title;
    public String subtitle;
    public String accentColor;
    public String status;          // "draft" | "published"
    public LocalDateTime createdAt;
    public LocalDateTime publishedAt;

    public List<Block> blocks;
    public int         commentCount;
    public List<Tag>   tags;   // optional, nur wenn geladen
}
