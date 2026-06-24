# ROOT/index.jsp — athanassiou.me Homepage

**Pfad:** `/usr/local/apache-tomcat-10.1.8/webapps/ROOT/index.jsp` (dev)
**Pfad:** `/opt/tomcat/webapps/ROOT/index.jsp` (prod)
**URL:** `https://athanassiou.me/` bzw. `http://localhost:8080/`

> Diese Datei liegt **außerhalb** des MyBlog-Projekts und ist nicht in Git versioniert.
> Sie gehört zur Tomcat-ROOT-Webapp, nicht zu MyBlog.

Zwei-Zonen-Homepage im N3 Dark Theme (Segoe UI, `#1c1c1c`).
Prüft via `fetch('/MyBlog/api/session')` ob der Benutzer eingeloggt ist
und schaltet den privaten Bereich entsprechend frei.

## Design-Thema

Identisch mit NextThree (`n3.css`) und MediaBrowser:
- Hintergrund: `#1c1c1c`
- Header: `#111111`
- Karten: `#252525`, Border: `#2e2e2e`
- Text: `#e0e0e0`, Muted: `#888`
- Akzent: `#e5a00d`
- Font: `Segoe UI / Helvetica Neue / Arial` (System-Stack, kein Google Fonts)
- Grey Mode: `body.grey-mode`, persistiert in `localStorage`

## Zonen

### Öffentlich — „Für jeden"

| Karte | Ziel | Bild |
|-------|------|------|
| /Dev — Entwicklerblog | `/MyBlog/ea-blog/` | `ZX81.png` |
| Days to Go | `/myCalendar/` | `D2Go.png` |
| NASA Medien | — | `NASA.png` (Coming Soon) |

Kleine Kacheln: HAL · Hitchhiker's Guide · Grüne Wolke

### Privat — „Für die Familie"

Karten sind mit `opacity:.35; pointer-events:none` gesperrt bis Session aktiv.

| Karte | Ziel |
|-------|------|
| Digitales Archiv | `/MediaBrowser/` |
| Familiengeschichte | `/MyBlog/familengeschichte/` |
| Formel 1 | `/NextThree/index.jsp` |

## Header-Elemente

- **EA-Logo** (Gold-Kreis) + `athanassiou.me`
- **Uhrzeit/Datum** live (de-DE, `setInterval`)
- **Anmelden**-Button → `/MyBlog/login?next=/`
- **Dashboard**-Button (sichtbar nur wenn eingeloggt)
- **Benutzername** (sichtbar nur wenn eingeloggt)

## Footer

Grey-Mode-Toggle-Button (`◑ Grey Mode`) — kein Login-Link.

## Session-Check

```javascript
fetch('/MyBlog/api/session', { credentials: 'include' })
  → { loggedIn: true, displayName: "Akis", username: "akis" }
```

Endpunkt: `GET /MyBlog/api/session` in `ApiServlet`.
