# AdminServlet

**Klasse:** `de.myblog.servlet.AdminServlet`
**Mapping:** `/MyBlog/admin/*`
**Zugang:** Login erforderlich. Für Blog-spezifische Aktionen zusätzlich Rolle `owner` oder `admin`.

Plattform-Administration: Benutzer und Blogs verwalten, Blog-Mitglieder pflegen.

## GET-Routen

| Pfad | Aktion | Forward → JSP |
|------|--------|---------------|
| `/admin/` oder `/admin/users` | Benutzerübersicht | `admin/users.jsp` |
| `/admin/users/new` | Formular: Benutzer anlegen | `admin/user-form.jsp` |
| `/admin/blogs/` | Alle Blogs | `admin/blogs.jsp` |
| `/admin/blogs/new` | Formular: Blog anlegen | `admin/blog-form.jsp` |
| `/admin/blogs/{id}/edit` | Formular: Blog bearbeiten | `admin/blog-form.jsp` |
| `/admin/members/{blogId}` | Blog-Mitglieder | `admin/members.jsp` |

## POST-Routen

| Pfad | Aktion | Rolle |
|------|--------|-------|
| `/admin/users/new` | Benutzer anlegen | (eingeloggt) |
| `/admin/blogs/new` | Blog anlegen | (eingeloggt) |
| `/admin/blogs/{id}/edit` | Blog updaten | owner, admin |
| `/admin/members/{blogId}/add` | Mitglied hinzufügen | owner, admin |
| `/admin/members/{blogId}/{uid}/role` | Rolle ändern | owner, admin |
| `/admin/members/{blogId}/{uid}/remove` | Mitglied entfernen | owner, admin |

## Request-Attribute

### → `admin/users.jsp`
| Attribut | Typ |
|----------|-----|
| `users` | `List<User>` |
| `blogs` | `List<Blog>` |

### → `admin/user-form.jsp`
| Attribut | Typ |
|----------|-----|
| `blogs` | `List<Blog>` (für Blog-Zuweisung beim Anlegen) |
| `error` | `String` (optional) |

### → `admin/blogs.jsp`
| Attribut | Typ |
|----------|-----|
| `blogs` | `List<Blog>` (alle, inkl. private) |

### → `admin/blog-form.jsp`
| Attribut | Typ |
|----------|-----|
| `blog` | `Blog` (null = neuer Blog) |
| `error` | `String` (optional) |

### → `admin/members.jsp`
| Attribut | Typ |
|----------|-----|
| `blog` | `Blog` |
| `members` | `List<BlogMember>` |
| `allUsers` | `List<User>` |

## Besonderheiten

- **Owner-Schutz:** Rolle eines `owner` kann nicht geändert oder entfernt werden.
- **Benutzer anlegen:** Passwort wird in `UserService.create()` als SHA-256 gehasht.
  Optionale direkte Blog-Zuweisung mit Rolle über Parameter `blogId` + `role`.
- **Blog anlegen:** Der anlegende User wird automatisch als `owner` eingetragen
  (`BlogService.create()` trägt ihn in `blog_members` ein).

## Services

| Service | Verwendung |
|---------|------------|
| `UserService` | Benutzer listen, anlegen, Rolle im Blog abfragen |
| `BlogService` | Blogs listen/laden/anlegen/updaten, Mitglieder verwalten |
