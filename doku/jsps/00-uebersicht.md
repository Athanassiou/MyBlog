# JSP-Übersicht — MyBlog

Alle JSPs im Projekt, gruppiert nach Bereich. Keine JSTL — ausschließlich plain Scriptlets (`<% %>`).
Designsystem: Raleway-Font, CSS-Custom-Properties (`--accent`, `--border` etc.), kein Framework.

## Dateibaum

```
webapp/
├── login.jsp                         ← Haupt-Login (Segoe UI, Dark Theme)
├── login-error.jsp                   ← Container-Fehlerseite (j_security_check)
└── WEB-INF/views/
    ├── index.jsp                     ← Plattform-Startseite (alle Blogs)
    ├── blog-home.jsp                 ← Blog-Schaufenster (Karten-Ansicht)
    ├── blog-index.jsp                ← Blog-Listenansicht + Suche + Tags
    ├── article.jsp                   ← Artikelansicht (Sidebar + TOC)
    ├── login.jsp                     ← (veraltet, nicht mehr genutzt)
    ├── error/
    │   ├── 404.jsp
    │   └── 500.jsp
    ├── dashboard/
    │   ├── my-blogs.jsp              ← Meine Blogs (nach Login)
    │   ├── list.jsp                  ← Artikelliste eines Blogs
    │   ├── editor.jsp                ← EditorJS-Artikeleditor
    │   └── blog-settings.jsp         ← Blog-Einstellungen
    └── admin/
        ├── blogs.jsp                 ← Alle Blogs (Plattform-Admin)
        ├── blog-form.jsp             ← Blog anlegen / bearbeiten
        ├── users.jsp                 ← Alle Benutzer
        ├── user-form.jsp             ← Benutzer anlegen
        └── members.jsp               ← Blog-Mitgliederverwaltung
```

## URL → JSP-Mapping

| URL | Servlet | JSP |
|-----|---------|-----|
| `/MyBlog/` | `BlogPlatformServlet` | `views/index.jsp` |
| `/MyBlog/login` | `LoginServlet` | `login.jsp` (ROOT) |
| `/MyBlog/{slug}/` | `BlogServlet` | `views/blog-home.jsp` |
| `/MyBlog/{slug}/list` | `BlogServlet` | `views/blog-index.jsp` |
| `/MyBlog/{slug}/{article}` | `BlogServlet` | `views/article.jsp` |
| `/MyBlog/dashboard/` | `DashboardServlet` | `views/dashboard/my-blogs.jsp` |
| `/MyBlog/dashboard/{slug}/` | `DashboardServlet` | `views/dashboard/list.jsp` |
| `/MyBlog/dashboard/{slug}/new` | `DashboardServlet` | `views/dashboard/editor.jsp` |
| `/MyBlog/dashboard/{slug}/{id}` | `DashboardServlet` | `views/dashboard/editor.jsp` |
| `/MyBlog/dashboard/{slug}/settings` | `DashboardServlet` | `views/dashboard/blog-settings.jsp` |
| `/MyBlog/admin/` | `AdminServlet` | `views/admin/blogs.jsp` |
| `/MyBlog/admin/users` | `AdminServlet` | `views/admin/users.jsp` |

## Einzeldokumente

- [login.md](login.md) — Login-Seiten
- [artikel.md](artikel.md) — Artikelansicht
- [blog-home.md](blog-home.md) — Blog-Schaufenster
- [blog-index.md](blog-index.md) — Listenansicht
- [plattform-index.md](plattform-index.md) — Alle Blogs
- [dashboard-meine-blogs.md](dashboard-meine-blogs.md) — Dashboard Startseite
- [dashboard-artikelliste.md](dashboard-artikelliste.md) — Artikelliste
- [dashboard-editor.md](dashboard-editor.md) — EditorJS-Editor
- [dashboard-einstellungen.md](dashboard-einstellungen.md) — Blog-Einstellungen
- [admin.md](admin.md) — Admin-Bereich (Alle 5 Admin-JSPs in einer Datei)
- [homepage.md](homepage.md) — athanassiou.me Startseite (ROOT/index.jsp) nicht in GIT
