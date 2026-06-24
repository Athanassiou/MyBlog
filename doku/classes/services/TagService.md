# TagService

**Paket:** `de.myblog.service`  
**Datei:** `TagService.java`

Tags lesen, für Artikel setzen (find-or-create). Alle Methoden werfen `SQLException`.

## Methoden

### `listByArticle(int articleId) → List<Tag>`

Alle Tags eines Artikels, alphabetisch sortiert.

---

### `mapByBlog(int blogId) → Map<Integer, List<Tag>>`

Tags aller Artikel eines Blogs in einer einzigen Abfrage.  
Rückgabe: `Map<articleId, List<Tag>>` — vermeidet N+1 beim Blog-Index.

```sql
SELECT at.article_id, t.*
FROM tags t JOIN article_tags at ON at.tag_id = t.id
WHERE t.blog_id = ? ORDER BY at.article_id, t.name
```

---

### `listNamesByBlog(int blogId) → List<String>`

Alle Tag-Namen eines Blogs (für Autocomplete im Editor).

---

### `saveArticleTags(int articleId, int blogId, String rawTags)`

Setzt Tags eines Artikels vollständig neu:
1. Alle alten `article_tags`-Einträge löschen
2. `rawTags` (komma-getrennte Namen) aufteilen und trimmen
3. Für jeden Namen: `findOrCreate()` → Tag-ID
4. `INSERT INTO article_tags ... ON CONFLICT DO NOTHING`

**Eingabeformat:** `"Java, Maven, Jakarta EE"`

## find-or-create Logik

`findOrCreate(c, blogId, name)` sucht case-insensitiv (`lower(name)`).  
Wenn der Tag noch nicht existiert, wird er mit der übergebenen Schreibweise angelegt.  
Gleicher Name in zwei Blogs → zwei separate Tag-Einträge.
