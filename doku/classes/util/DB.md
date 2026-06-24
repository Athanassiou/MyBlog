# DB

**Paket:** `de.myblog.util`  
**Datei:** `DB.java`

Singleton-Connection-Pool via HikariCP. Einziger Datenbankzugriffspunkt im gesamten Projekt.

## Verwendung

```java
try (Connection c = DB.get()) {
    // PreparedStatement, executeQuery, ...
}
```

Verbindungen werden per `try-with-resources` automatisch an den Pool zurückgegeben.

## Initialisierung

Double-Checked Locking — der Pool wird beim ersten Aufruf von `DB.get()` einmalig aufgebaut:

```
DB.get()
  → JNDI-Lookup: java:comp/env/DB_URL
  → Class.forName("org.postgresql.Driver")   (Fallback falls WAR-Classloader scheitert)
  → HikariDataSource(jdbcUrl=DB_URL, maxPoolSize=10, minIdle=2)
```

## JNDI-Konfiguration (`DB_URL`)

Der Wert kommt aus der Tomcat-Kontextdatei `MyBlog.xml`:

| Umgebung | DB_URL |
|----------|--------|
| Dev | `jdbc:postgresql://localhost:5432/myblog_db?user=myblog_app` |
| Prod | `jdbc:postgresql://localhost:5432/myblog_db?user=myblog_app` |

```xml
<!-- MyBlog.xml -->
<Environment name="DB_URL" type="java.lang.String"
             value="jdbc:postgresql://localhost:5432/myblog_db?user=myblog_app"/>
```

## Pool-Einstellungen

| Parameter | Wert |
|-----------|------|
| `maximumPoolSize` | 10 |
| `minimumIdle` | 2 |
| Kein Passwort | PostgreSQL `trust`-Auth für localhost |

## DB-Rolle

HikariCP verbindet sich als `myblog_app` (PostgreSQL-Rolle).  
Diese Rolle hat `SELECT, INSERT, UPDATE, DELETE` auf allen App-Tabellen.  
Der Tomcat-Realm nutzt eine separate Rolle `tomcat` (nur `SELECT` auf `users` und `user_roles`).
