# dashboard/list.jsp — Artikelliste

**Pfad:** `src/main/webapp/WEB-INF/views/dashboard/list.jsp`
**URL:** `/MyBlog/dashboard/{blog-slug}/`
**Servlet:** `DashboardServlet`
**Zugang:** Nur Mitglieder des Blogs

Verwaltungsliste aller Artikel eines Blogs. Zeigt Status-Badges, Datums und Aktionsschaltflächen.
Sichtbare Aktionen hängen von der Rolle ab (`canPublish`, `canManage`).

## Request-Attribute

| Attribut | Typ | Bedeutung |
|----------|-----|-----------|
| `blog` | `Blog` | Blog-Objekt |
| `articles` | `List<Article>` | Alle Artikel (draft + published) |
| `canPublish` | `Boolean` | Darf Artikel veröffentlichen (owner/admin/author) |
| `canManage` | `Boolean` | Darf Artikel löschen/Einstellungen ändern (owner/admin) |
| `role` | `String` | Rolle des Benutzers in diesem Blog |

## Aktionen pro Artikel

| Aktion | HTTP | URL |
|--------|------|-----|
| Bearbeiten | GET | `/dashboard/{slug}/{id}` |
| Veröffentlichen | POST | `/dashboard/{slug}/{id}/publish` |
| Zurückziehen | POST | `/dashboard/{slug}/{id}/unpublish` |
| Löschen | POST | `/dashboard/{slug}/{id}/delete` |

## Statusbadges

- `published` → grünes Badge
- `draft` → graues Badge
