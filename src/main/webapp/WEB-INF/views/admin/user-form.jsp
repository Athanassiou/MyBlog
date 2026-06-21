<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Admin · Neuer Benutzer · MyBlog</title>
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
    <h1>Neuer Benutzer</h1>
    <a class="btn btn-ghost" href="<%= request.getContextPath() %>/admin/">← Zurück</a>
  </div>

  <% String error = (String) request.getAttribute("error"); %>
  <% if (error != null) { %><div class="error-box"><%= error %></div><% } %>

  <div class="card" style="max-width:520px">
    <form method="post" action="<%= request.getContextPath() %>/admin/users/new">
      <div class="field">
        <label>Benutzername *</label>
        <input type="text" name="username" required autofocus value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>">
      </div>
      <div class="field">
        <label>Anzeigename</label>
        <input type="text" name="displayName" value="<%= request.getParameter("displayName") != null ? request.getParameter("displayName") : "" %>">
      </div>
      <div class="field">
        <label>E-Mail</label>
        <input type="email" name="email" value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>">
      </div>
      <div class="field">
        <label>Passwort *</label>
        <input type="password" name="password" required>
      </div>
      <div class="field" style="margin-bottom:24px">
        <label>Blog-Rolle (optional)</label>
        <select name="role" class="role-select" style="width:100%">
          <option value="">— kein Blog-Mitglied —</option>
          <option value="admin">admin</option>
          <option value="author">author</option>
          <option value="contributor">contributor</option>
        </select>
      </div>
      <button class="btn btn-primary" type="submit" style="width:100%">Benutzer anlegen</button>
    </form>
  </div>
</div>
</body></html>
