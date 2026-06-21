<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="de.myblog.model.Article, java.util.List, java.time.format.DateTimeFormatter" %>
<%
  boolean canPublish = Boolean.TRUE.equals(request.getAttribute("canPublish"));
  boolean canManage  = Boolean.TRUE.equals(request.getAttribute("canManage"));
  String  userRole   = (String) session.getAttribute("userRole");
%>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Dashboard · MyBlog</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Raleway:wght@400;600;700;800&display=swap" rel="stylesheet">
<style>
  :root {
    --accent:     #e5a00d;
    --accent-dim: rgba(229,160,13,.10);
    --border:     #e8e8e8;
    --text:       #1a1a1a;
    --muted:      #777;
    --bg:         #f5f5f5;
  }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: Raleway, sans-serif; background: var(--bg); color: var(--text); min-height: 100vh; }

  /* ── Topbar ── */
  .topbar {
    background: #fff;
    border-bottom: 1px solid var(--border);
    padding: 0 32px;
    height: 52px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    position: sticky;
    top: 0;
    z-index: 10;
  }
  .topbar-brand { font-size: 17px; font-weight: 800; color: var(--accent); letter-spacing: -.3px; }
  .topbar-user  { font-size: 13px; color: var(--muted); }
  .topbar-user a { color: var(--muted); text-decoration: none; margin-left: 14px; }
  .topbar-user a:hover { color: var(--accent); }

  /* ── Content ── */
  .content { max-width: 900px; margin: 0 auto; padding: 40px 24px 80px; }

  .page-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 28px;
  }
  .page-header h1 { font-size: 22px; font-weight: 800; }

  /* ── Buttons ── */
  .btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    border-radius: 5px;
    padding: 8px 16px;
    font-family: inherit;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    text-decoration: none;
    border: 1px solid transparent;
    transition: opacity .15s, background .15s;
  }
  .btn-primary   { background: var(--accent); color: #fff; }
  .btn-primary:hover { opacity: .88; }
  .btn-ghost     { background: #fff; color: var(--text); border-color: var(--border); }
  .btn-ghost:hover { border-color: var(--accent); color: var(--accent); background: var(--accent-dim); }
  .btn-danger    { background: #fff; color: #dc2626; border-color: #f9c6c6; }
  .btn-danger:hover { background: #fff3f3; }
  .btn-sm { padding: 5px 11px; font-size: 12px; }

  /* ── Tabelle ── */
  .table-wrap {
    background: #fff;
    border: 1px solid var(--border);
    border-radius: 8px;
    overflow: hidden;
  }
  table { width: 100%; border-collapse: collapse; }
  th {
    text-align: left;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .6px;
    color: var(--muted);
    padding: 12px 16px;
    border-bottom: 1px solid var(--border);
    background: #fafafa;
  }
  td { padding: 13px 16px; border-bottom: 1px solid var(--border); font-size: 14px; vertical-align: middle; }
  tr:last-child td { border-bottom: none; }
  tr:hover td { background: #fafef5; }

  .article-title { font-weight: 700; color: var(--text); }
  .article-sub   { font-size: 12px; color: var(--muted); margin-top: 2px; }

  .badge {
    display: inline-block;
    border-radius: 20px;
    padding: 2px 10px;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .4px;
  }
  .badge-published { background: #dcfce7; color: #15803d; }
  .badge-draft     { background: #f3f4f6; color: #6b7280; }

  .actions { display: flex; gap: 6px; flex-wrap: wrap; }

  /* ── Leer-Zustand ── */
  .empty {
    text-align: center;
    padding: 60px 24px;
    color: var(--muted);
  }
  .empty p { margin-bottom: 16px; }
</style>
</head>
<body>

<div class="topbar">
  <span class="topbar-brand">MyBlog</span>
  <span class="topbar-user">
    <%= session.getAttribute("displayName") %>
    <% if ("owner".equals(userRole) || "admin".equals(userRole)) { %>
    <a href="<%= request.getContextPath() %>/admin/">Admin</a>
    <% } %>
    <a href="<%= request.getContextPath() %>/login">Abmelden</a>
  </span>
</div>

<div class="content">
  <div class="page-header">
    <h1>Artikel</h1>
    <a class="btn btn-primary" href="<%= request.getContextPath() %>/dashboard/new">+ Neuer Artikel</a>
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
      <a class="btn btn-primary" href="<%= request.getContextPath() %>/dashboard/new">Ersten Artikel erstellen</a>
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
              <a class="btn btn-ghost btn-sm" href="<%= request.getContextPath() %>/dashboard/<%= a.id %>">Bearbeiten</a>

              <% if (canPublish) { %>
                <% if ("published".equals(a.status)) { %>
                <form method="post" action="<%= request.getContextPath() %>/dashboard/<%= a.id %>/unpublish" style="display:inline">
                  <button class="btn btn-ghost btn-sm" type="submit">Zurückziehen</button>
                </form>
                <% } else { %>
                <form method="post" action="<%= request.getContextPath() %>/dashboard/<%= a.id %>/publish" style="display:inline">
                  <button class="btn btn-ghost btn-sm" type="submit">Veröffentlichen</button>
                </form>
                <% } %>
              <% } %>

              <% if (canManage) { %>
              <form method="post" action="<%= request.getContextPath() %>/dashboard/<%= a.id %>/delete" style="display:inline"
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

</body>
</html>
