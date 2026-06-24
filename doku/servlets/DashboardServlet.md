# DashboardServlet

**Klasse:** `de.myblog.servlet.DashboardServlet`
**Mapping:** `/MyBlog/dashboard/*`
**Zugang:** Login erforderlich (`userId` in Session) — sonst Redirect auf `/login`

Autorenbereich: Blog- und Artikelverwaltung. Rollensystem steuert welche Aktionen
sichtbar und erlaubt sind.

## GET-Routen

| Pfad | Aktion | Forward → JSP |
|------|--------|---------------|
| `/dashboard/` | Meine Blogs laden | `dashboard/my-blogs.jsp` |
| `/dashboard/{slug}/` | Artikelliste | `dashboard/list.jsp` |
| `/dashboard/{slug}/new` | Leerer Editor | `dashboard/editor.jsp` |
| `/dashboard/{slug}/settings` | Blog-Einstellungen | `dashboard/blog-settings.jsp` |
| `/dashboard/{slug}/{id}` | Artikel im Editor laden | `dashboard/editor.jsp` |
| `/dashboard/{slug}/{id}/preview` | Vorschau (Artikel-JSP) | `views/article.jsp` |

## POST-Routen

| Pfad | Aktion | Rolle erforderlich |
|------|--------|--------------------|
| `/dashboard/` | Neuen Blog anlegen | (eingeloggt) |
| `/dashboard/{slug}/new` | Neuen Artikel anlegen | (Mitglied) |
| `/dashboard/{slug}/settings` | Blog-Einstellungen speichern | owner, admin |
| `/dashboard/{slug}/delete-blog` | Blog löschen | owner, admin |
| `/dashboard/{slug}/{id}` | Artikel-Meta + Blöcke speichern | (Mitglied) |
| `/dashboard/{slug}/{id}/publish` | Veröffentlichen | owner, admin, author |
| `/dashboard/{slug}/{id}/unpublish` | Zurückziehen | owner, admin, author |
| `/dashboard/{slug}/{id}/delete` | Artikel löschen | owner, admin |

## Request-Attribute (gesetzt vor dem Forward)

### → `dashboard/my-blogs.jsp`
| Attribut | Typ |
|----------|-----|
| `blogs` | `List<Blog>` |

### → `dashboard/list.jsp`
| Attribut | Typ |
|----------|-----|
| `blog` | `Blog` |
| `articles` | `List<Article>` (alle, draft + published) |
| `role` | `String` |
| `canPublish` | `Boolean` |
| `canManage` | `Boolean` |

### → `dashboard/editor.jsp`
| Attribut | Typ |
|----------|-----|
| `blog` | `Blog` |
| `article` | `Article` (null bei neuem Artikel) |
| `role` | `String` |
| `canPublish` | `Boolean` |
| `canManage` | `Boolean` |
| `blogTagNames` | `List<String>` |

### → `dashboard/blog-settings.jsp`
| Attribut | Typ |
|----------|-----|
| `blog` | `Blog` |
| `role` | `String` |

## Rollensystem

| Rolle | canPublish | canManage |
|-------|-----------|-----------|
| `owner` | ✅ | ✅ |
| `admin` | ✅ | ✅ |
| `author` | ✅ | ❌ |
| `contributor` | ❌ | ❌ |

`requireBlogAccess()` prüft ob der User überhaupt Mitglied des Blogs ist (sonst 403).

## Services

| Service | Verwendung |
|---------|------------|
| `BlogService` | Blog laden, anlegen, updaten, löschen |
| `ArticleService` | Artikel laden, anlegen, speichern, publish/unpublish/delete |
| `TagService` | Tags laden und speichern |
| `UserService` | Rolle im Blog abfragen |

## Block-Parsing

Beim Speichern (POST `/{slug}/{id}`) wird das EditorJS-JSON aus dem Parameter `blocks`
geparst: `JSONArray → List<Block>` → `ArticleService.saveBlocks()`.
