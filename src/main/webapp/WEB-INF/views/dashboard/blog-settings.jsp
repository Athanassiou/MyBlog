<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="de.myblog.model.Blog" %>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<%
  Blog   blog     = (Blog)   request.getAttribute("blog");
  String blogSlug = blog != null ? blog.slug : "main";
  String blogName = blog != null ? blog.name : "Blog";
  String error    = (String) request.getAttribute("error");
  String accent   = blog != null && blog.defaultAccentColor != null ? blog.defaultAccentColor : "#e5a00d";
%>
<title><%= blogName %> · Einstellungen · MyBlog</title>
<style>
  <%@ include file="/WEB-INF/views/fragments/dashboard-common.css" %>
  :root { --accent:<%= accent %>; }
  .content { max-width:1060px; }
  .color-row { display:flex; align-items:center; gap:10px; }
  input[type=color] { width:36px; height:36px; border:1px solid var(--border); border-radius:5px;
    padding:2px; cursor:pointer; background:none; }
  .color-hex { font-family:monospace; width:110px; }
</style>
</head>
<body>

<%
  String hBlogSlug = blogSlug; String hBlogName = blogName;
  String hBlogLink = null;
  String hPageTitle = "Einstellungen"; String hTopbarTitle = null;
%>
<%@ include file="/WEB-INF/views/fragments/header-dashboard.jsp" %>

<div class="content">
  <div class="page-header">
    <h1>Einstellungen</h1>
    <div style="display:flex;gap:8px">
      <a class="btn btn-ghost" href="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/">← Artikelliste</a>
    </div>
  </div>

  <% if (error != null) { %>
  <div class="error-box"><%= error %></div>
  <% } %>

  <%
    String _scheme = request.getScheme();
    String _host   = request.getServerName();
    int    _port   = request.getServerPort();
    String _portStr = (_scheme.equals("https") && _port == 443) || (_scheme.equals("http") && _port == 80) ? "" : ":" + _port;
    String _externalUrl = _scheme + "://" + _host + _portStr + request.getContextPath() + "/" + blogSlug + "/";
  %>
  <div class="card" style="margin-bottom:20px;padding:14px 20px;display:flex;align-items:center;justify-content:space-between;gap:16px">
    <div>
      <div style="font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);margin-bottom:4px">Öffentliche Blog-URL</div>
      <a href="<%= _externalUrl %>" target="_blank"
         style="font-size:14px;font-weight:600;color:var(--accent);text-decoration:none;font-family:monospace"><%= _externalUrl %></a>
    </div>
    <a href="<%= _externalUrl %>" target="_blank" class="btn btn-ghost" style="flex-shrink:0">↗ Öffnen</a>
  </div>

  <div class="card">
    <form method="post" action="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/settings">

      <div class="field">
        <label>Slug (URL)</label>
        <input type="text" value="<%= blogSlug %>" disabled style="background:var(--input-bg);color:var(--muted)">
      </div>

      <div class="field">
        <label for="name">Name *</label>
        <input type="text" id="name" name="name" required value="<%= blogName %>">
      </div>

      <div class="field">
        <label for="description">Beschreibung (HTML erlaubt)</label>
        <textarea id="description" name="description" rows="5"
                  style="resize:vertical"><%= blog != null && blog.description != null ? blog.description : "" %></textarea>
      </div>

      <div class="field">
        <label>Akzentfarbe</label>
        <div class="color-row">
          <input type="color" id="color-picker" value="<%= accent %>" oninput="syncColor(this.value)">
          <input type="text" class="field color-hex" id="color-hex" name="accentColor" maxlength="7"
                 value="<%= accent %>" oninput="syncColorFromHex(this.value)"
                 style="border:1px solid var(--border);border-radius:5px;padding:9px 12px">
        </div>
      </div>

      <div class="field">
        <label for="visibility">Sichtbarkeit</label>
        <select id="visibility" name="visibility">
          <option value="public"  <%= blog == null || "public".equals(blog.visibility)  ? "selected" : "" %>>Öffentlich</option>
          <option value="private" <%= blog != null && "private".equals(blog.visibility) ? "selected" : "" %>>Privat</option>
          <option value="invite"  <%= blog != null && "invite".equals(blog.visibility)  ? "selected" : "" %>>Nur Eingeladene</option>
        </select>
      </div>

      <div class="field">
        <label style="display:flex;align-items:center;gap:8px;font-weight:600;font-size:13px;cursor:pointer">
          <input type="checkbox" name="showPlatformHeader"
                 <%= blog == null || blog.showPlatformHeader ? "checked" : "" %>>
          Plattform-Header anzeigen (athanassiou.me Logo, Uhr, Login)
        </label>
        <p style="font-size:12px;color:var(--muted);margin-top:4px;margin-left:22px">
          Deaktivieren für Blogs die extern eingebettet oder unabhängig referenziert werden.
        </p>
      </div>

      <div style="display:flex;gap:10px;margin-top:8px">
        <button type="submit" class="btn btn-primary">Speichern</button>
      </div>
    </form>
  </div>

  <!-- ── Gefahrenzone ── -->
  <div class="card" style="margin-top:28px;border-color:#fca5a5;">
    <h3 style="font-size:14px;font-weight:700;color:#dc2626;margin-bottom:12px;">Gefahrenzone</h3>
    <p style="font-size:13px;color:var(--muted);margin-bottom:16px;">
      Den Blog <strong><%= blogName %></strong> und alle dazugehörigen Artikel unwiderruflich löschen.
    </p>
    <form method="post" action="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/delete-blog"
          onsubmit="return confirm('Blog «<%= blogName %>» und alle Artikel wirklich löschen? Das kann nicht rückgängig gemacht werden.')">
      <button type="submit" class="btn"
              style="background:#dc2626;color:#fff;border-color:#dc2626;">Blog löschen</button>
    </form>
  </div>
</div>

<script>
function syncColor(hex) { document.getElementById('color-hex').value = hex; }
function syncColorFromHex(val) {
  if (/^#[0-9a-fA-F]{6}$/.test(val)) document.getElementById('color-picker').value = val;
}
</script>
<%@ include file="/WEB-INF/views/fragments/site-footer.jsp" %>
<%@ include file="/WEB-INF/views/fragments/site-header-clock.jsp" %>
</body></html>
