<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="de.myblog.model.Article, de.myblog.model.Blog" %>
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
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Raleway:wght@400;600;700;800&display=swap" rel="stylesheet">
<link rel="alternate" type="application/rss+xml" title="<%= blog != null ? blog.name : "RSS" %>"
      href="<%= ctx %>/<%= slug %>/feed">
<style>
  :root { --accent:<%= accent %>; --accent-dim:rgba(229,160,13,.10); --border:#e8e8e8;
          --text:#1a1a1a; --muted:#777; }
  * { box-sizing:border-box; margin:0; padding:0; }
  body { font-family:Raleway,sans-serif; background:#f0f0f0; color:var(--text); }

  /* ── Header ── */
  .home-header { background:#fff; border-bottom:3px solid var(--accent); padding:40px 48px 32px; }
  .home-header .breadcrumb { font-size:13px; color:var(--muted); margin-bottom:16px; }
  .home-header .breadcrumb a { color:var(--muted); text-decoration:none; font-weight:600; }
  .home-header .breadcrumb a:hover { color:var(--accent); }
  .home-header h1 { font-size:36px; font-weight:800; margin-bottom:20px; }
  .header-body { display:flex; gap:40px; align-items:flex-start; }
  .header-text { flex:1; font-size:15px; line-height:1.75; color:#444; }
  .header-text p + p { margin-top:12px; }
  .header-img { width:220px; flex-shrink:0; border-radius:6px; overflow:hidden; }
  .header-img img { width:100%; display:block; border-radius:6px; }
  .view-toggle { display:inline-flex; align-items:center; gap:6px; margin-top:18px;
    font-size:12px; font-weight:700; color:var(--muted); text-decoration:none;
    border:1px solid var(--border); border-radius:20px; padding:5px 12px; }
  .view-toggle:hover { color:var(--accent); border-color:var(--accent); }

  /* ── Sections ── */
  .content { max-width:1400px; margin:0 auto; padding:0 32px 60px; }
  .section-title {
    font-size:20px; font-weight:700; margin:36px 0 16px; color:#333;
    display:flex; align-items:center; gap:12px;
  }
  .section-title::after { content:''; flex:1; height:2px; background:var(--accent); }

  /* ── Shelf (horizontal scroll) ── */
  .shelf {
    display:flex; overflow-x:auto; gap:16px;
    padding:4px 2px 18px; scroll-snap-type:x mandatory;
    -webkit-overflow-scrolling:touch;
  }
  .shelf::-webkit-scrollbar { height:5px; }
  .shelf::-webkit-scrollbar-track { background:#ddd; border-radius:3px; }
  .shelf::-webkit-scrollbar-thumb { background:#bbb; border-radius:3px; }

  /* ── Große Karten (neuere Beiträge) ── */
  .card-lg {
    flex:0 0 calc((100% - 32px) / 3); min-width:260px;
    background:#fff; border-radius:8px; overflow:hidden;
    box-shadow:0 3px 10px rgba(0,0,0,.10);
    text-decoration:none; color:inherit; display:flex; flex-direction:column;
    scroll-snap-align:start; transition:box-shadow .2s, transform .2s;
  }
  .card-lg:hover { box-shadow:0 8px 24px rgba(0,0,0,.18); transform:translateY(-3px); }
  .card-lg-img { width:100%; height:220px; object-fit:cover; display:block; flex-shrink:0; }
  .card-lg-placeholder {
    width:100%; height:220px; flex-shrink:0; background:#1c1c1c;
    display:flex; align-items:flex-end; padding:20px;
  }
  .card-lg-placeholder span { color:var(--accent); font-size:18px; font-weight:800; line-height:1.3; }
  .card-lg-body { padding:16px 18px 18px; flex:1; display:flex; flex-direction:column; }
  .card-lg-body h3 { font-size:15px; font-weight:700; margin-bottom:4px; color:#111; line-height:1.35; }
  .card-lg-date { font-size:11px; color:var(--muted); margin-bottom:10px; }
  .card-lg-body p {
    font-size:13px; color:#444; margin:0 0 14px; line-height:1.55; flex:1;
    display:-webkit-box; -webkit-line-clamp:5; -webkit-box-orient:vertical; overflow:hidden;
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
  .card-sm-img { width:100%; height:110px; object-fit:cover; display:block; }
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

  /* ── Kommentar-Badge ── */
  .cmt-badge { font-size:10px; color:var(--muted); white-space:nowrap; }

  @media(max-width:960px) { .card-lg { flex:0 0 calc((100% - 16px) / 2); } }
  @media(max-width:640px) {
    .home-header { padding:24px 20px 20px; }
    .header-body { flex-direction:column; }
    .header-img { width:100%; }
    .content { padding:0 16px 40px; }
    .card-lg { flex:0 0 80%; }
    .card-sm { flex:0 0 58%; }
  }
</style>
</head>
<body>

<div class="home-header">
  <div class="breadcrumb">
    <a href="<%= ctx %>/">← Alle Blogs</a>
    &nbsp;·&nbsp;
    <a href="<%= ctx %>/<%= slug %>/feed" style="opacity:.65">RSS ↗</a>
  </div>
  <h1><%= blog != null ? blog.name : "" %></h1>
  <div class="header-body">
    <div class="header-text">
      <% if (blog != null && blog.description != null && !blog.description.isEmpty()) { %>
      <%= blog.description %>
      <% } %>
      <br>
      <a class="view-toggle" href="<%= ctx %>/<%= slug %>/list">☰ Listenansicht</a>
    </div>
    <% if (blog != null && blog.coverImage != null && !blog.coverImage.isEmpty()) { %>
    <div class="header-img">
      <img src="<%= blog.coverImage %>" alt="<%= blog.name %>">
    </div>
    <% } %>
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
      <div class="card-footer">
        <span class="card-btn">MEHR DAZU »</span>
        <% if (a.commentCount > 0) { %>
        <span class="cmt-badge">💬 <%= a.commentCount %></span>
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
      <% if (a.commentCount > 0) { %>
      <div class="cmt-badge" style="margin-top:4px">💬 <%= a.commentCount %></div>
      <% } %>
    </div>
  </a>
  <% } %>
</div>
<% } %>

</div><!-- /content -->
</body>
</html>
