<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="de.myblog.model.User, de.myblog.model.BlogMember, java.util.List, java.util.Set, java.util.stream.Collectors" %>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Admin · Benutzer · MyBlog</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Raleway:wght@400;600;700;800&display=swap" rel="stylesheet">
<style>
<%@ include file="admin-common.css" %>
</style>
</head>
<body>
<%@ include file="admin-nav.html" %>
<div class="content">
  <div class="page-header">
    <h1>Benutzer</h1>
    <a class="btn btn-primary" href="<%= request.getContextPath() %>/admin/users/new">+ Neuer Benutzer</a>
  </div>

  <%
    @SuppressWarnings("unchecked") List<User>       users   = (List<User>)       request.getAttribute("users");
    @SuppressWarnings("unchecked") List<BlogMember> members = (List<BlogMember>) request.getAttribute("members");
    Set<Integer> memberIds = members.stream().map(m -> m.user.id).collect(Collectors.toSet());
    java.util.Map<Integer,String> roleMap = new java.util.HashMap<>();
    for (BlogMember m : members) roleMap.put(m.user.id, m.role);
  %>

  <div class="table-wrap">
    <table>
      <thead><tr><th>Benutzername</th><th>Name</th><th>E-Mail</th><th>Blog-Rolle</th><th>Aktion</th></tr></thead>
      <tbody>
      <% for (User u : users) { String r = roleMap.get(u.id); %>
      <tr>
        <td><strong><%= u.username %></strong></td>
        <td><%= u.displayName != null ? u.displayName : "—" %></td>
        <td style="color:var(--muted);font-size:13px"><%= u.email != null ? u.email : "—" %></td>
        <td>
          <% if (r != null) { %>
          <span class="badge badge-<%= r %>"><%= r %></span>
          <% } else { %>
          <span style="color:var(--muted);font-size:12px">kein Mitglied</span>
          <% } %>
        </td>
        <td>
          <% if (r == null) { %>
          <form method="post" action="<%= request.getContextPath() %>/admin/members/add" style="display:inline-flex;gap:6px">
            <input type="hidden" name="userId" value="<%= u.id %>">
            <select name="role" class="role-select">
              <option value="author">author</option>
              <option value="contributor">contributor</option>
              <option value="admin">admin</option>
            </select>
            <button class="btn btn-ghost btn-sm" type="submit">Hinzufügen</button>
          </form>
          <% } else if (!"owner".equals(r)) { %>
          <a class="btn btn-ghost btn-sm" href="<%= request.getContextPath() %>/admin/members">Bearbeiten</a>
          <% } %>
        </td>
      </tr>
      <% } %>
      </tbody>
    </table>
  </div>
</div>
</body></html>
