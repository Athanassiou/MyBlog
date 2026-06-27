<%-- N3 Site-Header für öffentliche Blog-Seiten (blog-home, blog-index). --%>
<%
  jakarta.servlet.http.HttpSession _pubSess = request.getSession(false);
  boolean _loggedIn = _pubSess != null && _pubSess.getAttribute("userId") != null;
  String  _dispName = _loggedIn ? (String) _pubSess.getAttribute("displayName") : null;
%>
<script>if(localStorage.getItem('greyMode')==='1')document.body.classList.add('grey-mode');</script>
<header class="site-header">
  <div class="site-header-left">
    <a class="site-logo" href="/">
      <div class="logo-icon">EA</div>
      <span class="logo-text"><span>athanassiou</span>.me</span>
    </a>
  </div>
  <div class="site-header-center">
    <% if (_loggedIn) { %>
    <span id="user-greeting" style="display:block">Hallo, <%= _dispName %></span>
    <% } else { %>
    <span id="user-greeting" style="display:none"></span>
    <% } %>
  </div>
  <div class="site-header-right">
    <span id="site-clock"></span>
    <% if (_loggedIn) { %>
    <form method="post" action="<%= request.getContextPath() %>/logout" style="margin:0">
      <button type="submit" class="header-logout">Abmelden</button>
    </form>
    <% } else { %>
    <a class="header-login-btn" href="<%= request.getContextPath() %>/login?next=/">Anmelden</a>
    <% } %>
  </div>
</header>
