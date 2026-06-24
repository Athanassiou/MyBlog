# Blog

**Paket:** `de.myblog.model`  
**Datei:** `Blog.java`

Repräsentiert einen Blog auf der Plattform.

## Felder

| Feld | Typ | DB-Spalte | Bedeutung |
|------|-----|-----------|-----------|
| `id` | `int` | `blogs.id` | Primärschlüssel |
| `slug` | `String` | `blogs.slug` | URL-Segment, plattformweit eindeutig |
| `name` | `String` | `blogs.name` | Anzeigename |
| `description` | `String` | `blogs.description` | Kurzbeschreibung |
| `defaultAccentColor` | `String` | `blogs.default_accent_color` | Standard-Akzentfarbe für Artikel |
| `coverImage` | `String` | `blogs.cover_image` | URL zum Titelbild (optional) |
| `visibility` | `String` | `blogs.visibility` | `"public"` / `"private"` / `"invite"` |
| `ownerId` | `int` | `blogs.owner_id` | User-ID des Eigentümers |
| `createdAt` | `LocalDateTime` | `blogs.created_at` | Erstellungszeitpunkt |
| `userRole` | `String` | — | Transient: Rolle des eingeloggten Users (nicht in DB) |

## Sichtbarkeit (`visibility`)

| Wert | Bedeutung |
|------|-----------|
| `public` | Für alle lesbar, erscheint auf der Plattform-Homepage |
| `private` | Nur für Mitglieder sichtbar |
| `invite` | Nur per Einladung |

## Hinweis

`userRole` wird von `BlogService.listForUser()` befüllt, um in der
Dashboard-Ansicht die Rolle des eingeloggten Users direkt am Blog-Objekt
verfügbar zu haben — ohne eine zweite DB-Abfrage pro Blog.
