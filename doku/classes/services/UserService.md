# UserService

**Paket:** `de.myblog.service`  
**Datei:** `UserService.java`  
**Abhängigkeit:** `org.mindrot.jbcrypt.BCrypt`

Authentifizierung, CRUD User, Blog-Rollen abfragen. Alle Methoden werfen `SQLException`.

## Methoden

### `findByUsername(String username) → User`

User nach Benutzername. `null` wenn nicht gefunden.

---

### `findById(int id) → User`

User nach Primärschlüssel. `null` wenn nicht gefunden.

---

### `authenticate(String username, String rawPassword) → User`

Prüft Passwort via **BCrypt**. Gibt User zurück bei Erfolg, sonst `null`.  
Wird **nicht** vom Login-Formular genutzt — dort delegiert `LoginServlet` an den Tomcat-Realm.  
Diese Methode wäre für programmatischen Zugriff gedacht (noch nicht verwendet).

---

### `create(String username, String displayName, String email, String rawPassword) → User`

Legt neuen User an. Passwort wird mit **BCrypt** (Rounds 12) gehasht.

> **Bekannte Inkonsistenz:** Der Tomcat-Realm erwartet SHA-256. Via `create()` angelegte
> User können sich daher nicht über das Login-Formular anmelden. Direkt in der DB
> angelegte User (SQL mit SHA-256) funktionieren.

---

### `listAll() → List<User>`

Alle User der Plattform, alphabetisch. Nur für Admin-Ansicht.

---

### `getRoleInBlog(int userId, int blogId) → String`

Gibt die Rolle des Users in einem Blog zurück (`owner`, `admin`, `author`, `contributor`).  
`null` wenn der User kein Mitglied ist.

---

### `resetPassword(int userId, String rawPassword)`

Setzt das Passwort neu — hash via BCrypt.  
Gilt nur für die App-interne Prüfung; für den Tomcat-Realm-Login muss SHA-256
direkt in der DB gesetzt werden.
