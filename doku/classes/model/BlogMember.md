# BlogMember

**Paket:** `de.myblog.model`  
**Datei:** `BlogMember.java`

Verbindet einen User mit einem Blog und speichert seine Rolle.

## Felder

| Feld | Typ | DB-Spalte | Bedeutung |
|------|-----|-----------|-----------|
| `blogId` | `int` | `blog_members.blog_id` | Zugehöriger Blog |
| `user` | `User` | JOIN `users` | Vollständiges User-Objekt (gejoint) |
| `role` | `String` | `blog_members.role` | Rolle im Blog |

## Rollen (`role`)

| Wert | Rechte |
|------|--------|
| `owner` | Vollzugriff inkl. Blog löschen, wird automatisch bei Blog-Erstellung gesetzt |
| `admin` | Alle Rechte außer Blog löschen |
| `author` | Artikel anlegen und eigene bearbeiten |
| `contributor` | Entwürfe einreichen (derzeit noch nicht umgesetzt) |

## Hinweis

`BlogMember.user` ist kein Lazy-Load — `BlogService.listMembers()`
führt immer einen JOIN auf `users` durch und befüllt das vollständige
`User`-Objekt.
