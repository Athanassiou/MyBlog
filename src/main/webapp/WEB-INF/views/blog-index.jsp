<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="de.myblog.model.Article, de.myblog.model.Blog, de.myblog.model.Tag, java.util.List, java.time.format.DateTimeFormatter, java.util.Locale" %>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<%
  Blog   blog       = (Blog)   request.getAttribute("blog");
  String accent     = (blog != null && blog.defaultAccentColor != null) ? blog.defaultAccentColor : "#e5a00d";
  String blogSlug   = blog != null ? blog.slug : "";
  String searchQ    = (String) request.getAttribute("searchQuery");
  String filterTag  = (String) request.getAttribute("filterTag");
  boolean isSearch  = searchQ  != null && !searchQ.isBlank();
  boolean isTag     = filterTag != null && !filterTag.isBlank();
%>
<title><%= blog != null ? blog.name : "Blog" %> · MyBlog</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/fa/css/all.css">
<link rel="alternate" type="application/rss+xml" title="<%= blog != null ? blog.name : "RSS" %>"
      href="<%= request.getContextPath() %>/<%= blogSlug %>/feed">
<style>
  :root { --accent:<%= accent %>; --border:#e8e8e8; --text:#1a1a1a; --muted:#777; }
  * { box-sizing:border-box; margin:0; padding:0; }
  body { font-family:'Segoe UI','Helvetica Neue',Arial,sans-serif; background:#f5f5f5; color:var(--text); }
  .header { border-bottom:3px solid var(--accent); padding:44px 0 28px; }
  .header h1 { font-size:34px; font-weight:800; }
  .header p  { color:var(--muted); margin-top:6px; font-size:15px; line-height:1.6; }
  .header-row { max-width:1060px; margin:0 auto; padding:0 32px; display:flex; align-items:flex-end; justify-content:space-between; gap:20px; flex-wrap:wrap; }
  <%@ include file="/WEB-INF/views/fragments/site-header-styles.jsp" %>
  /* ── View-Toggle (Schaufenster ↔ Liste) ── */
  .view-toggle { font-size:13px; color:var(--muted); text-decoration:none; font-weight:600; display:inline-block; margin-top:8px; }
  .view-toggle:hover { color:var(--accent); }
  /* Suchfeld */
  .search-form { display:flex; gap:6px; margin-top:16px; }
  .search-input { border:1.5px solid var(--border); border-radius:5px; padding:8px 12px;
    font-family:inherit; font-size:14px; outline:none; transition:border-color .15s; width:260px; }
  .search-input:focus { border-color:var(--accent); }
  .search-btn { background:var(--accent); color:#fff; border:none; border-radius:5px;
    padding:8px 14px; font-family:inherit; font-size:13px; font-weight:600; cursor:pointer; }
  /* Filter-Banner */
  .filter-banner { display:flex; align-items:center; gap:10px; background:#f5f5f5;
    border-left:3px solid var(--accent); padding:10px 16px; font-size:14px; margin-bottom:8px; }
  .filter-banner a { color:var(--muted); font-size:12px; text-decoration:none; }
  .filter-banner a:hover { color:var(--accent); }
  /* Liste */
  .list { max-width:1060px; margin:36px auto; padding:0 32px 80px; }
  .item { border-bottom:1px solid var(--border); padding:22px 0; }
  .item:last-child { border-bottom:none; }
  .item a.item-link { text-decoration:none; color:inherit; display:block; }
  .item a.item-link:hover h2 { color:var(--accent); }
  .item h2 { font-size:20px; font-weight:700; margin-bottom:4px; }
  .item .sub { color:var(--muted); font-size:14px; margin-bottom:8px; }
  .item .meta { font-size:12px; color:var(--muted); display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
  .dot { display:inline-block; width:10px; height:10px; border-radius:50%;
    background:var(--accent); margin-right:8px; vertical-align:middle; }
  /* Tag-Pillen */
  .tag-pill { display:inline-block; background:#f0f0f0; color:#555; border-radius:20px;
    padding:2px 9px; font-size:11px; font-weight:600; text-decoration:none; transition:background .15s; }
  .tag-pill:hover { background:var(--accent); color:#fff; }
  .cmt-badge { font-size:13px; color:var(--accent); font-weight:600; white-space:nowrap; }
  .empty { text-align:center; padding:60px 0; color:var(--muted); }
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/fragments/header-public.jsp" %>
<div class="header">
  <div class="header-row">
    <div>
      <h1><%= blog != null ? blog.name : "" %></h1>
      <% if (blog != null && blog.description != null && !blog.description.isEmpty()) { %>
      <p><%= blog.description %></p>
      <% } %>
      <% if (blog != null) { %>
      <a href="<%= request.getContextPath() %>/<%= blogSlug %>/" class="view-toggle">⊞ Schaufenster</a>
      <% } %>
    </div>
    <form class="search-form" method="get" action="<%= request.getContextPath() %>/<%= blogSlug %>/">
      <input class="search-input" type="search" name="q" placeholder="Suche …"
             value="<%= searchQ != null ? searchQ : "" %>">
      <button class="search-btn" type="submit">↵</button>
    </form>
  </div>
</div>

<div class="list">
  <%
    @SuppressWarnings("unchecked") List<Article> articles = (List<Article>) request.getAttribute("articles");
    DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd. MMMM yyyy", Locale.GERMAN);
  %>

  <% if (isSearch) { %>
  <div class="filter-banner">
    Suchergebnisse für „<strong><%= searchQ %></strong>" · <%= articles != null ? articles.size() : 0 %> Treffer
    <a href="<%= request.getContextPath() %>/<%= blogSlug %>/">✕ zurücksetzen</a>
  </div>
  <% } else if (isTag) { %>
  <div class="filter-banner">
    Tag: <strong><%= filterTag %></strong>
    <a href="<%= request.getContextPath() %>/<%= blogSlug %>/">✕ zurücksetzen</a>
  </div>
  <% } %>

  <% if (articles == null || articles.isEmpty()) { %>
  <div class="empty">
    <% if (isSearch || isTag) { %>Keine Artikel gefunden.<% } else { %>Noch keine Artikel veröffentlicht.<% } %>
  </div>
  <% } else {
    for (Article a : articles) {
      String ac = a.accentColor != null ? a.accentColor : accent;
  %>
  <div class="item">
    <a class="item-link" href="<%= request.getContextPath() %>/<%= blogSlug %>/<%= a.slug %>">
      <h2><span class="dot" style="background:<%= ac %>"></span><%= a.title %></h2>
      <% if (a.subtitle != null && !a.subtitle.isEmpty()) { %><div class="sub"><%= a.subtitle %></div><% } %>
    </a>
    <div class="meta">
      <span><%= a.publishedAt != null ? a.publishedAt.format(fmt) : "" %></span>
      <% if (a.commentCount > 0) { %><span class="cmt-badge"><i class="fa-regular fa-comment"></i> <%= a.commentCount %></span><% } %>
      <% if (a.tags != null) { for (Tag t : a.tags) { %>
      <a class="tag-pill" href="<%= request.getContextPath() %>/<%= blogSlug %>/tag/<%= t.name %>">#<%= t.name %></a>
      <% } } %>
    </div>
  </div>
  <% } } %>
</div>

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
<%@ include file="/WEB-INF/views/fragments/site-header-clock.jsp" %>
</script>
</body></html>
