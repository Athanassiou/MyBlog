    # Article

**Paket:** `de.myblog.model`  
**Datei:** `Article.java`

Repräsentiert einen Artikel in einem Blog.

## Felder

| Feld | Typ | DB-Spalte | Bedeutung |
|------|-----|-----------|-----------|
| `id` | `int` | `articles.id` | Primärschlüssel |
| `blogId` | `int` | `articles.blog_id` | Zugehöriger Blog |
| `authorId` | `int` | `articles.author_id` | Ersteller |
| `slug` | `String` | `articles.slug` | URL-Segment (eindeutig pro Blog) |
| `title` | `String` | `articles.title` | Titel |
| `subtitle` | `String` | `articles.subtitle` | Untertitel (optional) |
| `accentColor` | `String` | `articles.accent_color` | Hex-Farbe, z.B. `#e5a00d` |
| `status` | `String` | `articles.status` | `"draft"` oder `"published"` |
| `createdAt` | `LocalDateTime` | `articles.created_at` | Erstellungszeitpunkt |
| `publishedAt` | `LocalDateTime` | `articles.published_at` | Veröffentlichungszeitpunkt (null = unveröffentlicht) |
| `blocks` | `List<Block>` | — | Nur geladen bei `findById()` / `findBySlug()` |
| `commentCount` | `int` | — | Nur geladen bei `listByBlog()` |
| `tags` | `List<Tag>` | — | Optional, nicht automatisch befüllt |

## Hinweis

`blocks`, `commentCount` und `tags` sind keine DB-Spalten.
Sie werden je nach Kontext von `ArticleService` oder `TagService` nachgeladen.
`listByBlog()` liefert keine Blöcke — nur der Einzelabruf per ID/Slug tut das.
