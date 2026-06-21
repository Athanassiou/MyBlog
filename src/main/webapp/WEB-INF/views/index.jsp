<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="de.myblog.model.Blog, java.util.List" %>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>MyBlog — Alle Blogs</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Raleway:wght@400;600;700;800&display=swap" rel="stylesheet">
<style>
  :root { --accent:#e5a00d; --border:#e8e8e8; --text:#1a1a1a; --muted:#777; }
  * { box-sizing:border-box; margin:0; padding:0; }
  body { font-family:Raleway,sans-serif; background:#f5f5f5; color:var(--text); min-height:100vh; }
  .header { background:#fff; border-bottom:2px solid var(--accent); padding:40px 48px 32px;
    display:flex; justify-content:space-between; align-items:flex-end; }
  .header h1 { font-size:32px; font-weight:800; }
  .header p  { color:var(--muted); margin-top:4px; font-size:14px; }
  .header-right { display:flex; gap:10px; }
  .btn { display:inline-flex; align-items:center; border-radius:5px; padding:8px 16px;
    font-family:inherit; font-size:13px; font-weight:600; text-decoration:none;
    border:1px solid transparent; transition:opacity .15s; }
  .btn-primary { background:var(--accent); color:#fff; }
  .btn-primary:hover { opacity:.88; }
  .btn-ghost { background:#fff; color:var(--text); border-color:var(--border); }
  .btn-ghost:hover { border-color:var(--accent); color:var(--accent); }
  .grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(280px,1fr));
    gap:20px; padding:40px 48px 80px; max-width:1200px; margin:0 auto; }
  .blog-card { background:#fff; border:1px solid var(--border); border-radius:10px;
    padding:28px 24px; text-decoration:none; color:inherit; display:block;
    transition:box-shadow .15s,border-color .15s; }
  .blog-card:hover { box-shadow:0 4px 20px rgba(0,0,0,.08); border-color:var(--card-accent,var(--accent)); }
  .card-accent-bar { height:4px; border-radius:2px; margin-bottom:16px;
    background:var(--card-accent,var(--accent)); }
  .card-name { font-size:18px; font-weight:800; margin-bottom:6px; }
  .card-desc { font-size:13px; color:var(--muted); line-height:1.6; }
  .empty { text-align:center; padding:80px 0; color:var(--muted); }
  .topbar { background:#fff; border-bottom:1px solid var(--border); padding:0 48px; height:50px;
    display:flex; align-items:center; justify-content:flex-end; }
  .topbar a { font-size:13px; font-weight:600; color:var(--muted); text-decoration:none; margin-left:16px; }
  .topbar a:hover { color:var(--accent); }
</style>
</head>
<body>
<div class="topbar">
  <% if (session.getAttribute("userId") != null) { %>
  <a href="<%= request.getContextPath() %>/dashboard/">Dashboard</a>
  <% } else { %>
  <a href="<%= request.getContextPath() %>/login">Anmelden</a>
  <% } %>
</div>
<div class="header">
  <div>
    <h1>MyBlog</h1>
    <p>Alle öffentlichen Blogs</p>
  </div>
</div>

<%
  @SuppressWarnings("unchecked") List<Blog> blogs = (List<Blog>) request.getAttribute("blogs");
%>

<% if (blogs == null || blogs.isEmpty()) { %>
<div class="empty"><p>Noch keine öffentlichen Blogs vorhanden.</p></div>
<% } else { %>
<div class="grid">
  <% for (Blog b : blogs) {
     String accent = b.defaultAccentColor != null ? b.defaultAccentColor : "#e5a00d"; %>
  <a class="blog-card" href="<%= request.getContextPath() %>/<%= b.slug %>/"
     style="--card-accent:<%= accent %>">
    <div class="card-accent-bar"></div>
    <div class="card-name"><%= b.name %></div>
    <% if (b.description != null && !b.description.isEmpty()) { %>
    <div class="card-desc"><%= b.description %></div>
    <% } %>
  </a>
  <% } %>
</div>
<% } %>
</body></html>
