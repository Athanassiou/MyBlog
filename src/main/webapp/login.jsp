<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" type="image/png" href="/favicon.png">
    <title>MyBlog — Anmelden</title>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            background: #1c1c1c;
            color: #e0e0e0;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
        }
        .login-card {
            background: #252525;
            border: 1px solid #2e2e2e;
            border-radius: 8px;
            padding: 40px 36px;
            width: 100%;
            max-width: 360px;
        }
        .login-logo {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 32px;
            justify-content: center;
        }
        .login-logo-icon {
            width: 38px;
            height: 38px;
            background: #e5a00d;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #111;
            font-weight: 700;
            font-size: 14px;
        }
        .login-logo-text {
            font-size: 20px;
            font-weight: 700;
            color: #e0e0e0;
        }
        .error-msg {
            background: rgba(220,38,38,.15);
            border: 1px solid rgba(220,38,38,.4);
            border-radius: 4px;
            color: #f87171;
            font-size: 13px;
            padding: 10px 12px;
            margin-bottom: 20px;
        }
        label {
            display: block;
            font-size: 12px;
            color: #888;
            margin-bottom: 6px;
            text-transform: uppercase;
            letter-spacing: 0.8px;
        }
        input[type=text], input[type=password] {
            width: 100%;
            padding: 10px 12px;
            background: #1c1c1c;
            border: 1px solid #3a3a3a;
            border-radius: 5px;
            color: #e0e0e0;
            font-size: 14px;
            margin-bottom: 18px;
            outline: none;
            transition: border-color 0.2s;
        }
        input[type=text]:focus, input[type=password]:focus {
            border-color: #e5a00d;
        }
        button[type=submit] {
            width: 100%;
            padding: 11px;
            background: #e5a00d;
            border: none;
            border-radius: 5px;
            color: #111;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            transition: background 0.2s;
        }
        button[type=submit]:hover { background: #f0b020; }
        .back-link {
            display: block;
            text-align: center;
            margin-top: 20px;
            font-size: 12px;
            color: #555;
            text-decoration: none;
        }
        .back-link:hover { color: #888; }
    </style>
</head>
<body>
<div class="login-card">
    <div class="login-logo">
        <div class="login-logo-icon">EA</div>
        <span class="login-logo-text">athanassiou.me</span>
    </div>
    <% if (request.getAttribute("error") != null) { %>
    <div class="error-msg"><%= request.getAttribute("error") %></div>
    <% } %>
    <form method="post" action="<%= request.getContextPath() %>/login">
        <% String next = request.getParameter("next"); %>
        <% if (next != null) { %><input type="hidden" name="next" value="<%= next %>"><% } %>
        <label for="username">Benutzername</label>
        <input type="text"     id="username" name="username" autofocus autocomplete="username">
        <label for="password">Passwort</label>
        <input type="password" id="password" name="password" autocomplete="current-password">
        <button type="submit">Anmelden</button>
    </form>
    <a class="back-link" href="/">← Zurück zur Startseite</a>
</div>
</body>
</html>
