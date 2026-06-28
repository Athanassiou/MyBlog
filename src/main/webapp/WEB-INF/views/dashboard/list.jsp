<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="de.myblog.model.Article, de.myblog.model.Blog, java.util.List, java.time.format.DateTimeFormatter" %>
<%
  Blog    blog       = (Blog)    request.getAttribute("blog");
  boolean canPublish = Boolean.TRUE.equals(request.getAttribute("canPublish"));
  boolean canManage  = Boolean.TRUE.equals(request.getAttribute("canManage"));
  String  userRole   = (String)  request.getAttribute("role");
  String  blogSlug   = blog != null ? blog.slug : "main";
  String  blogName   = blog != null ? blog.name : "Blog";
%>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= blogName %> · Dashboard · MyBlog</title>
<style>
  <%@ include file="/WEB-INF/views/fragments/dashboard-common.css" %>
  .content { max-width:1060px; }
  .article-title { font-weight:700; color:var(--text); }
  .article-sub   { font-size:12px; color:var(--muted); margin-top:2px; }
  .actions { display:flex; gap:6px; flex-wrap:wrap; }
</style>
</head>
<body>

<%
  String hBlogSlug = blogSlug; String hBlogName = blogName;
  String hBlogLink = null;
  String hPageTitle = null; String hTopbarTitle = null;
%>
<%@ include file="/WEB-INF/views/fragments/header-dashboard.jsp" %>

<div class="content">
  <div class="page-header">
    <h1>Artikel</h1>
    <div style="display:flex;gap:8px">
      <a class="btn btn-ghost" href="<%= request.getContextPath() %>/dashboard/">← Meine Blogs</a>
      <% if (canManage) { %>
      <a class="btn btn-ghost" href="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/settings">⚙ Einstellungen</a>
      <% } %>
      <% if ("owner".equals(userRole) || "admin".equals(userRole)) { %>
      <a class="btn btn-ghost" href="<%= request.getContextPath() %>/admin/members/<%= blog != null ? blog.id : 1 %>">Mitglieder</a>
      <% } %>
      <a class="btn btn-primary" href="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/new">+ Neuer Artikel</a>
    </div>
  </div>

  <%
    @SuppressWarnings("unchecked")
    List<Article> articles = (List<Article>) request.getAttribute("articles");
    DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd.MM.yyyy");
  %>

  <% if (articles == null || articles.isEmpty()) { %>
  <div class="table-wrap">
    <div class="empty">
      <p>Noch keine Artikel vorhanden.</p>
      <a class="btn btn-primary" href="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/new">Ersten Artikel erstellen</a>
    </div>
  </div>
  <% } else { %>
  <div class="table-wrap">
    <table>
      <thead>
        <tr>
          <th>Titel</th>
          <th>Status</th>
          <th>Erstellt</th>
          <th>Aktionen</th>
        </tr>
      </thead>
      <tbody>
        <% for (Article a : articles) { %>
        <tr>
          <td>
            <div class="article-title"><%= a.title != null ? a.title : "(kein Titel)" %></div>
            <% if (a.subtitle != null && !a.subtitle.isEmpty()) { %>
            <div class="article-sub"><%= a.subtitle %></div>
            <% } %>
          </td>
          <td>
            <% if ("published".equals(a.status)) { %>
            <span class="badge badge-published">Veröffentlicht</span>
            <% } else { %>
            <span class="badge badge-draft">Entwurf</span>
            <% } %>
          </td>
          <td style="color:var(--muted); font-size:13px;">
            <%= a.createdAt != null ? a.createdAt.format(fmt) : "—" %>
          </td>
          <td>
            <div class="actions">
              <a class="btn btn-ghost btn-sm" href="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/<%= a.id %>">Bearbeiten</a>

              <% if (canPublish) { %>
                <% if ("published".equals(a.status)) { %>
                <form method="post" action="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/<%= a.id %>/unpublish" style="display:inline">
                  <button class="btn btn-ghost btn-sm" type="submit">Zurückziehen</button>
                </form>
                <% } else { %>
                <form method="post" action="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/<%= a.id %>/publish" style="display:inline">
                  <button class="btn btn-ghost btn-sm" type="submit">Veröffentlichen</button>
                </form>
                <% } %>
              <% } %>

              <% if (canManage) { %>
              <form method="post" action="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/<%= a.id %>/delete" style="display:inline"
                    onsubmit="return confirm('Artikel «<%= a.title != null ? a.title.replace("'","\\'" ) : "" %>» wirklich löschen?')">
                <button class="btn btn-danger btn-sm" type="submit">Löschen</button>
              </form>
              <% } %>
            </div>
          </td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
  <% } %>
</div>

<%@ include file="/WEB-INF/views/fragments/site-footer.jsp" %>
<%@ include file="/WEB-INF/views/fragments/site-header-clock.jsp" %>
</body>
</html>
