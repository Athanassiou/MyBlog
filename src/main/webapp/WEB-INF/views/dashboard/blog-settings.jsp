<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="de.myblog.model.Blog" %>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<%
  Blog   blog     = (Blog)   request.getAttribute("blog");
  String blogSlug = blog != null ? blog.slug : "main";
  String blogName = blog != null ? blog.name : "Blog";
  String error    = (String) request.getAttribute("error");
  String accent   = blog != null && blog.defaultAccentColor != null ? blog.defaultAccentColor : "#e5a00d";
%>
<title><%= blogName %> · Einstellungen · MyBlog</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Raleway:wght@400;600;700;800&display=swap" rel="stylesheet">
<style>
  :root { --accent:<%= accent %>; --accent-dim:rgba(229,160,13,.10); --border:#e8e8e8; --text:#1a1a1a; --muted:#777; }
  * { box-sizing:border-box; margin:0; padding:0; }
  body { font-family:Raleway,sans-serif; background:#f5f5f5; color:var(--text); min-height:100vh; }
  .topbar { background:#fff; border-bottom:1px solid var(--border); padding:0 32px; height:52px;
    display:flex; align-items:center; justify-content:space-between; position:sticky; top:0; z-index:10; }
  .topbar-brand { font-size:17px; font-weight:800; color:var(--accent); text-decoration:none; }
  .topbar-user  { font-size:13px; color:var(--muted); }
  .topbar-user a { color:var(--muted); text-decoration:none; margin-left:14px; }
  .topbar-user a:hover { color:var(--accent); }
  .content { max-width:600px; margin:0 auto; padding:40px 24px 80px; }
  .page-header { margin-bottom:24px; }
  .page-header h1 { font-size:22px; font-weight:800; margin-top:4px; }
  .card { background:#fff; border:1px solid var(--border); border-radius:8px; padding:28px 32px; }
  .btn { display:inline-flex; align-items:center; border-radius:5px; padding:8px 16px;
    font-family:inherit; font-size:13px; font-weight:600; cursor:pointer; border:1px solid transparent;
    text-decoration:none; transition:opacity .15s,background .15s; }
  .btn-primary { background:var(--accent); color:#fff; }
  .btn-primary:hover { opacity:.88; }
  .btn-ghost { background:#fff; color:var(--text); border-color:var(--border); }
  .btn-ghost:hover { border-color:var(--accent); color:var(--accent); }
  .field { display:flex; flex-direction:column; gap:5px; margin-bottom:16px; }
  .field label { font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:.5px; color:var(--muted); }
  .field input, .field select, .field textarea { border:1px solid var(--border); border-radius:5px;
    padding:9px 12px; font-family:inherit; font-size:14px; color:var(--text); outline:none; transition:border-color .15s; }
  .field input:focus, .field select:focus, .field textarea:focus { border-color:var(--accent); }
  .color-row { display:flex; align-items:center; gap:10px; }
  input[type=color] { width:36px; height:36px; border:1px solid var(--border); border-radius:5px;
    padding:2px; cursor:pointer; background:none; }
  .color-hex { font-family:monospace; width:110px; }
  .error-box { background:#fff3f3; border:1px solid #f9c6c6; border-left:3px solid #dc2626;
    border-radius:4px; padding:10px 14px; font-size:14px; color:#b91c1c; margin-bottom:18px; }
</style>
</head>
<body>

<div class="topbar">
  <div style="display:flex;align-items:center;gap:12px">
    <a href="<%= request.getContextPath() %>/dashboard/" class="topbar-brand">MyBlog</a>
    <span style="color:#e8e8e8">/</span>
    <a href="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/" style="font-size:14px;font-weight:700;color:#1a1a1a;text-decoration:none"><%= blogName %></a>
  </div>
  <span class="topbar-user">
    <%= session.getAttribute("displayName") %>
    <a href="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/">← Artikelliste</a>
  </span>
</div>

<div class="content">
  <div class="page-header">
    <a href="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/" style="font-size:13px;color:var(--muted);text-decoration:none">← <%= blogName %></a>
    <h1>Einstellungen</h1>
  </div>

  <% if (error != null) { %>
  <div class="error-box"><%= error %></div>
  <% } %>

  <div class="card">
    <form method="post" action="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/settings">

      <div class="field">
        <label>Slug (URL)</label>
        <input type="text" value="<%= blogSlug %>" disabled style="background:#f5f5f5;color:var(--muted)">
      </div>

      <div class="field">
        <label for="name">Name *</label>
        <input type="text" id="name" name="name" required value="<%= blogName %>">
      </div>

      <div class="field">
        <label for="description">Beschreibung (HTML erlaubt)</label>
        <textarea id="description" name="description" rows="5"
                  style="resize:vertical"><%= blog != null && blog.description != null ? blog.description : "" %></textarea>
      </div>

      <div class="field">
        <label>Akzentfarbe</label>
        <div class="color-row">
          <input type="color" id="color-picker" value="<%= accent %>" oninput="syncColor(this.value)">
          <input type="text" class="field color-hex" id="color-hex" name="accentColor" maxlength="7"
                 value="<%= accent %>" oninput="syncColorFromHex(this.value)"
                 style="border:1px solid var(--border);border-radius:5px;padding:9px 12px">
        </div>
      </div>

      <div class="field">
        <label for="visibility">Sichtbarkeit</label>
        <select id="visibility" name="visibility">
          <option value="public"  <%= blog == null || "public".equals(blog.visibility)  ? "selected" : "" %>>Öffentlich</option>
          <option value="private" <%= blog != null && "private".equals(blog.visibility) ? "selected" : "" %>>Privat</option>
          <option value="invite"  <%= blog != null && "invite".equals(blog.visibility)  ? "selected" : "" %>>Nur Eingeladene</option>
        </select>
      </div>

      <div style="display:flex;gap:10px;margin-top:8px">
        <a href="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/" class="btn btn-ghost">Abbrechen</a>
        <button type="submit" class="btn btn-primary">Speichern</button>
      </div>
    </form>
  </div>

  <!-- ── Gefahrenzone ── -->
  <div class="card" style="margin-top:28px;border-color:#fca5a5;">
    <h3 style="font-size:14px;font-weight:700;color:#dc2626;margin-bottom:12px;">Gefahrenzone</h3>
    <p style="font-size:13px;color:var(--muted);margin-bottom:16px;">
      Den Blog <strong><%= blogName %></strong> und alle dazugehörigen Artikel unwiderruflich löschen.
    </p>
    <form method="post" action="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/delete-blog"
          onsubmit="return confirm('Blog «<%= blogName %>» und alle Artikel wirklich löschen? Das kann nicht rückgängig gemacht werden.')">
      <button type="submit" class="btn"
              style="background:#dc2626;color:#fff;border-color:#dc2626;">Blog löschen</button>
    </form>
  </div>
</div>

<script>
function syncColor(hex) { document.getElementById('color-hex').value = hex; }
function syncColorFromHex(val) {
  if (/^#[0-9a-fA-F]{6}$/.test(val)) document.getElementById('color-picker').value = val;
}
</script>
</body></html>
