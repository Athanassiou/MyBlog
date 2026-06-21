<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="de.myblog.model.Article, java.util.List, java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>MyBlog</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Raleway:wght@400;600;700;800&display=swap" rel="stylesheet">
<style>
  :root { --accent:#e5a00d; --border:#e8e8e8; --text:#1a1a1a; --muted:#777; }
  * { box-sizing:border-box; margin:0; padding:0; }
  body { font-family:Raleway,sans-serif; background:#fff; color:var(--text); }
  .header {
    border-bottom: 2px solid var(--accent);
    padding: 40px 48px 32px;
  }
  .header h1 { font-size:32px; font-weight:800; }
  .header p  { color:var(--muted); margin-top:6px; }
  .list { max-width: 720px; margin: 40px auto; padding: 0 24px 80px; }
  .article-item {
    border-bottom: 1px solid var(--border);
    padding: 22px 0;
  }
  .article-item:last-child { border-bottom: none; }
  .article-item a { text-decoration:none; color:inherit; }
  .article-item a:hover h2 { color:var(--accent); }
  .article-item h2 { font-size:20px; font-weight:700; margin-bottom:4px; }
  .article-item .sub { color:var(--muted); font-size:14px; margin-bottom:6px; }
  .article-item .meta { font-size:12px; color:var(--muted); }
  .accent-dot {
    display:inline-block; width:10px; height:10px;
    border-radius:50%; margin-right:8px; vertical-align:middle;
  }
  .empty { text-align:center; padding:60px 0; color:var(--muted); }
</style>
</head>
<body>

<div class="header">
  <h1>MyBlog</h1>
  <p>Alle Artikel</p>
</div>

<div class="list">
  <%
    @SuppressWarnings("unchecked")
    List<Article> articles = (List<Article>) request.getAttribute("articles");
    DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd. MMMM yyyy", java.util.Locale.GERMAN);
  %>
  <% if (articles == null || articles.isEmpty()) { %>
  <div class="empty">Noch keine Artikel veröffentlicht.</div>
  <% } else { %>
    <% for (Article a : articles) { %>
    <div class="article-item">
      <a href="<%= request.getContextPath() %>/<%= a.slug %>">
        <h2>
          <span class="accent-dot" style="background:<%= a.accentColor != null ? a.accentColor : "#e5a00d" %>"></span>
          <%= a.title %>
        </h2>
        <% if (a.subtitle != null && !a.subtitle.isEmpty()) { %>
        <div class="sub"><%= a.subtitle %></div>
        <% } %>
        <div class="meta"><%= a.publishedAt != null ? a.publishedAt.format(fmt) : "" %></div>
      </a>
    </div>
    <% } %>
  <% } %>
</div>

</body>
</html>
