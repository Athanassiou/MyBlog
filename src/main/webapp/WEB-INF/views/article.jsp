<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="de.myblog.model.Article" %>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<%
  Article article = (Article) request.getAttribute("article");
  String accent = (article != null && article.accentColor != null) ? article.accentColor : "#e5a00d";
%>
<title><%= article != null ? article.title : "Artikel" %> · MyBlog</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Raleway:wght@400;600;700;800&display=swap" rel="stylesheet">
<style>
  :root {
    --accent: <%= accent %>;
    --accent-dim: rgba(229,160,13,.10);
    --sidebar-bg: #f2f2f2; --sidebar-border: #e0e0e0;
    --body-bg: #ffffff; --content-bg: #ffffff;
    --text: #1a1a1a; --muted: #777; --border: #e8e8e8;
  }
  * { box-sizing:border-box; margin:0; padding:0; }
  body { font-family:Raleway,sans-serif; background:var(--body-bg); color:var(--text); font-size:15px; line-height:1.78; }
  .layout { display:flex; min-height:100vh; }
  nav {
    width:210px; flex-shrink:0; background:var(--sidebar-bg);
    border-right:1px solid var(--sidebar-border);
    position:sticky; top:0; height:100vh; overflow-y:auto;
    display:flex; flex-direction:column; transition:width .2s;
  }
  nav.collapsed { width:44px; }
  .nav-top { padding:20px 16px 8px; }
  .nav-blog-title { font-size:13px; font-weight:800; color:var(--text); letter-spacing:-.2px; }
  .nav-section { font-size:10px; font-weight:700; text-transform:uppercase; letter-spacing:.8px;
                 color:var(--muted); padding:16px 16px 6px; }
  nav a.toc-link { display:block; padding:5px 16px; font-size:13px; color:var(--muted);
                   text-decoration:none; transition:color .15s; border-left:2px solid transparent; }
  nav a.toc-link:hover, nav a.toc-link.active { color:var(--accent); border-left-color:var(--accent); }
  .nav-footer { margin-top:auto; padding:12px; display:flex; flex-direction:column; gap:6px; }
  .footer-btn {
    display:flex; align-items:center; gap:8px; background:none;
    border:1px solid var(--sidebar-border); border-radius:5px;
    color:var(--muted); font-size:12px; padding:7px 10px; cursor:pointer;
    width:100%; font-family:inherit; transition:color .15s,border-color .15s,background .15s;
  }
  .footer-btn:hover, .footer-btn.active { color:var(--accent); border-color:var(--accent); background:var(--accent-dim); }
  .btn-icon { font-size:14px; }
  nav.collapsed .btn-label, nav.collapsed .nav-section,
  nav.collapsed .nav-blog-title, nav.collapsed a.toc-link span { display:none; }

  main { flex:1; padding:52px 64px 80px; max-width:820px; }
  .article-topline { display:flex; justify-content:space-between; align-items:center;
                     margin-bottom:28px; font-size:13px; color:var(--muted); }
  .blog-home-link { color:var(--muted); text-decoration:none; font-weight:600; }
  .blog-home-link:hover { color:var(--accent); }
  .title-row { display:flex; align-items:center; gap:12px; margin-bottom:10px; }
  h1 { font-size:32px; font-weight:800; line-height:1.15; flex:1; }
  .title-nav {
    width:34px; height:34px; border-radius:50%; border:1.5px solid var(--border);
    display:inline-flex; align-items:center; justify-content:center;
    font-size:18px; color:var(--muted); text-decoration:none; flex-shrink:0;
  }
  .title-nav:hover { color:var(--accent); border-color:var(--accent); background:var(--accent-dim); }
  p.subtitle { font-size:16px; color:var(--muted); margin-bottom:32px; padding-bottom:20px; border-bottom:2px solid var(--accent); }
  h3 { display:flex; align-items:center; gap:12px; font-size:20px; font-weight:700; margin:40px 0 18px; }
  h3::after { content:''; flex:1; height:2px; background:var(--accent); }
  h4 { font-size:16px; font-weight:700; margin:28px 0 12px; }
  p  { margin-bottom:16px; }
  ul, ol { margin:0 0 16px 24px; }
  li { margin-bottom:4px; }
  blockquote { border-left:3px solid var(--accent); padding:12px 20px; margin:20px 0;
               background:var(--accent-dim); border-radius:0 4px 4px 0; font-style:italic; }
  pre { background:#f0f4fa; border:1px solid var(--border); border-radius:5px;
        padding:16px 20px; overflow-x:auto; margin:20px 0; }
  code { font-family:'JetBrains Mono',Consolas,monospace; font-size:13px; }
  hr { border:none; border-top:2px solid var(--border); margin:32px 0; }
  img { max-width:100%; border-radius:4px; }
  .img-row { display:flex; gap:16px; margin:20px 0 6px; flex-wrap:wrap; }
  .img-row img { flex:1; min-width:0; width:0; }

  .article-nav {
    display:flex; justify-content:space-between; align-items:center;
    margin-top:60px; padding-top:28px; border-top:2px solid var(--accent);
    font-size:14px; font-weight:600;
  }
  .article-nav a { color:var(--text); text-decoration:none; display:flex; align-items:center; gap:8px; }
  .article-nav a:hover { color:var(--accent); }
  .nav-circle {
    width:34px; height:34px; border-radius:50%; border:1.5px solid var(--border);
    display:inline-flex; align-items:center; justify-content:center; font-size:18px; flex-shrink:0;
  }
  @media(max-width:768px) { nav { display:none; } main { padding:28px 20px 60px; } }
