# SessionFilter

**Paket:** `de.myblog.servlet`  
**Datei:** `SessionFilter.java`  
**Typ:** `jakarta.servlet.Filter`

Befüllt Session-Attribute aus der Datenbank, nachdem Tomcat den User per SSO authentifiziert hat.

## Aufgabe

Nach einem SSO-Login kennt Tomcat den `Principal` (Username), aber die HTTP-Session
enthält noch keine App-Attribute (`userId`, `displayName`). `SessionFilter`
schließt diese Lücke bei jedem Request, bei dem ein Principal vorhanden ist
aber die Session noch kein `userId` enthält.

## Ablauf

```
Request eingehend
  ↓
principal = request.getUserPrincipal()
  ↓ null → weiter (kein Login)
  ↓
session.getAttribute("userId") == null?
  ↓ nein → weiter (bereits befüllt)
  ↓
UserService.findByUsername(principal.getName())
  ↓
session.setAttribute("userId", user.id)
session.setAttribute("username", user.username)
session.setAttribute("displayName", user.displayName)
  ↓
chain.doFilter(...)
```

## Session-Attribute

| Key | Typ | Quelle |
|-----|-----|--------|
| `userId` | `int` | `users.id` |
| `username` | `String` | `users.username` |
| `displayName` | `String` | `users.display_name` |

## Konfiguration (web.xml)

```xml
<filter>
    <filter-name>SessionFilter</filter-name>
    <filter-class>de.myblog.servlet.SessionFilter</filter-class>
</filter>
<filter-mapping>
    <filter-name>SessionFilter</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>
```

## Hinweis

Der Filter läuft auf jedem Request (`/*`), prüft aber nur dann die DB,
wenn tatsächlich ein Principal vorhanden und `userId` noch nicht in der
Session ist. Im Normalfall (bereits eingeloggt, Session befüllt) fällt er
sofort durch — kein DB-Hit.
