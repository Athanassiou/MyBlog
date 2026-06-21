<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="de.myblog.model.Blog, java.util.List" %>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Admin · Blogs · MyBlog</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Raleway:wght@400;600;700;800&display=swap" rel="stylesheet">
<style>
<%@ include file="admin-common.css" %>
.accent-dot { display:inline-block; width:12px; height:12px; border-radius:50%; vertical-align:middle; margin-right:6px; }
</style>
</head>
<body>
<%@ include file="admin-nav.html" %>
<div class="content">
  <div class="page-header">
    <h1>Blogs</h1>
    <a class="btn btn-primary" href="<%= request.getContextPath() %>/admin/blogs/new">+ Neuer Blog</a>
  </div>

  <%
    @SuppressWarnings("unchecked") List<Blog> blogs = (List<Blog>) request.getAttribute("blogs");
  %>

  <div class="table-wrap">
    <table>
      <thead><tr><th>Name</th><th>Slug</th><th>Sichtbarkeit</th><th>Aktionen</th></tr></thead>
      <tbody>
      <% if (blogs == null || blogs.isEmpty()) { %>
      <tr><td colspan="4" style="text-align:center;color:var(--muted);padding:40px">Noch keine Blogs vorhanden.</td></tr>
      <% } else { for (Blog b : blogs) {
           String acc = b.defaultAccentColor != null ? b.defaultAccentColor : "#e5a00d"; %>
      <tr>
        <td>
          <span class="accent-dot" style="background:<%= acc %>"></span>
          <strong><%= b.name %></strong>
          <% if (b.description != null && !b.description.isEmpty()) { %>
          <div style="font-size:12px;color:var(--muted);margin-top:2px"><%= b.description %></div>
          <% } %>
        </td>
        <td style="font-family:monospace;font-size:13px;color:var(--muted)"><%= b.slug %></td>
        <td>
          <span class="badge <%= "public".equals(b.visibility) ? "badge-author" : "badge-contributor" %>">
            <%= b.visibility %>
          </span>
        </td>
        <td>
          <div style="display:flex;gap:6px">
            <a class="btn btn-ghost btn-sm" href="<%= request.getContextPath() %>/admin/blogs/<%= b.id %>/edit">Bearbeiten</a>
            <a class="btn btn-ghost btn-sm" href="<%= request.getContextPath() %>/admin/members/<%= b.id %>">Mitglieder</a>
            <a class="btn btn-ghost btn-sm" href="<%= request.getContextPath() %>/<%= b.slug %>/" target="_blank">Ansehen</a>
          </div>
        </td>
      </tr>
      <% } } %>
      </tbody>
    </table>
  </div>
</div>
</body></html>