</style>
</head>
<body>
<div class="layout">
  <nav id="sidebar">
    <div class="nav-top">
      <div class="nav-blog-title">MyBlog</div>
    </div>
    <div class="nav-section">Inhalt</div>
    <!-- TOC wird via JS befüllt -->
    <div class="nav-footer">
      <button class="footer-btn" id="grey-btn" onclick="toggleGreyMode()">
        <span class="btn-icon">◑</span><span class="btn-label">Grey Mode</span>
      </button>
      <button class="footer-btn" id="sidebar-btn" onclick="toggleSidebar()">
        <span class="btn-icon" id="sidebar-icon">‹</span>
        <span class="btn-label" id="sidebar-label">Einklappen</span>
      </button>
    </div>
  </nav>

  <main>
    <div class="article-topline">
      <div class="article-meta">
        <%
          if (article != null && article.publishedAt != null) {
            java.time.format.DateTimeFormatter fmt =
              java.time.format.DateTimeFormatter.ofPattern("dd. MMMM yyyy", java.util.Locale.GERMAN);
            out.print(article.publishedAt.format(fmt));
          }
        %>
      </div>
      <a class="blog-home-link" href="<%= request.getContextPath() %>/">← Blog</a>
    </div>

    <div class="title-row">
      <h1><%= article != null ? article.title : "" %></h1>
    </div>
    <% if (article != null && article.subtitle != null && !article.subtitle.isEmpty()) { %>
    <p class="subtitle"><%= article.subtitle %></p>
    <% } %>

    <!-- Block-Rendering (Stufe 1: Platzhalter, wird in Stufe 4 durch BlockRenderer ersetzt) -->
    <div id="article-content">
      <%
        if (article != null && article.blocks != null) {
          for (de.myblog.model.Block b : article.blocks) {
            try {
              org.json.JSONObject data = new org.json.JSONObject(b.data);
              switch (b.type) {
                case "paragraph":
                  out.print("<p>" + data.optString("text", "") + "</p>");
                  break;
                case "header":
                  int level = data.optInt("level", 2);
                  String text = data.optString("text", "");
                  if (level == 2) {
                    String hid = "s" + b.position;
                    out.print("<h3 id=\"" + hid + "\">" + text + "</h3>");
                  } else {
                    out.print("<h4>" + text + "</h4>");
                  }
                  break;
                case "list":
                  boolean ordered = "ordered".equals(data.optString("style", "unordered"));
                  org.json.JSONArray items = data.optJSONArray("items");
                  out.print(ordered ? "<ol>" : "<ul>");
                  if (items != null) for (int i = 0; i < items.length(); i++)
                    out.print("<li>" + items.getString(i) + "</li>");
                  out.print(ordered ? "</ol>" : "</ul>");
                  break;
                case "quote":
                  out.print("<blockquote>" + data.optString("text","") + "</blockquote>");
                  break;
                case "code":
                  out.print("<pre><code>" + data.optString("code","") + "</code></pre>");
                  break;
                case "delimiter":
                  out.print("<hr>");
                  break;
                case "image":
                  org.json.JSONObject file = data.optJSONObject("file");
                  String url = file != null ? file.optString("url", "") : "";
                  String caption = data.optString("caption", "");
                  out.print("<div style=\"text-align:center;margin:20px 0\"><img src=\"" + url + "\" alt=\"" + caption + "\"></div>");
                  break;
              }
            } catch (Exception ignored) {}
          }
        }
      %>
    </div>

    <div class="article-nav">
      <span></span>
      <a class="home" href="<%= request.getContextPath() %>/">⌂ Blog</a>
      <span></span>
    </div>
  </main>
</div>

<script>
function toggleGreyMode() {
  document.body.classList.toggle('grey-mode');
  document.getElementById('grey-btn').classList.toggle('active');
}
function toggleSidebar() {
  const nav = document.getElementById('sidebar');
  nav.classList.toggle('collapsed');
  const c = nav.classList.contains('collapsed');
  document.getElementById('sidebar-icon').textContent  = c ? '›' : '‹';
  document.getElementById('sidebar-label').textContent = c ? 'Ausklappen' : 'Einklappen';
}

// TOC aus h3-Elementen aufbauen
(function() {
  const nav     = document.getElementById('sidebar');
  const section = nav.querySelector('.nav-section');
  const heads   = document.querySelectorAll('h3[id]');
  heads.forEach(h => {
    const a = document.createElement('a');
    a.className = 'toc-link';
    a.href = '#' + h.id;
    a.textContent = h.textContent;
    section.after(a);
  });

  // Scroll-Spy
  const links = document.querySelectorAll('nav a.toc-link');
  if (heads.length && links.length) {
    const obs = new IntersectionObserver(entries => {
      entries.forEach(e => {
        if (e.isIntersecting) {
          links.forEach(l => l.classList.remove('active'));
          const a = document.querySelector('nav a[href="#' + e.target.id + '"]');
          if (a) a.classList.add('active');
        }
      });
    }, { rootMargin: '-10% 0px -75% 0px' });
    heads.forEach(s => obs.observe(s));
  }
})();
</script>
</body>
</html>
