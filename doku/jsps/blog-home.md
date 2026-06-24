# blog-home.jsp — Blog-Schaufenster

**Pfad:** `src/main/webapp/WEB-INF/views/blog-home.jsp`
**URL:** `/MyBlog/{blog-slug}/`
**Servlet:** `BlogServlet`

Visueller Einstieg in einen Blog. Neuere Artikel als große horizontale Karten (mit Bild),
ältere Artikel als kleinere Karten. Beide Reihen sind horizontal scrollbar (Shelf-Prinzip).

## Request-Attribute

| Attribut | Typ | Bedeutung |
|----------|-----|-----------|
| `blog` | `Blog` | Blog-Objekt (Name, Slug, Farbe, Beschreibung, Cover) |
| `recent` | `List<Article>` | Neuere Artikel (große Karten) |
| `older` | `List<Article>` | Ältere Artikel (kleine Karten) |
| `images` | `Map<Integer,String>` | Erstes Bild je Artikel: `articleId → imageUrl` |

## Layout

```
┌──────────────────────────────────────────┐
│ HEADER: Breadcrumb · Blog-Name · Cover   │
├──────────────────────────────────────────┤
│ Neuere Beiträge                    ──── │
│ [Karte] [Karte] [Karte] →              │
├──────────────────────────────────────────┤
│ Ältere Beiträge                    ──── │
│ [K][K][K][K][K][K] →                   │
└──────────────────────────────────────────┘
```

## Kartengrößen

**Große Karte (`.card-lg`):**
- Breite: `calc((100% - 48px) / 3)` — drei nebeneinander sichtbar
- Mindesthöhe: 420px
- Bild (flex:1) + Body (flex:1) = 50:50
- Text: h3 17px, p 14px, max 8 Zeilen (line-clamp)
- Opacity des Bildes: 0.8

**Kleine Karte (`.card-sm`):**
- Breite: `calc((100% - 80px) / 6)` — sechs nebeneinander
- Bild: 110px hoch
- Text: h5 12px, p 11px, max 3 Zeilen

## Breadcrumb

`⌂ athanassiou.me` → `/`
