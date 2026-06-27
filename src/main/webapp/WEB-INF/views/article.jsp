<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="de.myblog.model.Article, de.myblog.model.Comment" %>
<%@ page import="java.util.*, java.time.*, java.time.temporal.ChronoUnit" %>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<%
  Article article  = (Article) request.getAttribute("article");
  de.myblog.model.Blog artBlog = (de.myblog.model.Blog) request.getAttribute("blog");
  String  blogSlug = artBlog != null ? artBlog.slug : "";
  String accent = (article != null && article.accentColor != null) ? article.accentColor : "#e5a00d";
  Article prevA = (Article) request.getAttribute("prevArticle");
  Article nextA = (Article) request.getAttribute("nextArticle");
  boolean previewMode = Boolean.TRUE.equals(request.getAttribute("previewMode"));
%>
<title><%= article != null ? article.title : "Artikel" %> · MyBlog</title>
<style>
  :root {
    --accent: <%= accent %>;
    --accent-dim: rgba(229,160,13,.12);
    --sidebar-bg: #252525; --sidebar-border: #3e3e3e;
    --body-bg: #1c1c1c; --content-bg: #1c1c1c;
    --text: #e0e0e0; --muted: #888; --border: #3e3e3e;
  }
  * { box-sizing:border-box; margin:0; padding:0; }
  body { font-family:'Segoe UI','Helvetica Neue',Arial,sans-serif; background:var(--body-bg); color:var(--text); font-size:15px; line-height:1.78; }
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

  main { flex:1; padding:52px 64px 80px; max-width:850px; }
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
  pre { background:#2a2d3a; border:1px solid var(--border); border-radius:5px;
        padding:16px 20px; overflow-x:auto; margin:20px 0; }
  code { font-family:'JetBrains Mono',Consolas,monospace; font-size:13px; }
  hr { border:none; border-top:2px solid var(--border); margin:32px 0; }
  #article-content a { color:var(--accent); text-decoration:underline; text-decoration-color:var(--accent-dim); }
  #article-content a:hover { text-decoration-color:var(--accent); }
  img { max-width:100%; border-radius:4px; }
  #article-content img:not(a img) { cursor:zoom-in; }
  .lb-overlay {
    position:fixed; inset:0; background:rgba(0,0,0,.88);
    display:flex; align-items:center; justify-content:center;
    z-index:9000; cursor:zoom-out; animation:lb-in .15s ease;
  }
  @keyframes lb-in { from { opacity:0; } to { opacity:1; } }
  .lb-overlay img { max-width:92vw; max-height:92vh; border-radius:6px;
    box-shadow:0 8px 48px rgba(0,0,0,.6); cursor:default; }
  .img-row { display:flex; gap:16px; margin:20px 0 6px; flex-wrap:wrap; }
  table { border-collapse:collapse; width:100%; margin:16px 0; font-size:14px; font-family:inherit; }
  th, td { border:1px solid var(--border); padding:8px 12px; text-align:left; vertical-align:top; font-family:inherit; }
  th { background:var(--accent-dim); font-weight:700; }
  tr:nth-child(even) td { background:rgba(255,255,255,.05); }
  .img-row img { flex:1; min-width:0; width:0; }

  /* ── PDF-Link ── */
  .pdf-link { display:flex; align-items:center; gap:18px; background:#1e2a3a;
    border:1px solid var(--border); border-left:3px solid var(--accent);
    border-radius:3px; padding:16px 20px; text-decoration:none; color:inherit; margin:16px 0; }
  .pdf-link:hover { background:#243040; }
  .pdf-link-icon { font-size:32px; opacity:.55; flex-shrink:0; line-height:1; }
  .pdf-link-thumb { width:56px; flex-shrink:0; border-radius:2px; }
  .pdf-link-title { font-weight:700; font-size:14px; }
  .pdf-link-sub   { font-size:12px; color:var(--muted); margin-top:3px; }

  /* ── Timeline ── */
  .timeline { margin:24px 0; }
  .timeline-entry { display:grid; grid-template-columns:70px 14px 1fr; gap:0 12px; }
  .tl-year { font-weight:700; color:var(--accent); font-size:14px; text-align:right; padding-top:2px; }
  .tl-spine { display:flex; flex-direction:column; align-items:center; }
  .tl-dot { width:12px; height:12px; border-radius:50%; background:var(--accent); flex-shrink:0; margin-top:4px; }
  .tl-line { flex:1; width:2px; background:var(--border); margin-top:2px; }
  .timeline-entry:last-child .tl-line { display:none; }
  .tl-text { padding-bottom:20px; font-size:14px; line-height:1.65; }

  /* ── Infobox ── */
  .infobox { display:flex; align-items:flex-start; gap:12px; border-radius:4px;
    padding:14px 18px; margin:20px 0; border-left:3px solid var(--accent); }
  .infobox-icon { font-size:18px; flex-shrink:0; line-height:1.5; }
  .infobox-text { font-size:14px; line-height:1.65; }
  .infobox.info    { background:#101a2e; border-color:#2272c3; }
  .infobox.warning { background:#221800; border-color:#d97706; }
  .infobox.tip     { background:#0e1e0e; border-color:#16a34a; }

  /* ── Grey Mode (Light) ── */
  body.grey-mode {
    --body-bg: #ffffff; --content-bg: #ffffff;
    --sidebar-bg: #f2f2f2; --sidebar-border: #e0e0e0;
    --text: #1a1a1a; --muted: #777; --border: #e8e8e8;
  }
  body.grey-mode pre { background: #f0f4fa; }
  body.grey-mode tr:nth-child(even) td { background: #fafafa; }
  body.grey-mode .pdf-link { background: #f4f7fc; }
  body.grey-mode .pdf-link:hover { background: #eef2f9; }
  body.grey-mode .infobox.info    { background: #f0f7ff; border-color: #2272c3; }
  body.grey-mode .infobox.warning { background: #fffbeb; border-color: #d97706; }
  body.grey-mode .infobox.tip     { background: #f0fdf4; border-color: #16a34a; }

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
  /* ── Kommentare ── */
  .comments { margin-top:52px; padding-top:36px; border-top:2px solid var(--border); }
  .comments-hdr { font-size:17px; font-weight:800; margin-bottom:28px; }
  .comment { display:flex; gap:12px; margin-bottom:22px; }
  .comment.reply { margin-left:48px; margin-bottom:14px; }
  .c-avatar { width:36px; height:36px; border-radius:50%; background:var(--accent);
    display:flex; align-items:center; justify-content:center;
    font-weight:800; font-size:13px; color:#fff; flex-shrink:0; text-transform:uppercase; }
  .comment.reply .c-avatar { width:28px; height:28px; font-size:11px; }
  .c-body { flex:1; min-width:0; }
  .c-meta { font-size:13px; margin-bottom:4px; }
  .c-meta strong { color:var(--text); font-weight:700; }
  .c-meta .c-time { color:var(--muted); margin-left:8px; font-size:12px; }
  .c-text { font-size:14px; line-height:1.65; margin-bottom:6px; white-space:pre-wrap; }
  .c-actions { display:flex; gap:14px; }
  .c-actions button, .c-actions .c-link {
    background:none; border:none; cursor:pointer; color:var(--muted); font-family:inherit;
    font-size:12px; font-weight:600; padding:0; text-decoration:none; }
  .c-actions button:hover, .c-actions .c-link:hover { color:var(--accent); }
  .c-actions .c-del:hover { color:#dc2626; }
  .replies-wrap { margin-top:10px; border-left:2px solid var(--border); padding-left:16px; }
  .reply-form { display:none; margin-top:10px; }
  .reply-form.open { display:block; }
  .comment-input { width:100%; border:1px solid var(--border); border-radius:5px; padding:10px 13px;
    font-family:inherit; font-size:14px; resize:vertical; min-height:72px; outline:none;
    transition:border-color .15s; box-sizing:border-box; background:var(--content-bg); color:var(--text); }
  .comment-input:focus { border-color:var(--accent); }
  .comment-form-row { display:flex; justify-content:flex-end; gap:8px; margin-top:7px; }
  .btn-cmt { background:var(--accent); color:#fff; border:none; border-radius:5px;
    padding:7px 16px; font-family:inherit; font-size:13px; font-weight:600; cursor:pointer; }
  .btn-cmt:hover { opacity:.88; }
  .btn-cmt-cancel { background:none; border:1px solid var(--border); border-radius:5px;
    padding:7px 14px; font-family:inherit; font-size:13px; cursor:pointer; color:var(--muted); }
  .login-prompt { font-size:14px; color:var(--muted); text-align:center; padding:18px;
    border:1px dashed var(--border); border-radius:5px; margin-top:20px; }
  .login-prompt a { color:var(--accent); font-weight:600; text-decoration:none; }

  @media(max-width:768px) { nav { display:none; } main { padding:28px 20px 60px; } }
</style>
</head>
<body>
<script>if(localStorage.getItem('greyMode')==='1')document.body.classList.add('grey-mode');</script>
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
    <% if (previewMode) { %>
    <div style="background:#fffbeb;border:1px solid #fbbf24;border-radius:5px;padding:10px 18px;
                margin-bottom:24px;font-size:13px;display:flex;align-items:center;gap:12px;">
      <span style="font-size:16px;">✎</span>
      <span><strong>Vorschau</strong> — Dieser Artikel ist noch nicht veröffentlicht.</span>
      <a href="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/<%= article != null ? article.id : "" %>"
         style="margin-left:auto;color:#92400e;font-weight:600;text-decoration:none;">← Editor</a>
    </div>
    <% } %>
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
      <a class="blog-home-link" href="<%= request.getContextPath() %>/<%= blogSlug %>/">← Blog</a>
    </div>

    <div class="title-row">
      <% if (prevA != null) { %>
      <a class="title-nav" href="<%= request.getContextPath() %>/<%= blogSlug %>/<%= prevA.slug %>"
         title="<%= prevA.title %>">‹</a>
      <% } else { %>
      <span class="title-nav" style="visibility:hidden">‹</span>
      <% } %>
      <h1><%= article != null ? article.title : "" %></h1>
      <% if (nextA != null) { %>
      <a class="title-nav" href="<%= request.getContextPath() %>/<%= blogSlug %>/<%= nextA.slug %>"
         title="<%= nextA.title %>">›</a>
      <% } else { %>
      <span class="title-nav" style="visibility:hidden">›</span>
      <% } %>
    </div>
    <% if (article != null && article.subtitle != null && !article.subtitle.isEmpty()) { %>
    <p class="subtitle"><%= article.subtitle %></p>
    <% } %>
    <% if (article != null && article.tags != null && !article.tags.isEmpty()) { %>
    <div style="margin:-8px 0 28px;display:flex;flex-wrap:wrap;gap:6px">
      <% for (de.myblog.model.Tag t : article.tags) { %>
      <a href="<%= request.getContextPath() %>/<%= blogSlug %>/tag/<%= t.name %>"
         style="display:inline-block;background:#f0f0f0;color:#555;border-radius:20px;padding:3px 10px;font-size:12px;font-weight:600;text-decoration:none"
         onmouseover="this.style.background='<%= accent %>';this.style.color='#fff'"
         onmouseout="this.style.background='#f0f0f0';this.style.color='#555'">#<%= t.name %></a>
      <% } %>
    </div>
    <% } %>

    <!-- Block-Rendering (Stufe 1: Platzhalter, wird in Stufe 4 durch BlockRenderer ersetzt) -->
    <div id="article-content">
      <%
        if (article != null && article.blocks != null) {
          for (de.myblog.model.Block b : article.blocks) {
            try {
              org.json.JSONObject data = new org.json.JSONObject(b.data);
              switch (b.type) {
                case "paragraph": {
                  String ptext = data.optString("text", "");
                  // Bare URLs (no protocol) in href attributes → prepend https://
                  ptext = ptext.replaceAll(
                      "href=\"(?!https?://|//|/|#|mailto:|tel:)([^\"]+)\"",
                      "href=\"https://$1\"");
                  out.print("<p>" + ptext + "</p>");
                  break;
                }
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
                case "code": {
                  String raw = data.optString("code","")
                      .replace("&","&amp;").replace("<","&lt;").replace(">","&gt;");
                  out.print("<pre><code>" + raw + "</code></pre>");
                  break;
                }
                case "delimiter":
                  out.print("<hr>");
                  break;
                case "image":
                  org.json.JSONObject file = data.optJSONObject("file");
                  String url = file != null ? file.optString("url", "") : "";
                  String caption = data.optString("caption", "");
                  out.print("<div style=\"text-align:center;margin:20px 0\"><img src=\"" + url + "\" alt=\"" + caption + "\"></div>");
                  break;
                case "imagePair":
                  org.json.JSONObject ipl = data.optJSONObject("left");
                  org.json.JSONObject ipr = data.optJSONObject("right");
                  String lu = ipl != null ? ipl.optString("url","") : "";
                  String ru = ipr != null ? ipr.optString("url","") : "";
                  String la = ipl != null ? ipl.optString("alt","") : "";
                  String ra = ipr != null ? ipr.optString("alt","") : "";
                  if (!lu.isEmpty() || !ru.isEmpty()) {
                    out.print("<div class=\"img-row\">");
                    if (!lu.isEmpty()) out.print("<img src=\""+lu+"\" alt=\""+la+"\">");
                    if (!ru.isEmpty()) out.print("<img src=\""+ru+"\" alt=\""+ra+"\">");
                    out.print("</div>");
                  }
                  break;
                case "pdfLink":
                  String pu = data.optString("url","");
                  String pt = data.optString("title","");
                  String pd = data.optString("description","");
                  String ph = data.optString("thumb","");
                  if (!pu.isEmpty()) {
                    out.print("<a class=\"pdf-link\" href=\""+pu+"\" target=\"_blank\">");
                    if (!ph.isEmpty()) out.print("<img class=\"pdf-link-thumb\" src=\""+ph+"\">");
                    else out.print("<span class=\"pdf-link-icon\">📄</span>");
                    out.print("<div><div class=\"pdf-link-title\">"+pt+"</div>");
                    if (!pd.isEmpty()) out.print("<div class=\"pdf-link-sub\">"+pd+"</div>");
                    out.print("</div></a>");
                  }
                  break;
                case "timeline":
                  org.json.JSONArray tl = data.optJSONArray("entries");
                  if (tl != null && tl.length() > 0) {
                    out.print("<div class=\"timeline\">");
                    for (int ti = 0; ti < tl.length(); ti++) {
                      org.json.JSONObject te = tl.optJSONObject(ti);
                      if (te == null) continue;
                      out.print("<div class=\"timeline-entry\">");
                      out.print("<div class=\"tl-year\">"+te.optString("year","")+"</div>");
                      out.print("<div class=\"tl-spine\"><div class=\"tl-dot\"></div><div class=\"tl-line\"></div></div>");
                      out.print("<div class=\"tl-text\">"+te.optString("text","")+"</div>");
                      out.print("</div>");
                    }
                    out.print("</div>");
                  }
                  break;
                case "infobox":
                  String ibs = data.optString("style","info");
                  String ibi = data.optString("icon","ℹ");
                  String ibt = data.optString("text","");
                  out.print("<div class=\"infobox "+ibs+"\">");
                  out.print("<span class=\"infobox-icon\">"+ibi+"</span>");
                  out.print("<div class=\"infobox-text\">"+ibt+"</div>");
                  out.print("</div>");
                  break;
                case "html":
                  out.print(data.optString("html",""));
                  break;
              }
            } catch (Exception ignored) {}
          }
        }
      %>
    </div>

    <div class="article-nav">
      <% if (prevA != null) { %>
      <a href="<%= request.getContextPath() %>/<%= blogSlug %>/<%= prevA.slug %>">
        <span class="nav-circle">‹</span><%= prevA.title %>
      </a>
      <% } else { %><span></span><% } %>
      <a class="home" href="<%= request.getContextPath() %>/<%= blogSlug %>/">⌂ Blog</a>
      <% if (nextA != null) { %>
      <a href="<%= request.getContextPath() %>/<%= blogSlug %>/<%= nextA.slug %>">
        <%= nextA.title %><span class="nav-circle">›</span>
      </a>
      <% } else { %><span></span><% } %>
    </div>

    <!-- ── Kommentare ── -->
    <%
      @SuppressWarnings("unchecked")
      List<Comment> allComments = (List<Comment>) request.getAttribute("comments");
      if (allComments == null) allComments = Collections.emptyList();

      // Kommentare gruppieren: Top-Level und Replies
      List<Comment> topLevel = new ArrayList<>();
      Map<Integer, List<Comment>> replies = new LinkedHashMap<>();
      for (Comment cm : allComments) {
        if (cm.parentId == null) topLevel.add(cm);
        else replies.computeIfAbsent(cm.parentId, k -> new ArrayList<>()).add(cm);
      }

      // Hilfsmethode: Zeitstempel → "vor X Minuten" etc.
      // (inline als Lambda nicht möglich in JSP — direkte Berechnung per Methode)
      // Wird unten per Scriptlet gerechnet.

      Object loggedId = session.getAttribute("userId");
      String articleUrl = request.getContextPath() + "/" + blogSlug + "/" + (article != null ? article.slug : "");
    %>
    <div class="comments" id="comments">
      <div class="comments-hdr">Kommentare (<%= allComments.size() %>)</div>

      <% for (Comment cm : topLevel) {
           String initials = cm.authorDisplayName != null && !cm.authorDisplayName.isEmpty()
               ? cm.authorDisplayName.substring(0,1)
               : (cm.authorUsername != null ? cm.authorUsername.substring(0,1) : "?");
           String name = cm.authorDisplayName != null && !cm.authorDisplayName.isEmpty()
               ? cm.authorDisplayName : cm.authorUsername;

           // Zeitstempel
           String timeStr = "—";
           if (cm.createdAt != null) {
             long mins = ChronoUnit.MINUTES.between(cm.createdAt, LocalDateTime.now());
             if      (mins < 1)    timeStr = "gerade eben";
             else if (mins < 60)   timeStr = "vor " + mins + " Min.";
             else if (mins < 1440) timeStr = "vor " + (mins/60) + " Std.";
             else timeStr = cm.createdAt.format(java.time.format.DateTimeFormatter.ofPattern("dd.MM.yyyy"));
           }
           List<Comment> cmReplies = replies.getOrDefault(cm.id, Collections.emptyList());
      %>
      <div class="comment">
        <div class="c-avatar"><%= initials %></div>
        <div class="c-body">
          <div class="c-meta">
            <strong><%= name != null ? name : "?" %></strong>
            <span class="c-time"><%= timeStr %></span>
          </div>
          <div class="c-text"><%= cm.body %></div>
          <div class="c-actions">
            <% if (loggedId != null) { %>
            <button class="c-link" onclick="toggleReply(<%= cm.id %>)">Antworten</button>
            <% } %>
            <% if (loggedId != null && (int)loggedId == cm.authorId) { %>
            <form method="post" action="<%= articleUrl %>" style="display:inline"
                  onsubmit="return confirm('Kommentar löschen?')">
              <input type="hidden" name="_action" value="delete">
              <input type="hidden" name="commentId" value="<%= cm.id %>">
              <button type="submit" class="c-actions c-del">Löschen</button>
            </form>
            <% } %>
          </div>

          <!-- Antwortformular -->
          <% if (loggedId != null) { %>
          <div class="reply-form" id="reply-<%= cm.id %>">
            <form method="post" action="<%= articleUrl %>">
              <input type="hidden" name="parentId" value="<%= cm.id %>">
              <textarea class="comment-input" name="body" placeholder="Antwort schreiben …" rows="3"></textarea>
              <div class="comment-form-row">
                <button type="button" class="btn-cmt-cancel" onclick="toggleReply(<%= cm.id %>)">Abbrechen</button>
                <button type="submit" class="btn-cmt">Antworten</button>
              </div>
            </form>
          </div>
          <% } %>

          <!-- Replies -->
          <% if (!cmReplies.isEmpty()) { %>
          <div class="replies-wrap">
            <% for (Comment rep : cmReplies) {
                 String ri = rep.authorDisplayName != null && !rep.authorDisplayName.isEmpty()
                     ? rep.authorDisplayName.substring(0,1)
                     : (rep.authorUsername != null ? rep.authorUsername.substring(0,1) : "?");
                 String rn = rep.authorDisplayName != null && !rep.authorDisplayName.isEmpty()
                     ? rep.authorDisplayName : rep.authorUsername;
                 String rt = "—";
                 if (rep.createdAt != null) {
                   long m = ChronoUnit.MINUTES.between(rep.createdAt, LocalDateTime.now());
                   if      (m < 1)    rt = "gerade eben";
                   else if (m < 60)   rt = "vor " + m + " Min.";
                   else if (m < 1440) rt = "vor " + (m/60) + " Std.";
                   else rt = rep.createdAt.format(java.time.format.DateTimeFormatter.ofPattern("dd.MM.yyyy"));
                 }
            %>
            <div class="comment reply">
              <div class="c-avatar"><%= ri %></div>
              <div class="c-body">
                <div class="c-meta">
                  <strong><%= rn != null ? rn : "?" %></strong>
                  <span class="c-time"><%= rt %></span>
                </div>
                <div class="c-text"><%= rep.body %></div>
                <% if (loggedId != null && (int)loggedId == rep.authorId) { %>
                <div class="c-actions">
                  <form method="post" action="<%= articleUrl %>" style="display:inline"
                        onsubmit="return confirm('Kommentar löschen?')">
                    <input type="hidden" name="_action" value="delete">
                    <input type="hidden" name="commentId" value="<%= rep.id %>">
                    <button type="submit" class="c-actions c-del">Löschen</button>
                  </form>
                </div>
                <% } %>
              </div>
            </div>
            <% } %>
          </div>
          <% } %>
        </div>
      </div>
      <% } %>

      <!-- Neuer Kommentar -->
      <% if (loggedId != null) { %>
      <form method="post" action="<%= articleUrl %>" style="margin-top:8px">
        <textarea class="comment-input" name="body" placeholder="Kommentar schreiben …" rows="3"></textarea>
        <div class="comment-form-row">
          <button type="submit" class="btn-cmt">Kommentieren</button>
        </div>
      </form>
      <% } else { %>
      <div class="login-prompt">
        <a href="<%= request.getContextPath() %>/login?next=<%= articleUrl %>">Anmelden</a>, um zu kommentieren.
      </div>
      <% } %>
    </div><!-- /comments -->
  </main>
</div>

<script>
function toggleGreyMode() {
  var on = document.body.classList.toggle('grey-mode');
  var btn = document.getElementById('grey-btn');
  btn.classList.toggle('active', on);
  var label = btn.querySelector('.btn-label');
  if (label) label.textContent = on ? 'Dark Mode' : 'Grey Mode';
  localStorage.setItem('greyMode', on ? '1' : '0');
}
(function(){
  var on = document.body.classList.contains('grey-mode');
  var btn = document.getElementById('grey-btn');
  if (btn) {
    btn.classList.toggle('active', on);
    var label = btn.querySelector('.btn-label');
    if (label) label.textContent = on ? 'Dark Mode' : 'Grey Mode';
  }
})();
function toggleSidebar() {
  const nav = document.getElementById('sidebar');
  nav.classList.toggle('collapsed');
  const c = nav.classList.contains('collapsed');
  document.getElementById('sidebar-icon').textContent  = c ? '›' : '‹';
  document.getElementById('sidebar-label').textContent = c ? 'Ausklappen' : 'Einklappen';
}

// ── Reply-Toggle ──
function toggleReply(id) {
  const f = document.getElementById('reply-' + id);
  if (f) f.classList.toggle('open');
}

// TOC aus h3-Elementen aufbauen
(function() {
  const nav     = document.getElementById('sidebar');
  const section = nav.querySelector('.nav-section');
  const heads   = document.querySelectorAll('h3[id]');
  let after = section;
  heads.forEach(h => {
    const a = document.createElement('a');
    a.className = 'toc-link';
    a.href = '#' + h.id;
    a.textContent = h.textContent;
    after.after(a);
    after = a;
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

document.querySelectorAll('#article-content a').forEach(a => {
  a.target = '_blank';
  a.rel    = 'noopener';
});

// ── Lightbox ──
document.querySelectorAll('#article-content img').forEach(img => {
  if (img.closest('a')) return;
  img.addEventListener('click', () => {
    const ov = document.createElement('div');
    ov.className = 'lb-overlay';
    const big = document.createElement('img');
    big.src = img.src;
    big.alt = img.alt;
    ov.appendChild(big);
    const close = () => ov.remove();
    ov.addEventListener('click', close);
    big.addEventListener('click', e => e.stopPropagation());
    document.addEventListener('keydown', e => { if (e.key === 'Escape') close(); }, { once: true });
    document.body.appendChild(ov);
  });
});
</script>
</body>
</html>
