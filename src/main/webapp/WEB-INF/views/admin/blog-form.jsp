<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="de.myblog.model.Blog" %>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<%
  Blog   blog   = (Blog)   request.getAttribute("blog");
  String error  = (String) request.getAttribute("error");
  boolean isNew = (blog == null);
  String formAction = isNew
      ? request.getContextPath() + "/admin/blogs/new"
      : request.getContextPath() + "/admin/blogs/" + blog.id + "/edit";
%>
<title><%= isNew ? "Neuer Blog" : "Blog bearbeiten" %> · Admin · MyBlog</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Raleway:wght@400;600;700;800&display=swap" rel="stylesheet">
<style>
<%@ include file="admin-common.css" %>
.color-row { display:flex; align-items:center; gap:10px; }
input[type=color] { width:36px; height:36px; border:1px solid var(--border); border-radius:5px;
  padding:2px; cursor:pointer; background:none; }
.color-hex { border:1px solid var(--border); border-radius:5px; padding:9px 12px;
  font-family:monospace; font-size:13px; width:110px; outline:none; color:var(--text); }
.color-hex:focus { border-color:var(--accent); }
</style>
</head>
<body>
<%@ include file="admin-nav.html" %>
<div class="content">
  <div class="page-header">
    <div>
      <a href="<%= request.getContextPath() %>/admin/blogs/" style="font-size:13px;color:var(--muted);text-decoration:none">← Alle Blogs</a>
      <h1 style="margin-top:4px"><%= isNew ? "Neuer Blog" : "Blog bearbeiten" %></h1>
    </div>
  </div>

  <% if (error != null) { %>
  <div class="error-box"><%= error %></div>
  <% } %>

  <div class="card" style="max-width:560px">
    <form method="post" action="<%= formAction %>">
      <% if (isNew) { %>
      <div class="field">
        <label for="slug">Slug (URL) *</label>
        <input type="text" id="slug" name="slug" required
               style="font-family:monospace"
               value="<%= request.getParameter("slug") != null ? request.getParameter("slug") : "" %>"
               oninput="this.value=this.value.toLowerCase().replace(/[^a-z0-9-]/g,'')">
        <span style="font-size:11px;color:var(--muted);margin-top:2px">Kann später nicht geändert werden.</span>
      </div>
      <% } %>

      <div class="field">
        <label for="name">Name *</label>
        <input type="text" id="name" name="name" required
               value="<%= isNew ? (request.getParameter("name")!=null?request.getParameter("name"):"") : (blog.name!=null?blog.name:"") %>"
               <% if (isNew) { %>oninput="autoSlug(this.value)"<% } %>>
      </div>

      <div class="field">
        <label for="description">Beschreibung</label>
        <input type="text" id="description" name="description"
               value="<%= isNew ? (request.getParameter("description")!=null?request.getParameter("description"):"") : (blog.description!=null?blog.description:"") %>">
      </div>

      <div class="field">
        <label>Akzentfarbe</label>
        <%
          String defAccent = isNew ? "#e5a00d" : (blog.defaultAccentColor != null ? blog.defaultAccentColor : "#e5a00d");
        %>
        <div class="color-row">
          <input type="color" id="color-picker" value="<%= defAccent %>" oninput="syncColor(this.value)">
          <input type="text" class="color-hex" id="color-hex" name="accentColor" maxlength="7"
                 value="<%= defAccent %>" oninput="syncColorFromHex(this.value)">
        </div>
      </div>

      <% if (!isNew) { %>
      <div class="field">
        <label for="visibility">Sichtbarkeit</label>
        <select id="visibility" name="visibility" class="role-select" style="width:180px">
          <option value="public"  <%= "public".equals(blog.visibility)  ? "selected" : "" %>>Öffentlich</option>
          <option value="private" <%= "private".equals(blog.visibility) ? "selected" : "" %>>Privat</option>
          <option value="invite"  <%= "invite".equals(blog.visibility)  ? "selected" : "" %>>Nur Eingeladene</option>
        </select>
      </div>
      <% } %>

      <div style="display:flex;gap:10px;margin-top:20px">
        <a href="<%= request.getContextPath() %>/admin/blogs/" class="btn btn-ghost">Abbrechen</a>
        <button type="submit" class="btn btn-primary"><%= isNew ? "Blog anlegen" : "Speichern" %></button>
      </div>
    </form>
  </div>
</div>

<script>
function autoSlug(v) {
  const u = {ä:'ae',ö:'oe',ü:'ue',ß:'ss',Ä:'ae',Ö:'oe',Ü:'ue'};
  const el = document.getElementById('slug');
  if (el && !el._edited) {
    el.value = v.toLowerCase().replace(/[äöüßÄÖÜ]/g,m=>u[m]||m)
      .replace(/[^a-z0-9\s-]/g,'').trim().replace(/\s+/g,'-').replace(/-+/g,'-');
  }
}
function syncColor(hex) {
  document.getElementById('color-hex').value = hex;
}
function syncColorFromHex(val) {
  if (/^#[0-9a-fA-F]{6}$/.test(val))
    document.getElementById('color-picker').value = val;
}
const slugEl = document.getElementById('slug');
if (slugEl) slugEl.addEventListener('input', () => slugEl._edited = true);
</script>
</body></html>
