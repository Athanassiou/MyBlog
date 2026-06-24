# Comment

**Paket:** `de.myblog.model`  
**Datei:** `Comment.java`

Kommentar zu einem Artikel, mit optionalem Threading (Antworten auf Kommentare).

## Felder

| Feld | Typ | DB-Spalte | Bedeutung |
|------|-----|-----------|-----------|
| `id` | `int` | `comments.id` | Primärschlüssel |
| `articleId` | `int` | `comments.article_id` | Zugehöriger Artikel |
| `authorId` | `int` | `comments.author_id` | Autor |
| `parentId` | `Integer` | `comments.parent_id` | Eltern-Kommentar (null = Top-Level) |
| `body` | `String` | `comments.body` | Inhalt |
| `createdAt` | `LocalDateTime` | `comments.created_at` | Zeitpunkt |
| `authorUsername` | `String` | JOIN `users.username` | Direkt gejoint, nicht in `comments` |
| `authorDisplayName` | `String` | JOIN `users.display_name` | Direkt gejoint, nicht in `comments` |

## Threading

`parentId = null` → Top-Level-Kommentar  
`parentId = X` → Antwort auf Kommentar X (eine Ebene)

Die Anzeige-Hierarchie muss in der JSP aus der flachen Liste aufgebaut werden
(Kommentare kommen sortiert nach `created_at ASC` aus der DB).

## Hinweis

`authorUsername` und `authorDisplayName` werden immer via LEFT JOIN
aus `users` gejoint — auch wenn der Author-Account zwischenzeitlich
gelöscht wurde (dann sind beide Felder `null`).
