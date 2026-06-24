# blog-index.jsp — Listenansicht

**Pfad:** `src/main/webapp/WEB-INF/views/blog-index.jsp`
**URL:** `/MyBlog/{blog-slug}/list`
**Servlet:** `BlogServlet`

Kompakte Tabellenansicht aller Artikel eines Blogs — alternativ zur Karten-Ansicht (`blog-home.jsp`).
Unterstützt Volltextsuche und Tag-Filter.

## Request-Attribute

| Attribut | Typ | Bedeutung |
|----------|-----|-----------|
| `blog` | `Blog` | Blog-Objekt |
| `articles` | `List<Article>` | Artikelliste (gefiltert oder vollständig) |
| `tags` | `List<Tag>` | Alle Tags des Blogs (für Filterleiste) |
| `searchQuery` | `String` | Aktiver Suchbegriff (null = keine Suche) |
| `filterTag` | `String` | Aktiver Tag-Filter (null = kein Filter) |

## Features

- **Suche:** GET-Parameter `?q=…` → `ArticleService.search()`
- **Tag-Filter:** GET-Parameter `?tag=…` → filtert nach Tag-Name
- **Spalten:** Titel · Datum · Tags · Kommentare
- **Breadcrumb:** `⌂ athanassiou.me → Blog-Name → Listenansicht`
- **Wechsel:** Link zurück zu `blog-home.jsp` (Karten-Ansicht)
