# Servlet-Übersicht — MyBlog

Alle Servlets im Package `de.myblog.servlet`. Mapping in `WEB-INF/web.xml`.

## URL-Mapping

| Servlet | Mapping | Beschreibung |
|---------|---------|--------------|
| `BlogPlatformServlet` | `/MyBlog/*` | Öffentliche Blog- und Artikelansicht, RSS |
| `DashboardServlet` | `/MyBlog/dashboard/*` | Geschützter Autorenbereich |
| `AdminServlet` | `/MyBlog/admin/*` | Plattform-Administration |
| `LoginServlet` | `/MyBlog/login` | Anmeldung |
| `LogoutServlet` | `/MyBlog/logout` | Abmeldung |
| `ApiServlet` | `/MyBlog/api/*` | JSON-API für EditorJS + Session |
| `UploadServlet` | `/MyBlog/upload` | Bild-Upload (Multipart) |
| `FilesServlet` | `/MyBlog/files/*` | Statische Auslieferung hochgeladener Bilder |

## Querschnitt: Auth-Pattern

Alle geschützten Servlets prüfen die Session selbst:
```java
HttpSession s = req.getSession(false);
if (s == null || s.getAttribute("userId") == null) {
    resp.sendRedirect(".../login?next=...");
}
```
`SessionFilter` befüllt die Session-Attribute nach jedem Tomcat-SSO-Login.

## Session-Attribute

| Attribut | Typ | Gesetzt von |
|----------|-----|-------------|
| `userId` | `int` | `LoginServlet`, `SessionFilter` |
| `username` | `String` | `LoginServlet`, `SessionFilter` |
| `displayName` | `String` | `LoginServlet`, `SessionFilter` |

## Einzeldokumente

- [BlogPlatformServlet.md](BlogPlatformServlet.md)
- [DashboardServlet.md](DashboardServlet.md)
- [AdminServlet.md](AdminServlet.md)
- [LoginServlet.md](LoginServlet.md)
- [LogoutServlet.md](LogoutServlet.md)
- [ApiServlet.md](ApiServlet.md)
- [UploadServlet.md](UploadServlet.md)
- [FilesServlet.md](FilesServlet.md)
