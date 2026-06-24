# index.jsp — Plattform-Startseite

**Pfad:** `src/main/webapp/WEB-INF/views/index.jsp`
**URL:** `/MyBlog/`
**Servlet:** `BlogPlatformServlet`

Übersichtsseite aller öffentlichen Blogs der Plattform. Wird aufgerufen wenn mehrere Blogs
existieren. Im aktuellen Setup (nur `ea-blog`) wird direkt auf den Blog weitergeleitet.

## Request-Attribute

| Attribut | Typ | Bedeutung |
|----------|-----|-----------|
| `blogs` | `List<Blog>` | Alle öffentlichen Blogs |

## Hinweis

Nicht zu verwechseln mit `ROOT/index.jsp` — das ist die **athanassiou.me Homepage**
(außerhalb von MyBlog). Siehe [homepage.md](homepage.md).
