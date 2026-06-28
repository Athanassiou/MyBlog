<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="de.myblog.model.User, de.myblog.model.Blog, de.myblog.model.BlogMember, java.util.List, java.util.Set, java.util.stream.Collectors" %>
<%
  Blog blog = (Blog) request.getAttribute("blog");
  int  blogId = blog != null ? blog.id : 0;
  @SuppressWarnings("unchecked") List<BlogMember> members  = (List<BlogMember>) request.getAttribute("members");
  @SuppressWarnings("unchecked") List<User>       allUsers = (List<User>)       request.getAttribute("allUsers");
  Set<Integer> memberIds = members.stream().map(m -> m.user.id).collect(Collectors.toSet());
  String[] roles = {"owner","admin","author","contributor"};
%>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Mitglieder · <%= blog != null ? blog.name : "" %> · MyBlog</title>
<style>
<%@ include file="admin-common.css" %>
  .content { max-width:1060px; }
</style>
</head>
<body>
<%
  String hBlogSlug    = blog != null ? blog.slug : null;
  String hBlogName    = blog != null ? blog.name : null;
  String hBlogLink    = null;
  String hPageTitle   = "Mitglieder";
  String hTopbarTitle = null;
%>
<%@ include file="/WEB-INF/views/fragments/header-dashboard.jsp" %>
<div class="content">
  <div class="page-header">
    <h1>Mitglieder · <%= blog != null ? blog.name : "" %></h1>
  </div>

  <div class="table-wrap" style="margin-bottom:28px">
    <table>
      <thead><tr><th>Benutzer</th><th>Rolle</th><th>Aktionen</th></tr></thead>
      <tbody>
      <% for (BlogMember m : members) { %>
      <tr>
        <td>
          <strong><%= m.user.username %></strong>
          <% if (m.user.displayName != null) { %><span style="color:var(--muted);font-size:12px"> · <%= m.user.displayName %></span><% } %>
        </td>
        <td>
          <% if ("owner".equals(m.role)) { %>
          <span class="badge badge-owner">owner</span>
          <% } else { %>
          <form method="post" action="<%= request.getContextPath() %>/admin/members/<%= blogId %>/<%= m.user.id %>/role" style="display:inline-flex;gap:6px;align-items:center">
            <select name="role" class="role-select">
              <% for (String r : roles) { if ("owner".equals(r)) continue; %>
              <option value="<%= r %>" <%= r.equals(m.role) ? "selected" : "" %>><%= r %></option>
              <% } %>
            </select>
            <button class="btn btn-ghost btn-sm" type="submit">Speichern</button>
          </form>
          <% } %>
        </td>
        <td>
          <% if (!"owner".equals(m.role)) { %>
          <form method="post" action="<%= request.getContextPath() %>/admin/members/<%= blogId %>/<%= m.user.id %>/remove"
                onsubmit="return confirm('<%= m.user.username %> entfernen?')">
            <button class="btn btn-danger btn-sm" type="submit">Entfernen</button>
          </form>
          <% } %>
        </td>
      </tr>
      <% } %>
      </tbody>
    </table>
  </div>

  <% List<User> nonMembers = allUsers.stream().filter(u -> !memberIds.contains(u.id)).collect(java.util.stream.Collectors.toList());
     if (!nonMembers.isEmpty()) { %>
  <div class="card" style="max-width:480px">
    <h2 style="font-size:16px;font-weight:700;margin-bottom:16px">Benutzer hinzufügen</h2>
    <form method="post" action="<%= request.getContextPath() %>/admin/members/<%= blogId %>/add" style="display:flex;gap:10px;flex-wrap:wrap">
      <select name="userId" class="role-select" style="flex:2;min-width:160px">
        <% for (User u : nonMembers) { %>
        <option value="<%= u.id %>"><%= u.username %><%= u.displayName != null ? " (" + u.displayName + ")" : "" %></option>
        <% } %>
      </select>
      <select name="role" class="role-select">
        <option value="author">author</option>
        <option value="contributor">contributor</option>
        <option value="admin">admin</option>
      </select>
      <button class="btn btn-primary" type="submit">Hinzufügen</button>
    </form>
  </div>
  <% } %>
</div>
<%@ include file="/WEB-INF/views/fragments/site-footer.jsp" %>
<%@ include file="/WEB-INF/views/fragments/site-header-clock.jsp" %>
</body></html>
