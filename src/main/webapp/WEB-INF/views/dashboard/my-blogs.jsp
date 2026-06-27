<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="de.myblog.model.Blog, java.util.List" %>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Dashboard · MyBlog</title>
<style>
  :root { --accent:#e5a00d; --accent-dim:rgba(229,160,13,.10); --border:#e8e8e8; --text:#1a1a1a; --muted:#777; }
  <%@ include file="/WEB-INF/views/fragments/dashboard-common.css" %>
  <%@ include file="/WEB-INF/views/fragments/site-header-styles.jsp" %>
  .content { max-width:1060px; }
  .grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:16px; }
  .blog-card { background:#fff; border:1px solid var(--border); border-radius:10px;
    padding:24px 22px; text-decoration:none; color:inherit; display:block;
    transition:box-shadow .15s,border-color .15s; position:relative; }
  .blog-card:hover { box-shadow:0 4px 16px rgba(0,0,0,.08); }
  .card-bar { height:3px; border-radius:2px; margin-bottom:14px; }
  .card-name { font-size:17px; font-weight:800; margin-bottom:4px; }
  .card-desc { font-size:12px; color:var(--muted); line-height:1.55; margin-bottom:10px; }
  .card-role { font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:.4px; }
  .role-owner { color:#92400e; } .role-admin { color:#5b21b6; }
  .role-author { color:#15803d; } .role-contributor { color:#6b7280; }
  /* Neuer-Blog-Dialog */
  .overlay { position:fixed; inset:0; background:rgba(0,0,0,.35);
    display:none; align-items:center; justify-content:center; z-index:100; }
  .overlay.open { display:flex; }
  .dialog { background:#fff; border-radius:10px; padding:36px 40px; width:100%; max-width:460px;
    box-shadow:0 8px 40px rgba(0,0,0,.15); }
  .dialog h2 { font-size:20px; font-weight:800; margin-bottom:22px; }
  .dialog-actions { display:flex; gap:10px; margin-top:20px; }
</style>
</head>
<body>

<%
  String hBlogSlug = null; String hBlogName = null;
  String hBlogLink = null;
  String hPageTitle = null; String hTopbarTitle = null;
%>
<%@ include file="/WEB-INF/views/fragments/header-dashboard.jsp" %>

<div class="content">
  <div class="page-header">
    <h1>Meine Blogs: Bearbeiten</h1>
    <button class="btn btn-primary" onclick="document.getElementById('new-overlay').classList.add('open')">+ Neuer Blog</button>
  </div>

  <%
    @SuppressWarnings("unchecked") List<Blog> blogs = (List<Blog>) request.getAttribute("blogs");
  %>

  <% if (blogs == null || blogs.isEmpty()) { %>
  <div class="empty"><p>Du bist noch kein Mitglied in einem Blog.</p></div>
  <% } else { %>
  <div class="grid">
    <% for (Blog b : blogs) {
       String acc = b.defaultAccentColor != null ? b.defaultAccentColor : "#e5a00d"; %>
    <a class="blog-card" href="<%= request.getContextPath() %>/dashboard/<%= b.slug %>/">
      <div class="card-bar" style="background:<%= acc %>"></div>
      <div class="card-name"><%= b.name %></div>
      <% if (b.description != null && !b.description.isEmpty()) { %>
      <div class="card-desc"><%= b.description %></div>
      <% } %>
      <div class="card-role role-<%= b.userRole %>"><%= b.userRole %></div>
    </a>
    <% } %>
  </div>
  <% } %>
</div>

<!-- Neuer-Blog-Dialog -->
<div class="overlay" id="new-overlay" onclick="if(event.target===this)this.classList.remove('open')">
  <div class="dialog">
    <h2>Neuer Blog</h2>
    <form method="post" action="<%= request.getContextPath() %>/dashboard/">
      <div class="field">
        <label>Name *</label>
        <input type="text" name="name" required autofocus oninput="autoSlug(this.value)">
      </div>
      <div class="field">
        <label>Slug (URL) *</label>
        <input type="text" id="new-slug" name="slug" required style="font-family:monospace;font-size:13px">
      </div>
      <div class="field">
        <label>Beschreibung</label>
        <textarea name="description" rows="2" style="resize:vertical"></textarea>
      </div>
      <input type="hidden" name="accentColor" value="#e5a00d">
      <div class="dialog-actions">
        <button type="button" class="btn" style="border:1px solid var(--border);background:#fff"
                onclick="document.getElementById('new-overlay').classList.remove('open')">Abbrechen</button>
        <button type="submit" class="btn btn-primary" style="flex:1;justify-content:center">Blog anlegen</button>
      </div>
    </form>
  </div>
</div>

<script>
function autoSlug(v) {
  const u = {ä:'ae',ö:'oe',ü:'ue',ß:'ss',Ä:'ae',Ö:'oe',Ü:'ue'};
  document.getElementById('new-slug').value = v.toLowerCase()
    .replace(/[äöüßÄÖÜ]/g,m=>u[m]||m).replace(/[^a-z0-9\s-]/g,'')
    .trim().replace(/\s+/g,'-').replace(/-+/g,'-');
}
</script>
<script>
<%@ include file="/WEB-INF/views/fragments/site-header-clock.jsp" %>
</script>
</body></html>
