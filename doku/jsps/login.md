# Login-Seiten

## login.jsp (webapp root)

**Pfad:** `src/main/webapp/login.jsp`
**URL:** `GET /MyBlog/login`
**Servlet:** `LoginServlet`

Die eigentliche Anmeldeseite. Dark Theme (Segoe UI, `#1c1c1c`), zentrierte Karte, EA-Logo-Kreis.

### Request-Attribute

| Attribut | Typ | Bedeutung |
|----------|-----|-----------|
| `error` | `String` | Fehlermeldung bei falschem Login (optional) |

### Request-Parameter (GET)

| Parameter | Bedeutung |
|-----------|-----------|
| `next` | Ziel-URL nach erfolgreichem Login (z.B. `/`) |

### Formular

- `POST /MyBlog/login`
- Felder: `username`, `password`, `next` (hidden)
- Bei Erfolg: Redirect auf `next` oder `/MyBlog/dashboard/`
- Bei Fehler: Seite wird neu gerendert mit `error`-Attribut

---

## login-error.jsp (webapp root)

**Pfad:** `src/main/webapp/login-error.jsp`
**URL:** Tomcat leitet hierher wenn `j_security_check` fehlschlägt

Fallback-Seite für Container-managed FORM-Auth. Gleiches Dark-Design wie `login.jsp`.
Zeigt rote Fehlermeldung, Formular posted erneut auf `j_security_check`.

---

## WEB-INF/views/login.jsp

**Status:** veraltet — wird nicht mehr verwendet.
`LoginServlet` forwardet direkt auf `webapp/login.jsp` (Root-Ebene).
