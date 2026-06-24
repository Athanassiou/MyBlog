# Block

**Paket:** `de.myblog.model`  
**Datei:** `Block.java`

Ein einzelner EditorJS-Block innerhalb eines Artikels.

## Felder

| Feld | Typ | DB-Spalte | Bedeutung |
|------|-----|-----------|-----------|
| `id` | `int` | `blocks.id` | Primärschlüssel |
| `articleId` | `int` | `blocks.article_id` | Zugehöriger Artikel |
| `position` | `int` | `blocks.position` | Reihenfolge (0-basiert) |
| `type` | `String` | `blocks.type` | EditorJS-Blocktyp |
| `data` | `String` | `blocks.data` | Roh-JSON aus JSONB-Spalte |

## Block-Typen (`type`)

| Wert | Beschreibung |
|------|--------------|
| `paragraph` | Fließtext |
| `header` | Überschrift (level 2 = h3 mit TOC, level 3 = h4) |
| `image` | Einzelbild (`data.file.url`) |
| `imagePair` | Zwei Bilder nebeneinander (custom, `data.left.url` / `data.right.url`) |
| `list` | Aufzählung oder nummerierte Liste |
| `code` | Code-Block |
| `quote` | Blockzitat |
| `delimiter` | Trennlinie |
| `pdfLink` | PDF-Download-Karte (custom) |
| `timeline` | Zeitleiste (custom) |
| `infobox` | Info-Kasten mit Icon (custom) |

## Hinweis

`data` wird als roher JSON-String gespeichert (`JSONB` in PostgreSQL,
aber im Java-Modell als `String`). Der BlockRenderer (noch nicht implementiert)
parst dieses JSON bei der HTML-Ausgabe.
