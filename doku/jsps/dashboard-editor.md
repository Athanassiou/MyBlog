# dashboard/editor.jsp — EditorJS-Artikeleditor

**Pfad:** `src/main/webapp/WEB-INF/views/dashboard/editor.jsp`
**URL:** `/MyBlog/dashboard/{blog-slug}/new` (neuer Artikel)
**URL:** `/MyBlog/dashboard/{blog-slug}/{id}` (bestehender Artikel)
**Servlet:** `DashboardServlet`
**Zugang:** Nur Mitglieder des Blogs

Zweispaltiger Editor: oben eine Meta-Leiste (Titel, Slug, Farbe), unten der EditorJS-Canvas.

## Request-Attribute

| Attribut | Typ | Bedeutung |
|----------|-----|-----------|
| `article` | `Article` | Artikel (null = neuer Artikel) |
| `blog` | `Blog` | Zugehöriger Blog |

## Meta-Bereich

- **Titel** — großes Textfeld, Pflichtfeld
- **Untertitel** — optionales Textfeld
- **Slug** — wird aus Titel automatisch generiert (JS), manuell überschreibbar
- **Akzentfarbe** — Color-Picker + Hex-Input

## EditorJS

Geladen vom CDN (`cdn.jsdelivr.net`). Konfigurierte Tools:

| Tool | CDN-Paket | Block-Typ |
|------|-----------|-----------|
| Header | `@editorjs/header` | `header` |
| Paragraph | (eingebaut) | `paragraph` |
| List | `@editorjs/list` | `list` |
| Quote | `@editorjs/quote` | `quote` |
| Code | `@editorjs/code` | `code` |
| Delimiter | `@editorjs/delimiter` | `delimiter` |
| Image | `@editorjs/image` | `image` |
| ImagePair | (custom, inline) | `imagePair` |

### Bild-Upload

Upload-Endpunkt: `POST /MyBlog/api/upload?blogSlug={slug}`
Gibt `{ success: 1, file: { url: "/files/{slug}/filename" } }` zurück.
Dateien landen in `ROOT/{blogSlug}/`.

## Speichern

1. `editor.save()` → EditorJS-JSON
2. JSON wird in Hidden-Feld `blocks` geschrieben
3. Form-POST zu `DashboardServlet`
4. Server: `ArticleService.saveBlocks()` + `updateMeta()`

## Aktionen

| Schaltfläche | HTTP | Aktion |
|-------------|------|--------|
| Speichern | POST | Meta + Blöcke sichern |
| Veröffentlichen | POST | `publish` → setzt `status='published'`, `published_at=NOW()` |
| Zurückziehen | POST | `unpublish` → setzt `status='draft'` |
| Vorschau | GET | öffnet `/MyBlog/{slug}/{article-slug}?preview=true` |
