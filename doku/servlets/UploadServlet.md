# UploadServlet

**Klasse:** `de.myblog.servlet.UploadServlet`
**Mapping:** `/MyBlog/upload`
**Methode:** nur POST (Multipart)
**Zugang:** Login erforderlich (403 + `{ "success": 0 }` sonst)

Nimmt Bild-Uploads von EditorJS entgegen, speichert sie unter
`ROOT/{blogSlug}/` und gibt eine EditorJS-kompatible JSON-Antwort zurück.

## POST `/MyBlog/upload`

### Multipart-Limits

| Limit | Wert |
|-------|------|
| Schwellwert für Disk-Speicherung | 1 MB |
| Max. Dateigröße | 20 MB |
| Max. Request-Größe | 25 MB |

### Request-Parameter

| Parameter | Typ | Bedeutung |
|-----------|-----|-----------|
| `image` | Part (Datei) | Hochzuladendes Bild |
| `blogSlug` | String | Ziel-Unterverzeichnis (default: `ea-blog`) |

### Ablauf

```
1. Session prüfen (userId muss vorhanden sein)
2. blogSlug bereinigen: nur [a-zA-Z0-9_-]
3. Dateiname bereinigen (sanitize): Pfad-Traversal verhindern,
   Sonderzeichen → Underscore, alles Lowercase
4. uniqueFile(): bei Namenskollision -1, -2, … anhängen
5. Datei schreiben nach ROOT/{blogSlug}/{filename}
6. URL zurückgeben: /MyBlog/files/{blogSlug}/{filename}
```

### Response (Erfolg)

```json
{
  "success": 1,
  "file": { "url": "/MyBlog/files/ea-blog/bild.jpg" }
}
```

### Response (Fehler)

```json
{ "success": 0 }
```

## Upload-Verzeichnis

Gelesen aus JNDI-Env-Entry `ROOT` (gesetzt in `MyBlog.xml`):

| Umgebung | Pfad |
|----------|------|
| Dev | `/usr/local/apache-tomcat-10.1.8/webapps/ROOT/` |
| Prod | `/opt/tomcat/webapps/ROOT/` |
| Fallback | `~/myblog-uploads/` |

Dateien liegen also direkt im Tomcat ROOT — damit sind sie
ohne eigenen Servlet-Umweg über `http://.../ea-blog/bild.jpg` erreichbar.
Für den Zugriff über den `/MyBlog/files/…`-Pfad ist `FilesServlet` zuständig.

## EditorJS-Integration

In `dashboard/editor.jsp` ist der Upload-Endpunkt konfiguriert als:
```javascript
endpoints: { byFile: '/MyBlog/upload?blogSlug=<%= blogSlug %>' }
```
