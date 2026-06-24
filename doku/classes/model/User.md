# User

**Paket:** `de.myblog.model`  
**Datei:** `User.java`

Benutzer-Account auf der Plattform.

## Felder

| Feld | Typ | DB-Spalte | Bedeutung |
|------|-----|-----------|-----------|
| `id` | `int` | `users.id` | Primärschlüssel |
| `username` | `String` | `users.username` | Login-Name (eindeutig) |
| `displayName` | `String` | `users.display_name` | Anzeigename |
| `email` | `String` | `users.email` | E-Mail (eindeutig) |
| `passwordHash` | `String` | `users.password_hash` | Passwort-Hash |
| `avatarUrl` | `String` | `users.avatar_url` | URL zum Profilbild (optional) |
| `createdAt` | `LocalDateTime` | `users.created_at` | Registrierungszeitpunkt |

## Passwort-Hashing

Zwei verschiedene Hash-Verfahren sind im Einsatz — das ist eine bekannte Inkonsistenz:

| Kontext | Verfahren |
|---------|-----------|
| `UserService.create()` / `resetPassword()` | **BCrypt** (Rounds 12) |
| Tomcat DataSourceRealm | **SHA-256**, iterations=1, saltLength=0 |

User, die über `UserService.create()` angelegt werden (Admin-Formular),
können sich **nicht** über den Tomcat-Login authentifizieren — der Realm
erkennt BCrypt-Hashes nicht. Direkt in der DB angelegte User nutzen SHA-256
und funktionieren mit dem Realm. Diese Inkonsistenz muss noch bereinigt werden.

## Session-Attribute

Nach dem Login werden folgende Felder in der HTTP-Session gespeichert:

| Session-Key | Quelle |
|-------------|--------|
| `userId` | `users.id` |
| `username` | `users.username` |
| `displayName` | `users.display_name` |
