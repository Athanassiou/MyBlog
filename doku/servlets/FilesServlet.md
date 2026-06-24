# FilesServlet

**Klasse:** `de.myblog.servlet.FilesServlet`
**Mapping:** `/MyBlog/files/*`
**Methode:** nur GET
**Zugang:** öffentlich

Liefert hochgeladene Bilder aus dem Upload-Verzeichnis (`ROOT/`) aus.
Sicherheitsprüfung: Pfade mit `..` werden mit 404 abgewiesen.

## GET `/MyBlog/files/{blogSlug}/{filename}`

```
PathInfo: /{blogSlug}/{filename}
Datei:    ROOT/{blogSlug}/{filename}
```

### Response-Header

| Header | Wert |
|--------|------|
| `Content-Type` | via `Files.probeContentType()` (Fallback: `application/octet-stream`) |
| `Content-Length` | Dateigröße in Bytes |
| `Cache-Control` | `max-age=31536000` (1 Jahr) |

### Fehler

| Status | Ursache |
|--------|---------|
| 404 | Datei nicht gefunden |
| 404 | PathInfo leer oder enthält `..` |

## Hinweis

Da die Dateien unter Tomcat `ROOT/` liegen, sind sie alternativ auch
**direkt** ohne MyBlog-Kontext erreichbar:
```
https://athanassiou.me/ea-blog/bild.jpg
```
Die `/MyBlog/files/…`-URLs sind die kanonischen URLs die EditorJS und
`FilesServlet` verwenden. Beide Pfade zeigen auf dieselbe Datei.
