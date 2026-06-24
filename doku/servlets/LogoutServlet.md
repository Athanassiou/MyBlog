# LogoutServlet

**Klasse:** `de.myblog.servlet.LogoutServlet`
**Mapping:** `/MyBlog/logout`
**Methode:** nur POST

Meldet den User vollständig ab: invalidiert die HTTP-Session und ruft
`request.logout()` auf, damit auch der Tomcat-SSO-Cookie gelöscht wird.

## POST `/MyBlog/logout`

```
session.invalidate()      → lokale Session löschen
request.logout()          → SSO-Ticket beim Tomcat-Valve entwerten
Redirect → /              → athanassiou.me Homepage
```

Das Formular in den JSPs muss `method="POST"` verwenden (GET wäre unsicher
und würde durch Browser-Prefetch versehentlich ausloggen können).

```html
<form method="POST" action="/MyBlog/logout">
    <button type="submit">Abmelden</button>
</form>
```
