<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="de.myblog.model.Article, de.myblog.model.Blog, de.myblog.model.Tag" %>
<%@ page import="java.util.*, java.time.format.DateTimeFormatter, java.util.Locale" %>
<%
  Blog   blog   = (Blog)   request.getAttribute("blog");
  String accent = (blog != null && blog.defaultAccentColor != null) ? blog.defaultAccentColor : "#e5a00d";
  String slug   = blog != null ? blog.slug : "";
  List<Article> recent  = (List<Article>) request.getAttribute("recent");
  List<Article> older   = (List<Article>) request.getAttribute("older");
  Map<Integer,String> images = (Map<Integer,String>) request.getAttribute("images");
  DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MMMM yyyy", Locale.GERMAN);
  if (recent == null) recent = Collections.emptyList();
  if (older  == null) older  = Collections.emptyList();
  if (images == null) images = Collections.emptyMap();
  String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= blog != null ? blog.name : "Blog" %> · MyBlog</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/fa/css/all.css">
<link rel="alternate" type="application/rss+xml" title="<%= blog != null ? blog.name : "RSS" %>"
      href="<%= ctx %>/<%= slug %>/feed">
<style>
  :root { --accent:<%= accent %>; --accent-dim:rgba(229,160,13,.10); --border:#e8e8e8;
          --text:#1a1a1a; --muted:#777; }
  * { box-sizing:border-box; margin:0; padding:0; }
  body { font-family:'Segoe UI','Helvetica Neue',Arial,sans-serif; background:#f5f5f5; color:var(--text); }

  /* ── Header ── */
  .header { border-bottom:3px solid var(--accent); padding:44px 0 28px; }
  .header h1 { font-size:34px; font-weight:800; }
  .header p  { color:var(--muted); margin-top:6px; font-size:15px; line-height:1.6; }
  .header-row { max-width:1060px; margin:0 auto; padding:0 32px; display:flex; align-items:flex-end; justify-content:space-between; gap:40px; flex-wrap:wrap; }
  /* ── N3 Site Header ── */
  .site-header {
    background: #d7d7d7; border-bottom: 1px solid #ccc;
    padding: 0 40px; height: 54px;
    display: flex; align-items: center;
    position: sticky; top: 0; z-index: 20;
  }
  .site-logo { flex:1; display:flex; align-items:center; gap:10px; text-decoration:none; }
  .logo-icon {
    width:30px; height:30px; background:var(--accent); border-radius:50%;
    display:flex; align-items:center; justify-content:center;
    color:#111; font-weight:700; font-size:11px; letter-spacing:.4px; flex-shrink:0;
  }
  .logo-text { font-size:15px; font-weight:700; color:#222; letter-spacing:.2px; }
  .logo-text span { color:var(--accent); }
  .site-header-center { flex:1; display:flex; justify-content:center; align-items:center; }
  #user-greeting { font-size:14px; font-weight:600; color:#555; display:none; }
  .site-header-right { flex:1; display:flex; align-items:center; justify-content:flex-end; gap:12px; }
  #site-clock { font-size:13px; font-weight:700; color:#333; font-variant-numeric:tabular-nums; }
  .header-login-btn {
    font-family:inherit; font-size:12px; font-weight:600; padding:5px 14px;
    border-radius:4px; cursor:pointer; text-decoration:none; letter-spacing:.3px;
    border:1px solid var(--accent); background:transparent; color:var(--accent);
    transition:background .15s, color .15s;
  }
  .header-login-btn:hover { background:var(--accent); color:#111; }
  /* ── View-Toggle (Schaufenster ↔ Liste) ── */
  .view-toggle { font-size:13px; color:var(--muted); text-decoration:none; font-weight:600; display:inline-block; margin-top:8px; }
  .view-toggle:hover { color:var(--accent); }
  .header-img { width:220px; flex-shrink:0; border-radius:6px; overflow:hidden; }
  .header-img img { width:100%; display:block; border-radius:6px; }
  .search-form { display:flex; gap:6px; }
  .search-input { border:1.5px solid var(--border); border-radius:5px; padding:8px 12px;
    font-family:inherit; font-size:14px; outline:none; transition:border-color .15s; width:260px; }
  .search-input:focus { border-color:var(--accent); }
  .search-btn { background:var(--accent); color:#fff; border:none; border-radius:5px;
    padding:8px 14px; font-family:inherit; font-size:13px; font-weight:600; cursor:pointer; }
  .tag-pill { display:inline-block; background:#f0f0f0; color:#555; border-radius:20px;
    padding:2px 9px; font-size:11px; font-weight:600; text-decoration:none; transition:background .15s; }
  .tag-pill:hover { background:var(--accent); color:#fff; }
  .cmt-badge { font-size:13px; color:var(--accent); font-weight:600; white-space:nowrap; }

  /* ── Sections ── */
  .content { max-width:1060px; margin:0 auto; padding:0 32px 60px; }
  .section-title {
    font-size:20px; font-weight:700; margin:36px 0 16px; color:#333;
    display:flex; align-items:center; gap:12px;
  }
  .section-title::after { content:''; flex:1; height:2px; background:var(--accent); }

  /* ── Shelf (horizontal scroll) ── */
  .shelf {
    display:flex; overflow-x:auto; gap:24px;
    padding:4px 2px 18px; scroll-snap-type:x mandatory;
    -webkit-overflow-scrolling:touch;
  }
  .shelf::-webkit-scrollbar { height:5px; }
  .shelf::-webkit-scrollbar-track { background:#ddd; border-radius:3px; }
  .shelf::-webkit-scrollbar-thumb { background:#bbb; border-radius:3px; }

  /* ── Große Karten (neuere Beiträge) ── */
  .card-lg {
    flex:0 0 calc((100% - 48px) / 3); min-width:220px; min-height:420px;
    background:#fff; border-radius:8px; overflow:hidden;
    box-shadow:0 3px 10px rgba(0,0,0,.10);
    text-decoration:none; color:inherit; display:flex; flex-direction:column;
    scroll-snap-align:start; transition:box-shadow .2s, transform .2s;
  }
  .card-lg:hover { box-shadow:0 8px 24px rgba(0,0,0,.18); transform:translateY(-3px); }
  .card-lg-img { width:100%; flex:1; object-fit:cover; display:block; opacity:.8; min-height:0; }
  .card-lg-placeholder {
    flex:1; min-height:0; background:#1c1c1c;
    display:flex; align-items:flex-end; padding:20px;
  }
  .card-lg-placeholder span { color:var(--accent); font-size:18px; font-weight:800; line-height:1.3; }
  .card-lg-body { padding:20px 22px 20px; flex:1; display:flex; flex-direction:column; }
  .card-lg-body h3 { font-size:17px; font-weight:700; margin-bottom:6px; color:#111; line-height:1.35; }
  .card-lg-date { font-size:12px; color:var(--muted); margin-bottom:12px; }
  .card-lg-body p {
    font-size:14px; color:#444; margin:0 0 14px; line-height:1.6; flex:1;
    display:-webkit-box; -webkit-line-clamp:8; -webkit-box-orient:vertical; overflow:hidden;
  }
  .card-footer { display:flex; align-items:center; justify-content:space-between; margin-top:auto; }
  .card-btn { padding:5px 12px; background:#fff; border:1px solid #ccc;
    font-size:11px; font-weight:700; color:#333; border-radius:3px; }
  .card-lg:hover .card-btn { background:#f0f0f0; border-color:#999; }

  /* ── Kleine Karten (ältere Beiträge) ── */
  .card-sm {
    flex:0 0 calc((100% - 80px) / 6); min-width:160px;
    background:#fff; border-radius:6px; overflow:hidden;
    box-shadow:0 2px 6px rgba(0,0,0,.08);
    text-decoration:none; color:inherit; display:block;
    scroll-snap-align:start; transition:box-shadow .2s, transform .2s;
  }
  .card-sm:hover { box-shadow:0 5px 16px rgba(0,0,0,.16); transform:translateY(-2px); }
  .card-sm-img { width:100%; height:110px; object-fit:cover; display:block; opacity:.8; }
  .card-sm-placeholder {
    width:100%; height:110px; background:#dde;
    display:flex; align-items:center; justify-content:center; font-size:28px; color:#999;
  }
  .card-sm-body { padding:8px 10px 10px; }
  .card-sm-body h5 {
    margin:0 0 3px; font-size:12px; font-weight:700; line-height:1.3; color:#222;
    display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden;
  }
  .card-sm-date { font-size:10px; color:var(--muted); margin-bottom:4px; }
  .card-sm-body p {
    font-size:11px; color:#555; margin:0; line-height:1.4;
    display:-webkit-box; -webkit-line-clamp:3; -webkit-box-orient:vertical; overflow:hidden;
  }


  @media(max-width:960px) { .card-lg { flex:0 0 calc((100% - 16px) / 2); } }
  @media(max-width:640px) {
    .header { padding:24px 20px 20px; }
    .header-row { flex-direction:column; }
    .header-img { width:100%; }
    .content { padding:0 16px 40px; }
    .card-lg { flex:0 0 80%; }
    .card-sm { flex:0 0 58%; }
  }
</style>
</head>
<body>

<header class="site-header">
  <a class="site-logo" href="/">
    <div class="logo-icon">EA</div>
    <span class="logo-text"><span>athanassiou</span>.me</span>
  </a>
  <div class="site-header-center">
    <span id="user-greeting"></span>
  </div>
  <div class="site-header-right">
    <span id="site-clock"></span>
    <a class="header-login-btn" id="header-login-btn" href="/MyBlog/login?next=/">Anmelden</a>
  </div>
</header>

<div class="header">
  <div class="header-row">
    <div>
      <h1><%= blog != null ? blog.name : "" %></h1>
      <% if (blog != null && blog.description != null && !blog.description.isEmpty()) { %>
      <p><%= blog.description %></p>
      <% } %>
      <% if (blog != null) { %>
      <a href="<%= ctx %>/<%= slug %>/list" class="view-toggle">☰ Listenansicht</a>
      <% } %>
    </div>
    <form class="search-form" method="get" action="<%= ctx %>/<%= slug %>/">
      <input class="search-input" type="search" name="q" placeholder="Suche …">
      <button class="search-btn" type="submit">↵</button>
    </form>
  </div>
</div>

<div class="content">

<%-- ── Neuere Beiträge (große Karten) ── --%>
<% if (!recent.isEmpty()) { %>
<div class="section-title">Neuere Beiträge</div>
<div class="shelf">
  <% for (Article a : recent) {
       String imgUrl  = images.get(a.id);
       String dateStr = a.publishedAt != null ? a.publishedAt.format(fmt) : "";
       String artUrl  = ctx + "/" + slug + "/" + a.slug;
  %>
  <a class="card-lg" href="<%= artUrl %>">
    <% if (imgUrl != null) { %>
    <img class="card-lg-img" src="<%= imgUrl %>" alt="<%= a.title %>">
    <% } else { %>
    <div class="card-lg-placeholder">
      <span><%= a.title %></span>
    </div>
    <% } %>
    <div class="card-lg-body">
      <h3><%= a.title %></h3>
      <div class="card-lg-date"><%= dateStr %></div>
      <% if (a.subtitle != null && !a.subtitle.isEmpty()) { %>
      <p><%= a.subtitle %></p>
      <% } %>
      <% if (a.tags != null && !a.tags.isEmpty()) { %>
      <div style="margin-bottom:10px;display:flex;flex-wrap:wrap;gap:4px">
        <% for (Tag t : a.tags) { %>
        <span class="tag-pill">#<%= t.name %></span>
        <% } %>
      </div>
      <% } %>
      <div class="card-footer">
        <span class="card-btn">MEHR DAZU »</span>
        <% if (a.commentCount > 0) { %>
        <span class="cmt-badge"><i class="fa-regular fa-comment"></i> <%= a.commentCount %></span>
        <% } %>
      </div>
    </div>
  </a>
  <% } %>
</div>
<% } %>

<%-- ── Ältere Beiträge (kleine Karten) ── --%>
<% if (!older.isEmpty()) { %>
<div class="section-title">Ältere Beiträge</div>
<div class="shelf">
  <% for (Article a : older) {
       String imgUrl  = images.get(a.id);
       String dateStr = a.publishedAt != null ? a.publishedAt.format(fmt) : "";
       String artUrl  = ctx + "/" + slug + "/" + a.slug;
  %>
  <a class="card-sm" href="<%= artUrl %>">
    <% if (imgUrl != null) { %>
    <img class="card-sm-img" src="<%= imgUrl %>" alt="<%= a.title %>">
    <% } else { %>
    <div class="card-sm-placeholder">📄</div>
    <% } %>
    <div class="card-sm-body">
      <h5><%= a.title %></h5>
      <div class="card-sm-date"><%= dateStr %></div>
      <% if (a.subtitle != null && !a.subtitle.isEmpty()) { %>
      <p><%= a.subtitle %></p>
      <% } %>
    </div>
  </a>
  <% } %>
</div>
<% } %>

</div><!-- /content -->

<script>
(async () => {
  try {
    const r = await fetch('/MyBlog/api/session', { credentials: 'include' });
    const d = await r.json();
    if (d.loggedIn) {
      const g = document.getElementById('user-greeting');
      g.textContent = 'Hallo, ' + d.displayName;
      g.style.display = 'block';
      const btn = document.getElementById('header-login-btn');
      if (btn) btn.style.display = 'none';
    }
  } catch(e) {}
})();
(function() {
  const el = document.getElementById('site-clock');
  function tick() {
    const now = new Date();
    const date = now.toLocaleDateString('de-DE', { weekday:'short', day:'2-digit', month:'2-digit', year:'numeric' });
    const time = now.toLocaleTimeString('de-DE', { hour:'2-digit', minute:'2-digit', second:'2-digit' });
    el.innerHTML = '<span style="color:var(--accent)">' + date + '</span>'
                 + '<span style="color:#999"> · </span>' + time;
  }
  tick();
  setInterval(tick, 1000);
})();
</script>
</body>
</html>
