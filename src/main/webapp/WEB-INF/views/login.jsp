<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Anmelden · MyBlog</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Raleway:wght@400;600;700;800&display=swap" rel="stylesheet">
<style>
  :root {
    --accent:     #e5a00d;
    --accent-dim: rgba(229,160,13,.10);
    --border:     #e8e8e8;
    --text:       #1a1a1a;
    --muted:      #777;
  }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    font-family: Raleway, sans-serif;
    background: #f2f2f2;
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--text);
  }
  .card {
    background: #fff;
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 40px 44px 44px;
    width: 100%;
    max-width: 420px;
    box-shadow: 0 2px 12px rgba(0,0,0,.06);
  }
  .logo {
    font-size: 22px;
    font-weight: 800;
    color: var(--accent);
    letter-spacing: -.5px;
    margin-bottom: 28px;
    text-align: center;
  }
  h1 {
    font-size: 20px;
    font-weight: 700;
    margin-bottom: 24px;
    text-align: center;
  }
  label {
    display: block;
    font-size: 13px;
    font-weight: 600;
    color: var(--muted);
    margin-bottom: 5px;
    text-transform: uppercase;
    letter-spacing: .5px;
  }
  input[type=text], input[type=password] {
    width: 100%;
    border: 1px solid var(--border);
    border-radius: 5px;
    padding: 10px 13px;
    font-family: inherit;
    font-size: 15px;
    color: var(--text);
    outline: none;
    transition: border-color .15s;
    margin-bottom: 16px;
  }
  input:focus { border-color: var(--accent); }
  .error {
    background: #fff3f3;
    border: 1px solid #f9c6c6;
    border-left: 3px solid #dc2626;
    border-radius: 4px;
    padding: 10px 14px;
    font-size: 14px;
    color: #b91c1c;
    margin-bottom: 18px;
  }
  button[type=submit] {
    width: 100%;
    background: var(--accent);
    color: #fff;
    border: none;
    border-radius: 5px;
    padding: 11px;
    font-family: inherit;
    font-size: 15px;
    font-weight: 700;
    cursor: pointer;
    margin-top: 6px;
    transition: opacity .15s;
  }
  button[type=submit]:hover { opacity: .88; }
</style>
</head>
<body>
<div class="card">
  <div class="logo">MyBlog</div>
  <h1>Anmelden</h1>

  <%
    String error = (String) request.getAttribute("error");
    String next  = request.getParameter("next");
    if (next == null) next = "";
  %>

  <% if (error != null) { %>
  <div class="error"><%= error %></div>
  <% } %>

  <form method="post" action="<%= request.getContextPath() %>/login">
    <% if (!next.isEmpty()) { %>
    <input type="hidden" name="next" value="<%= next %>">
    <% } %>

    <label for="username">Benutzername</label>
    <input type="text" id="username" name="username" autocomplete="username"
           autofocus required
           value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>">

    <label for="password">Passwort</label>
    <input type="password" id="password" name="password" autocomplete="current-password" required>

    <button type="submit">Anmelden</button>
  </form>
</div>
</body>
</html>
