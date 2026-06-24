# article.jsp — Artikelansicht

**Pfad:** `src/main/webapp/WEB-INF/views/article.jsp`
**URL:** `/MyBlog/{blog-slug}/{article-slug}`
**Servlet:** `BlogServlet`

Vollständige Artikeldarstellung mit Sidebar-Navigation, automatisch generiertem Inhaltsverzeichnis (TOC)
und Vor/Zurück-Navigation zwischen Artikeln. Font: Raleway (Google Fonts). Akzentfarbe kommt aus `articles.accent_color`.

## Request-Attribute

| Attribut | Typ | Bedeutung |
|----------|-----|-----------|
| `article` | `Article` | Der darzustellende Artikel (inkl. `blocks`) |
| `blog` | `Blog` | Zugehöriger Blog (für Slug, Name, Farbe) |
| `prevArticle` | `Article` | Vorheriger Artikel (null = keiner) |
| `nextArticle` | `Article` | Nächster Artikel (null = keiner) |
| `comments` | `List<Comment>` | Kommentarliste (kann leer sein) |
| `previewMode` | `Boolean` | true = Dashboard-Vorschau (kein SSO-Check nötig) |

## Layout

```
┌─────────────────────────────────────────────────┐
│  nav (sticky, 210px)  │  main content           │
│  ┌───────────────┐    │  ┌─────────────────┐    │
│  │ Blog-Name     │    │  │ title-row       │    │
│  │ ─────────     │    │  │ ‹ Titel ›       │    │
│  │ TOC-Links     │    │  │                 │    │
│  │               │    │  │ Artikel-Inhalt  │    │
│  │               │    │  │ (Blöcke)        │    │
│  │ ─────────     │    │  │                 │    │
│  │ ◑ Grey Mode   │    │  │ Kommentare      │    │
│  │ ‹ Einklappen  │    │  └─────────────────┘    │
│  └───────────────┘    │                         │
└─────────────────────────────────────────────────┘
```

## TOC-Generierung

Alle `header`-Blöcke mit Level 2 erzeugen automatisch einen TOC-Eintrag.
IDs werden als `s1`, `s2`, … vergeben. Scroll-Spy via `IntersectionObserver`.

## Sidebar-Funktionen

- **Grey Mode:** `body.grey-mode` toggle, persistiert in `localStorage`
- **Einklappen:** `nav.collapsed` → Sidebar auf 44px schmaler Streifen

## Block-Rendering

`BlockRenderer.render(blocks)` gibt fertiges HTML zurück.
Unterstützte Block-Typen: `paragraph`, `header`, `image`, `imagePair`,
`list`, `code`, `quote`, `delimiter`, `pdfLink`, `timeline`, `infobox`.

## Navigation

- **title-row:** Kreisförmige `‹`/`›`-Links zu prev/next (oben)
- **article-nav:** Footer-Navigation mit Kreis-Buttons + Haustitel
