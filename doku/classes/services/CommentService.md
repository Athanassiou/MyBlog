# CommentService

**Paket:** `de.myblog.service`  
**Datei:** `CommentService.java`

Kommentare lesen, anlegen und löschen. Alle Methoden werfen `SQLException`.

## Methoden

### `listByArticle(int articleId) → List<Comment>`

Alle Kommentare eines Artikels, chronologisch aufsteigend.  
JOINt `users` für `authorUsername` und `authorDisplayName`.

```sql
SELECT cm.*, u.username, u.display_name
FROM comments cm LEFT JOIN users u ON u.id = cm.author_id
WHERE cm.article_id = ? ORDER BY cm.created_at ASC
```

---

### `create(int articleId, int authorId, String body, Integer parentId)`

Legt neuen Kommentar an. `parentId=null` → Top-Level-Kommentar.

---

### `delete(int commentId, int requestingUserId)`

Löscht nur Kommentare des anfragenden Users (`WHERE id=? AND author_id=?`).  
Kein Fehler wenn kein Eintrag gelöscht wurde — Admins müssen direkt in der DB löschen.

## Hinweis

Thread-Struktur wird von der JSP aufgebaut — die DB liefert die Kommentare
als flache Liste. Beim Löschen eines Eltern-Kommentars bleiben Kinder erhalten
(kein CASCADE im Schema für `parent_id`).
