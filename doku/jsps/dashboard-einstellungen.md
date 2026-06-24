# dashboard/blog-settings.jsp — Blog-Einstellungen

**Pfad:** `src/main/webapp/WEB-INF/views/dashboard/blog-settings.jsp`
**URL:** `/MyBlog/dashboard/{blog-slug}/settings`
**Servlet:** `DashboardServlet`
**Zugang:** Nur owner/admin des Blogs

Formular zum Bearbeiten der Blog-Metadaten.

## Request-Attribute

| Attribut | Typ | Bedeutung |
|----------|-----|-----------|
| `blog` | `Blog` | Aktueller Blog |
| `error` | `String` | Fehlermeldung (optional) |

## Bearbeitbare Felder

- **Name** des Blogs
- **Slug** (URL-Kennung, einmalig)
- **Beschreibung** (Freitext, erscheint auf `blog-home.jsp`)
- **Standard-Akzentfarbe** (Color-Picker)
- **Cover-Bild** (URL)
- **Sichtbarkeit** — `public` / `private` / `invite`

## Aktionen

- `POST /MyBlog/dashboard/{slug}/settings` → `BlogService.updateSettings()`
