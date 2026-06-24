# BlogPlatformServlet

**Klasse:** `de.myblog.servlet.BlogPlatformServlet`
**Mapping:** `/MyBlog/*`
**Zugang:** öffentlich (kein Login erforderlich)

Kernservlet für alle lesbaren Ansichten: Plattform-Startseite, Blog-Schaufenster,
Listenansicht, Artikelansicht, Suche, Tag-Filter und RSS-Feed.
Kommentare werden ebenfalls hier entgegengenommen (POST, Login erforderlich).

## GET-Routen

| Pfad | Handler | Forward → JSP |
|------|---------|---------------|
| `/MyBlog/` | `showPlatformHome` | `views/index.jsp` |
| `/MyBlog/{slug}/` | `showBlogHome` | `views/blog-home.jsp` |
| `/MyBlog/{slug}/?q=…` | `showSearch` | `views/blog-index.jsp` |
| `/MyBlog/{slug}/list` | `showBlogIndex` | `views/blog-index.jsp` |
| `/MyBlog/{slug}/feed` | `showRss` | *(direkte RSS-Ausgabe, kein JSP)* |
| `/MyBlog/{slug}/tag/{name}` | `showTagFilter` | `views/blog-index.jsp` |
| `/MyBlog/{slug}/{article-slug}` | `showArticle` | `views/article.jsp` |

## POST-Routen

| Pfad | Aktion |
|------|--------|
| `/MyBlog/{slug}/{article-slug}` | Kommentar erstellen oder löschen |

POST erfordert eingeloggte Session — sonst Redirect auf Login.

## Request-Attribute (gesetzt vor dem Forward)

### → `views/index.jsp`
| Attribut | Typ |
|----------|-----|
| `blogs` | `List<Blog>` |

### → `views/blog-home.jsp`
| Attribut | Typ |
|----------|-----|
| `blog` | `Blog` |
| `recent` | `List<Article>` (bis 6, neueste) |
| `older` | `List<Article>` (Rest) |
| `images` | `Map<Integer,String>` (articleId → imageUrl) |

### → `views/blog-index.jsp`
| Attribut | Typ | Befüllt bei |
|----------|-----|-------------|
| `blog` | `Blog` | immer |
| `articles` | `List<Article>` | immer |
| `tagNames` | `List<String>` | immer |
| `searchQuery` | `String` | Suche (`?q=`) |
| `filterTag` | `String` | Tag-Filter (`/tag/…`) |

### → `views/article.jsp`
| Attribut | Typ |
|----------|-----|
| `blog` | `Blog` |
| `article` | `Article` (inkl. Blöcke + Tags) |
| `comments` | `List<Comment>` |
| `prevArticle` | `Article` (null = keiner) |
| `nextArticle` | `Article` (null = keiner) |

## Services

| Service | Verwendung |
|---------|------------|
| `BlogService` | Blog per Slug laden, Sichtbarkeit prüfen |
| `ArticleService` | Artikel laden, Suche, Nachbarn, erste Bilder |
| `CommentService` | Kommentare listen, erstellen, löschen |
| `TagService` | Tags listen, Tag-Filter |

## RSS-Feed

- Content-Type: `application/rss+xml;charset=UTF-8`
- Enthält: Titel, Link, GUID, Beschreibung (Untertitel), pubDate
- Format: RFC 822 (`EEE, dd MMM yyyy HH:mm:ss Z`)

## Pfad-Aufteilung

`splitPath(path)` zerlegt den Servlet-Pfad in maximal 2 Segmente:
- `""` → Platform-Home
- `["ea-blog"]` → Blog-Home
- `["ea-blog", "maven"]` → Artikel
- `["ea-blog", "feed"]` → RSS
