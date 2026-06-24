# dashboard/my-blogs.jsp — Dashboard-Startseite

**Pfad:** `src/main/webapp/WEB-INF/views/dashboard/my-blogs.jsp`
**URL:** `/MyBlog/dashboard/`
**Servlet:** `DashboardServlet`
**Zugang:** Nur für eingeloggte Benutzer (Rolle `USER`)

Übersicht aller Blogs, zu denen der eingeloggte Benutzer gehört.
Zeigt Rolle pro Blog und ermöglicht den Sprung in die Artikelliste.

## Request-Attribute

| Attribut | Typ | Bedeutung |
|----------|-----|-----------|
| `blogs` | `List<Blog>` | Blogs des Benutzers |
| `displayName` | `String` | Anzeigename (aus Session) |

## Aktionen

- **Blog öffnen** → `GET /MyBlog/dashboard/{slug}/`
- **Abmelden** → `POST /MyBlog/logout`
