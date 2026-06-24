# Java-Klassen — Übersicht

```
de.myblog
├── model/
│   ├── Article.java        Artikel mit Blöcken, Tags, Kommentarzähler
│   ├── Block.java          Einzelner EditorJS-Block (JSONB)
│   ├── Blog.java           Blog mit Sichtbarkeit und Rolle des Users
│   ├── BlogMember.java     Mitgliedschaft: User + Rolle in einem Blog
│   ├── Comment.java        Kommentar mit Threading via parentId
│   ├── Tag.java            Tag (blogweit, nicht global)
│   └── User.java           Benutzer-Account
├── service/
│   ├── ArticleService.java CRUD Artikel + Blöcke, Suche, Nachbarn
│   ├── BlogService.java    CRUD Blogs + Mitglieder-Verwaltung
│   ├── CommentService.java Kommentare lesen, anlegen, löschen
│   ├── TagService.java     Tags lesen, setzen (find-or-create)
│   └── UserService.java    Auth, CRUD User, Blog-Rolle abfragen
├── servlet/
│   └── SessionFilter.java  Befüllt Session-Attribute nach SSO-Login
└── util/
    └── DB.java             HikariCP-Pool, JNDI-URL-Lookup
```

## Abhängigkeiten

```
Servlet / JSP
    └── Service (z.B. ArticleService)
            └── DB.get()  →  HikariCP  →  PostgreSQL
```

Services haben **keine** Abhängigkeiten untereinander. Jeder Service
instanziiert direkt `DB.get()` für jede Abfrage und gibt Verbindungen
sofort wieder frei (try-with-resources).

## Einzeldokumentation

| Paket | Datei |
|-------|-------|
| **model** | [Article](model/Article.md) · [Block](model/Block.md) · [Blog](model/Blog.md) · [BlogMember](model/BlogMember.md) · [Comment](model/Comment.md) · [Tag](model/Tag.md) · [User](model/User.md) |
| **service** | [ArticleService](services/ArticleService.md) · [BlogService](services/BlogService.md) · [CommentService](services/CommentService.md) · [TagService](services/TagService.md) · [UserService](services/UserService.md) |
| **util** | [DB](util/DB.md) · [SessionFilter](util/SessionFilter.md) |
