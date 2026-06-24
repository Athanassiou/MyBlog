# Tag

**Paket:** `de.myblog.model`  
**Datei:** `Tag.java`

Ein Schlagwort, das Artikeln zugeordnet wird. Tags sind pro Blog, nicht global.

## Felder

| Feld | Typ | DB-Spalte | Bedeutung |
|------|-----|-----------|-----------|
| `id` | `int` | `tags.id` | Primärschlüssel |
| `blogId` | `int` | `tags.blog_id` | Zugehöriger Blog |
| `name` | `String` | `tags.name` | Tag-Name |

## Hinweis

Tags sind blogspezifisch — derselbe Tag-Name in zwei Blogs sind zwei
verschiedene `Tag`-Einträge. `TagService.findOrCreate()` sucht
case-insensitiv (`lower(name)`), legt aber den Tag mit der Schreibweise
an, die beim ersten Aufruf übergeben wird.
