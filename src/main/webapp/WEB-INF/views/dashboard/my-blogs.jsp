<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="de.myblog.model.Blog, java.util.List" %>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Dashboard · MyBlog</title>
<style>
  :root { --accent:#e5a00d; --accent-dim:rgba(229,160,13,.10); --border:#e8e8e8; --text:#1a1a1a; --muted:#777; }
  * { box-sizing:border-box; margin:0; padding:0; }
  body { font-family:'Segoe UI','Helvetica Neue',Arial,sans-serif; background:#f5f5f5; color:var(--text); min-height:100vh; }
  /* ── N3 Site Header ── */
  .site-header { background:#d7d7d7; border-bottom:1px solid #ccc; padding:0 40px; height:54px;
    display:flex; align-items:center; position:sticky; top:0; z-index:20; }
  .site-header-left { flex:1; display:flex; align-items:center; gap:10px; }
  .site-logo { display:flex; align-items:center; gap:28px; text-decoration:none; }
  .logo-icon { width:32px; height:32px; background:var(--accent); border-radius:50%;
    display:flex; align-items:center; justify-content:center;
    color:#111; font-weight:700; font-size:12px; letter-spacing:.4px; flex-shrink:0; }
  .logo-text { font-size:16px; font-weight:700; color:#222; letter-spacing:.3px; }
  .logo-text span { color:var(--accent); }
  .site-header-center { flex:1; display:flex; justify-content:center; align-items:center; }
  .site-greeting { font-size:14px; font-weight:600; color:#555; }
  .site-header-right { flex:1; display:flex; align-items:center; justify-content:flex-end; gap:12px; }
  #site-clock { font-size:14px; font-weight:700; color:#333; font-variant-numeric:tabular-nums; letter-spacing:.3px; }
  .header-nav-link { font-size:13px; color:#555; text-decoration:none; padding:0 4px; }
  .header-nav-link:hover { color:var(--accent); }
  .header-logout { background:transparent; border:1px solid var(--accent); border-radius:6px;
    padding:6px 16px; font-family:inherit; font-size:12px; font-weight:600; letter-spacing:.3px;
    color:var(--accent); cursor:pointer; transition:background .15s,color .15s,border-color .15s; }
  .header-logout:hover { background:var(--accent); color:#111; }
  .content { max-width:1060px; margin:0 auto; padding:40px 24px 80px; }
  .page-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:28px; }
  .page-header h1 { font-size:22px; font-weight:800; }
  .btn { display:inline-flex; align-items:center; gap:6px; border-radius:5px; padding:8px 16px;
    font-family:inherit; font-size:13px; font-weight:600; cursor:pointer; border:1px solid transparent;
    text-decoration:none; transition:opacity .15s,background .15s; }
  .btn-primary { background:var(--accent); color:#fff; }
  .btn-primary:hover { opacity:.88; }
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
  .empty { text-align:center; padding:60px 0; color:var(--muted); }
  /* Neuer-Blog-Dialog */
  .overlay { position:fixed; inset:0; background:rgba(0,0,0,.35);
    display:none; align-items:center; justify-content:center; z-index:100; }
  .overlay.open { display:flex; }
  .dialog { background:#fff; border-radius:10px; padding:36px 40px; width:100%; max-width:460px;
    box-shadow:0 8px 40px rgba(0,0,0,.15); }
  .dialog h2 { font-size:20px; font-weight:800; margin-bottom:22px; }
  .field { display:flex; flex-direction:column; gap:5px; margin-bottom:14px; }
  .field label { font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:.5px; color:var(--muted); }
  .field input, .field textarea { border:1px solid var(--border); border-radius:5px; padding:9px 12px;
    font-family:inherit; font-size:14px; color:var(--text); outline:none; transition:border-color .15s; }
  .field input:focus, .field textarea:focus { border-color:var(--accent); }
  .dialog-actions { display:flex; gap:10px; margin-top:20px; }
</style>
</head>
<body>

<header class="site-header">
  <div class="site-header-left">
    <a class="site-logo" href="/">
      <div class="logo-icon">EA</div>
      <span class="logo-text"><span>athanassiou</span>.me</span>
    </a>
  </div>
  <div class="site-header-center">
    <span class="site-greeting">Hallo, <%= session.getAttribute("displayName") %></span>
  </div>
  <div class="site-header-right">
    <span id="site-clock"></span>
    <form method="post" action="<%= request.getContextPath() %>/logout" style="display:inline">
      <button type="submit" class="header-logout">Abmelden</button>
    </form>
  </div>
</header>

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
(function() {
  const el = document.getElementById('site-clock');
  function tick() {
    const now = new Date();
    const date = now.toLocaleDateString('de-DE', { weekday:'short', day:'2-digit', month:'2-digit', year:'numeric' });
    const time = now.toLocaleTimeString('de-DE', { hour:'2-digit', minute:'2-digit', second:'2-digit' });
    el.innerHTML = '<span style="color:var(--accent)">' + date + '</span><span style="color:#999"> · </span>' + time;
  }
  tick(); setInterval(tick, 1000);
})();
</script>
</body></html>
