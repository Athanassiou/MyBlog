package de.myblog.model;

import java.time.LocalDateTime;

public class Blog {
    public int    id;
    public String slug;
    public String name;
    public String description;
    public String defaultAccentColor;
    public String coverImage;
    public String visibility;   // 'public'|'private'|'invite'
    public int    ownerId;
    public LocalDateTime createdAt;

    /** Wird beim Laden für den eingeloggten User befüllt (nicht in DB). */
    public String userRole;
}
