# ApiServlet

**Klasse:** `de.myblog.servlet.ApiServlet`
**Mapping:** `/MyBlog/api/*`
**Content-Type:** `application/json;charset=UTF-8`

JSON-API für EditorJS-Kommunikation und Session-Abfragen der Homepage.

## GET-Endpunkte

### `GET /api/session`

**Zugang:** öffentlich

Gibt den aktuellen Login-Zustand zurück. Wird von `ROOT/index.jsp` (athanassiou.me)
per `fetch()` aufgerufen um die private Zone freizuschalten.

**Response (eingeloggt):**
```json
{ "loggedIn": true, "displayName": "Akis", "username": "akis" }
```

**Response (nicht eingeloggt):**
```json
{ "loggedIn": false }
```

---

### `GET /api/article/{id}/blocks`

**Zugang:** öffentlich

Gibt alle Blöcke eines Artikels als EditorJS-kompatibles JSON zurück.

**Response:**
```json
{
  "blocks": [
    { "type": "header", "data": { "text": "Titel", "level": 2 } },
    { "type": "paragraph", "data": { "text": "…" } }
  ]
}
```

## POST-Endpunkte

### `POST /api/article/{id}/blocks`

**Zugang:** Login erforderlich (403 sonst)

Ersetzt alle Blöcke eines Artikels. Request-Body: EditorJS-JSON.

**Request-Body:**
```json
{
  "blocks": [
    { "type": "paragraph", "data": { "text": "Hallo Welt" } }
  ]
}
```

**Response (Erfolg):** `{ "ok": true }`

Intern: `ArticleService.saveBlocks()` — löscht alle alten Blöcke und schreibt neue.

## Fehler-Responses

| Status | Body | Bedeutung |
|--------|------|-----------|
| 400 | `{ "error": "Ungültige ID" }` | ID kein Integer |
| 403 | `{ "error": "Nicht angemeldet" }` | POST ohne Login |
| 404 | `{ "error": "Nicht gefunden" }` | Artikel nicht vorhanden |
| 404 | `{ "error": "Unbekannte Route" }` | Pfad nicht erkannt |
