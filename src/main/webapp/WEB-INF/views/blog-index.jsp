<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="de.myblog.model.Article, de.myblog.model.Blog, java.util.List, java.time.format.DateTimeFormatter, java.util.Locale" %>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<%
  Blog blog = (Blog) request.getAttribute("blog");
  String accent = (blog != null && blog.defaultAccentColor != null) ? blog.defaultAccentColor : "#e5a00d";
%>
<title><%= blog != null ? blog.name : "Blog" %> · MyBlog</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Raleway:wght@400;600;700;800&display=swap" rel="stylesheet">
<style>
  :root { --accent:<%= accent %>; --border:#e8e8e8; --text:#1a1a1a; --muted:#777; }
  * { box-sizing:border-box; margin:0; padding:0; }
  body { font-family:Raleway,sans-serif; background:#fff; color:var(--text); }
  .header { border-bottom:3px solid var(--accent); padding:44px 56px 32px; }
  .header h1 { font-size:34px; font-weight:800; }
  .header p  { color:var(--muted); margin-top:6px; font-size:15px; }
  .breadcrumb { font-size:13px; color:var(--muted); margin-bottom:14px; }
  .breadcrumb a { color:var(--muted); text-decoration:none; font-weight:600; }
  .breadcrumb a:hover { color:var(--accent); }
  .list { max-width:720px; margin:40px auto; padding:0 24px 80px; }
  .item { border-bottom:1px solid var(--border); padding:22px 0; }
  .item:last-child { border-bottom:none; }
  .item a { text-decoration:none; color:inherit; }
  .item a:hover h2 { color:var(--accent); }
  .item h2 { font-size:20px; font-weight:700; margin-bottom:4px; }
  .item .sub { color:var(--muted); font-size:14px; margin-bottom:6px; }
  .item .meta { font-size:12px; color:var(--muted); }
  .dot { display:inline-block; width:10px; height:10px; border-radius:50%;
    background:var(--accent); margin-right:8px; vertical-align:middle; }
  .empty { text-align:center; padding:60px 0; color:var(--muted); }
</style>
</head>
<body>
<div class="header">
  <div class="breadcrumb"><a href="<%= request.getContextPath() %>/">← Alle Blogs</a></div>
  <h1><%= blog != null ? blog.name : "" %></h1>
  <% if (blog != null && blog.description != null && !blog.description.isEmpty()) { %>
  <p><%= blog.description %></p>
  <% } %>
</div>

<div class="list">
  <%
    @SuppressWarnings("unchecked") List<Article> articles = (List<Article>) request.getAttribute("articles");
    DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd. MMMM yyyy", Locale.GERMAN);
  %>
  <% if (articles == null || articles.isEmpty()) { %>
  <div class="empty">Noch keine Artikel veröffentlicht.</div>
  <% } else { %>
    <% for (Article a : articles) { %>
    <div class="item">
      <a href="<%= request.getContextPath() %>/<%= blog.slug %>/<%= a.slug %>">
        <h2><span class="dot" style="background:<%= a.accentColor != null ? a.accentColor : accent %>"></span><%= a.title %></h2>
        <% if (a.subtitle != null && !a.subtitle.isEmpty()) { %><div class="sub"><%= a.subtitle %></div><% } %>
        <div class="meta">
          <%= a.publishedAt != null ? a.publishedAt.format(fmt) : "" %>
          <% if (a.commentCount > 0) { %>
          <span style="margin-left:10px;color:var(--accent);font-weight:600">
            💬 <%= a.commentCount %>
          </span>
          <% } %>
        </div>
      </a>
    </div>
    <% } %>
  <% } %>
</div>
</body></html>
