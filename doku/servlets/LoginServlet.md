# LoginServlet

**Klasse:** `de.myblog.servlet.LoginServlet`
**Mapping:** `/MyBlog/login`
**Zugang:** öffentlich

Delegiert die Authentifizierung an den Tomcat-Realm (`request.login()`).
Nach erfolgreichem Login werden Session-Attribute aus der DB befüllt.

## GET `/MyBlog/login`

Zeigt das Login-Formular. Wenn der User bereits eingeloggt ist (`getUserPrincipal() != null`),
direkter Redirect auf `/MyBlog/dashboard/`.

**Forward:** `webapp/login.jsp`

### Request-Parameter (GET)

| Parameter | Bedeutung |
|-----------|-----------|
| `next` | Ziel-URL nach Login (wird ans Formular durchgereicht) |

## POST `/MyBlog/login`

### Request-Parameter (POST)

| Parameter | Bedeutung |
|-----------|-----------|
| `username` | Benutzername |
| `password` | Passwort (Klartext, Hashing im Realm) |
| `next` | Ziel-URL nach Erfolg |

### Ablauf

```
request.login(username, password)
  ↓ Tomcat DataSourceRealm prüft gegen myblog_db.users (SHA-256)
  ↓ Erfolg → UserService.findByUsername() → Session befüllen
  ↓ Redirect auf next (wenn vorhanden und beginnt mit "/") oder /dashboard/
  ↓ Fehler → login.jsp mit error-Attribut
```

### Session-Attribute (gesetzt bei Erfolg)

| Attribut | Quelle |
|----------|--------|
| `userId` | `users.id` |
| `username` | `users.username` |
| `displayName` | `users.display_name` |

## Tomcat-Realm-Konfiguration

```xml
<!-- server.xml -->
<Realm className="org.apache.catalina.realm.DataSourceRealm"
       dataSourceName="jdbc/login"
       userTable="users"
       userNameCol="username"
       userCredCol="password_hash"
       userRoleTable="user_roles"
       roleNameCol="role_name">
    <CredentialHandler className="org.apache.catalina.realm.MessageDigestCredentialHandler"
                       algorithm="SHA-256" iterations="1" saltLength="0"/>
</Realm>
```

## SSO

Der Tomcat `SingleSignOn` Valve sorgt dafür, dass ein Login in MyBlog auch
NextThree und MediaBrowser freischaltet (und umgekehrt) — alle drei Apps
nutzen denselben Realm gegen `myblog_db`.
