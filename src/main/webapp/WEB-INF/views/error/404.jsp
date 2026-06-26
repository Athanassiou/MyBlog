<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<title>Seite nicht gefunden</title>
<style>
  body { font-family: 'Segoe UI','Helvetica Neue',Arial,sans-serif; display: flex; align-items: center; justify-content: center;
         min-height: 100vh; margin: 0; background: #f2f2f2; color: #1a1a1a; }
  .box { text-align: center; }
  h1 { font-size: 72px; font-weight: 800; margin: 0; color: #e5a00d; }
  p  { color: #777; margin: 8px 0 24px; }
  a  { color: #e5a00d; font-weight: 600; text-decoration: none; }
</style>
</head>
<body>
<div class="box">
  <h1>404</h1>
  <p>Diese Seite existiert nicht.</p>
  <a href="<%= request.getContextPath() %>/">← Zurück zur Startseite</a>
</div>
</body>
</html>
