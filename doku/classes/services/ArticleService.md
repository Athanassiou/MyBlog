# ArticleService

**Paket:** `de.myblog.service`  
**Datei:** `ArticleService.java`

CRUD für Artikel und Blöcke. Alle Methoden werfen `SQLException`.

## Lese-Methoden

### `listByBlog(int blogId) → List<Article>`

Alle Artikel eines Blogs, neueste zuerst. Enthält `commentCount`, aber keine Blöcke oder Tags.

```sql
SELECT a.*, COUNT(cm.id) AS comment_count
FROM articles a LEFT JOIN comments cm ON cm.article_id=a.id
WHERE a.blog_id=? GROUP BY a.id ORDER BY a.created_at DESC
```

---

### `findBySlug(int blogId, String slug) → Article`

Artikel inkl. Blöcke. `null` wenn nicht gefunden.

---

### `findById(int id) → Article`

Artikel inkl. Blöcke. `null` wenn nicht gefunden.

---

### `findNeighbours(int blogId, LocalDateTime publishedAt, int articleId) → Article[2]`

Gibt `[prevArticle, nextArticle]` für die Artikel-Navigation zurück.  
Reihenfolge: `published_at ASC`, `id` als Tiebreaker bei Gleichstand.  
Liefert `null`-Einträge wenn kein Vor-/Nachfolger existiert.  
Nur für veröffentlichte Artikel.

---

### `search(int blogId, String query) → List<Article>`

Volltextsuche auf Titel, Untertitel und Tag-Namen (case-insensitive `LIKE`).  
Nur veröffentlichte Artikel. Ergebnis: neueste zuerst, keine Blöcke geladen.

---

### `findFirstImages(List<Integer> articleIds) → Map<Integer, String>`

Liefert pro Artikel-ID die URL des ersten `image`- oder `imagePair`-Blocks.  
Einmalige Abfrage für alle IDs (kein N+1) via PostgreSQL `ANY(?)`.  
Wird für Blog-Index-Vorschaubilder genutzt.

## Schreib-Methoden

### `create(int blogId, int authorId, String title, String slug, String accentColor) → Article`

Legt neuen Artikel an (Status `draft`). Fehlende `accentColor` → `#e5a00d`.  
Gibt den vollständig geladenen Artikel zurück (inkl. Blöcke — anfangs leer).

```sql
INSERT INTO articles (blog_id,author_id,title,slug,accent_color,status)
VALUES (?,?,?,?,?,'draft') RETURNING id
```

---

### `saveBlocks(int articleId, List<Block> blocks)`

Ersetzt **alle** Blöcke eines Artikels in einer Transaktion:
1. `DELETE FROM blocks WHERE article_id=?`
2. `INSERT INTO blocks ... (Batch)`

Rollback bei Fehler.

---

### `updateMeta(int articleId, String title, String subtitle, String slug, String accentColor)`

Aktualisiert Metadaten (kein Status-Wechsel, keine Blöcke).

---

### `publish(int articleId)`

Setzt `status='published'` und `published_at=NOW()`.

---

### `unpublish(int articleId)`

Setzt `status='draft'` und `published_at=NULL`.

---

### `delete(int articleId)`

Löscht Artikel inkl. aller Blöcke (`ON DELETE CASCADE` in DB).
