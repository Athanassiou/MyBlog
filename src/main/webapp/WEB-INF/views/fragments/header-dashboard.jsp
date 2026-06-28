<%-- N3 Site-Header für alle Dashboard- und Admin-Seiten.
     Variablen (vor dem Include setzen):
       String hBlogSlug    — Blog-Slug (null = nur Logo); nur für Fallback-Link genutzt
       String hBlogName    — Anzeigename 2. Breadcrumb-Ebene (null = kein Breadcrumb)
       String hBlogLink    — Optionaler vollständiger Link für 2. Ebene (null → /dashboard/<hBlogSlug>/)
       String hPageTitle   — Statischer Text 3. Ebene, z.B. "Einstellungen" (null = keine 3. Ebene)
       String hTopbarTitle — Live-aktualisierter Text 3. Ebene, id="topbar-title" (null = nein) --%>
<script>if(localStorage.getItem('greyMode')==='1')document.body.classList.add('grey-mode');</script>
<header class="site-header">
  <div class="site-header-left">
    <a class="site-logo" href="/">
      <div class="logo-icon">EA</div>
      <span class="logo-text"><span>athanassiou</span>.me</span>
    </a>
    <% if (hBlogSlug != null) { %>
    <span class="site-sep">/</span>
    <% String _h2link = hBlogLink != null ? hBlogLink : (request.getContextPath() + "/dashboard/" + hBlogSlug + "/"); %>
    <% if (hPageTitle != null || hTopbarTitle != null) { %>
    <a href="<%= _h2link %>" class="site-ctx"><%= hBlogName %></a>
    <% } else { %>
    <span class="site-ctx"><%= hBlogName %></span>
    <% } %>
    <% if (hTopbarTitle != null) { %>
    <span class="site-sep">/</span>
    <span class="topbar-title" id="topbar-title"><%= hTopbarTitle %></span>
    <% } else if (hPageTitle != null) { %>
    <span class="site-sep">/</span>
    <span class="site-ctx"><%= hPageTitle %></span>
    <% } %>
    <% } %>
  </div>
  <div class="site-header-center">
    <span class="site-greeting">Hallo, <%= session.getAttribute("displayName") %></span>
  </div>
  <div class="site-header-right">
    <span id="site-clock"></span>
    <a href="<%= request.getContextPath() %>/help.html" target="_blank"
       title="Handbuch" style="color:var(--muted);font-size:13px;font-weight:700;text-decoration:none;
       width:28px;height:28px;border:1px solid var(--border,#ccc);border-radius:50%;
       display:inline-flex;align-items:center;justify-content:center;transition:color .15s,border-color .15s"
       onmouseover="this.style.color='var(--accent)';this.style.borderColor='var(--accent)'"
       onmouseout="this.style.color='';this.style.borderColor=''">?</a>
    <form method="post" action="<%= request.getContextPath() %>/logout" style="display:inline">
      <button type="submit" class="header-logout">Abmelden</button>
    </form>
  </div>
</header>
