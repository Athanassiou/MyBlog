<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="de.myblog.model.User, java.util.List" %>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Admin · Benutzer · MyBlog</title>
<style>
<%@ include file="admin-common.css" %>
  .content { max-width:1060px; }
</style>
</head>
<body>
<%
  String hBlogSlug = "admin"; String hBlogName = "Admin";
  String hBlogLink = request.getContextPath() + "/admin/";
  String hPageTitle = "Benutzer"; String hTopbarTitle = null;
%>
<%@ include file="/WEB-INF/views/fragments/header-dashboard.jsp" %>
<div class="content">
  <div class="page-header">
    <h1>Benutzer</h1>
    <a class="btn btn-primary" href="<%= request.getContextPath() %>/admin/users/new">+ Neuer Benutzer</a>
  </div>

  <%
    @SuppressWarnings("unchecked") List<User> users = (List<User>) request.getAttribute("users");
  %>

  <div class="table-wrap">
    <table>
      <thead><tr><th>Benutzername</th><th>Name</th><th>E-Mail</th><th>Erstellt</th></tr></thead>
      <tbody>
      <% for (User u : users) { %>
      <tr>
        <td><strong><%= u.username %></strong></td>
        <td><%= u.displayName != null ? u.displayName : "—" %></td>
        <td style="color:var(--muted);font-size:13px"><%= u.email != null ? u.email : "—" %></td>
        <td style="color:var(--muted);font-size:12px">
          <%= u.createdAt != null ? u.createdAt.format(java.time.format.DateTimeFormatter.ofPattern("dd.MM.yyyy")) : "—" %>
        </td>
      </tr>
      <% } %>
      </tbody>
    </table>
  </div>
</div>
<%@ include file="/WEB-INF/views/fragments/site-footer.jsp" %>
<%@ include file="/WEB-INF/views/fragments/site-header-clock.jsp" %>
</body></html>
