<%-- N3 Site-Header für öffentliche Blog-Seiten (blog-home, blog-index).
     Login-Status wird per JS gesteuert (keine Session-Abhängigkeit). --%>
<header class="site-header">
  <div class="site-header-left">
    <a class="site-logo" href="/">
      <div class="logo-icon">EA</div>
      <span class="logo-text"><span>athanassiou</span>.me</span>
    </a>
  </div>
  <div class="site-header-center">
    <span id="user-greeting"></span>
  </div>
  <div class="site-header-right">
    <span id="site-clock"></span>
    <a class="header-login-btn" id="header-login-btn"
       href="<%= request.getContextPath() %>/login?next=/">Anmelden</a>
  </div>
</header>
