# Admin-Bereich — JSPs

**Basispfad:** `src/main/webapp/WEB-INF/views/admin/`
**URL-Präfix:** `/MyBlog/admin/`
**Servlet:** `AdminServlet`
**Zugang:** Nur Benutzer mit Rolle `ADMIN`

Alle Admin-JSPs binden gemeinsame Fragmente ein:
- `admin-common.css` — einheitliches Admin-Styling (via `<%@ include %>`)
- `admin-nav.html` — Topbar mit Navigation zwischen den Bereichen

---

## blogs.jsp — Blog-Übersicht

**URL:** `/MyBlog/admin/`

Tabelle aller Blogs auf der Plattform.

| Attribut | Typ | Beschreibung |
|----------|-----|--------------|
| `blogs` | `List<Blog>` | Alle Blogs |

Aktionen: **Bearbeiten** → `blog-form.jsp` · **Mitglieder** → `members.jsp`

---

## blog-form.jsp — Blog anlegen / bearbeiten

**URL:** `/MyBlog/admin/blogs/new` (neu) · `/MyBlog/admin/blogs/{id}/edit` (bearbeiten)

Formular für Blog-Stammdaten: Name, Slug, Beschreibung, Akzentfarbe, Cover-URL, Sichtbarkeit.

| Attribut | Typ | Beschreibung |
|----------|-----|--------------|
| `blog` | `Blog` | null = neuer Blog |
| `error` | `String` | Validierungsfehler (optional) |

---

## users.jsp — Benutzer-Übersicht

**URL:** `/MyBlog/admin/users`

Tabelle aller Plattform-Benutzer mit ID, Benutzername, Anzeigename, E-Mail.

| Attribut | Typ | Beschreibung |
|----------|-----|--------------|
| `users` | `List<User>` | Alle Benutzer |

---

## user-form.jsp — Benutzer anlegen

**URL:** `/MyBlog/admin/users/new`

Einfaches Formular: Benutzername, Anzeigename, E-Mail, Passwort.
Passwort wird serverseitig als SHA-256 gehasht gespeichert.

---

## members.jsp — Blog-Mitgliederverwaltung

**URL:** `/MyBlog/admin/blogs/{id}/members`

Zeigt alle Mitglieder eines Blogs und deren Rollen. Ermöglicht:
- Benutzer hinzufügen (mit Rolle)
- Rolle ändern
- Mitglied entfernen

| Attribut | Typ | Beschreibung |
|----------|-----|--------------|
| `blog` | `Blog` | Betroffener Blog |
| `members` | `List<BlogMember>` | Aktuelle Mitglieder |
| `allUsers` | `List<User>` | Alle Benutzer (für Dropdown) |

### Rollen

| Rolle | Bedeutung |
|-------|-----------|
| `owner` | Vollzugriff, kann Blog löschen |
| `admin` | Einstellungen + Mitglieder verwalten |
| `author` | Artikel schreiben + veröffentlichen |
| `contributor` | Artikel schreiben, kein Veröffentlichen |
