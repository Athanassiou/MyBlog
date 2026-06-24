# BlogService

**Paket:** `de.myblog.service`  
**Datei:** `BlogService.java`

CRUD für Blogs und Mitglieder-Verwaltung. Alle Methoden werfen `SQLException`.

## Blog-Abfragen

### `findBySlug(String slug) → Blog`

Blog nach URL-Slug. `null` wenn nicht gefunden.

---

### `findById(int id) → Blog`

Blog nach Primärschlüssel. `null` wenn nicht gefunden.

---

### `listAll() → List<Blog>`

Alle Blogs der Plattform, neueste zuerst. Nur für Admin-Ansicht gedacht.

---

### `listPublic() → List<Blog>`

Nur Blogs mit `visibility='public'`, neueste zuerst.  
Wird auf der Plattform-Homepage angezeigt.

---

### `listForUser(int userId) → List<Blog>`

Alle Blogs, in denen der User Mitglied ist.  
Befüllt `blog.userRole` aus `blog_members.role` — ohne Extra-Query.

```sql
SELECT b.*, bm.role
FROM blogs b JOIN blog_members bm ON b.id=bm.blog_id
WHERE bm.user_id=? ORDER BY b.name
```

## Blog-Schreiben

### `create(String slug, String name, String description, String accentColor, int ownerId) → Blog`

Legt neuen Blog an und fügt den Ersteller automatisch als `owner` in `blog_members` ein.  
`accentColor=null` → `#e5a00d`.

---

### `update(int blogId, String name, String description, String accentColor, String visibility)`

Aktualisiert Name, Beschreibung, Akzentfarbe und Sichtbarkeit.

---

### `delete(int blogId)`

Löscht den Blog (Artikel via Fremdschlüssel, sofern CASCADE gesetzt).

## Mitglieder-Verwaltung

### `listMembers(int blogId) → List<BlogMember>`

Alle Mitglieder eines Blogs mit vollständigem User-Objekt (JOIN auf `users`).  
Sortiert nach Rolle, dann Benutzername.

---

### `addMember(int blogId, int userId, String role)`

Fügt User als Mitglied hinzu. Bei bestehendem Eintrag wird die Rolle aktualisiert
(`ON CONFLICT … DO UPDATE`).

---

### `updateMemberRole(int blogId, int userId, String role)`

Ändert die Rolle eines bestehenden Mitglieds.

---

### `removeMember(int blogId, int userId)`

Entfernt ein Mitglied aus dem Blog.
