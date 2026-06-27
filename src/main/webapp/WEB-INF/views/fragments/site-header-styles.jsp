<%-- Gemeinsames CSS für den N3 Site-Header.
     Wird innerhalb eines <style>-Blocks eingebunden.
     Voraussetzung: --accent ist über :root in der einbindenden Seite definiert. --%>
  /* ── N3 Site Header ── */
  .site-header { background:#d7d7d7; border-bottom:1px solid #ccc; padding:0 40px; height:54px;
    display:flex; align-items:center; position:sticky; top:0; z-index:20; }
  .site-header-left { flex:1; display:flex; align-items:center; gap:10px; min-width:0; }
  .site-logo { display:flex; align-items:center; gap:28px; text-decoration:none; flex-shrink:0; }
  .logo-icon { width:32px; height:32px; background:var(--accent); border-radius:50%;
    display:flex; align-items:center; justify-content:center;
    color:#111; font-weight:700; font-size:12px; letter-spacing:.4px; flex-shrink:0; }
  .logo-text { font-size:16px; font-weight:700; color:#222; letter-spacing:.3px; }
  .logo-text span { color:var(--accent); }
  .site-sep { color:#bbb; font-size:16px; flex-shrink:0; }
  .site-ctx { font-size:14px; font-weight:700; color:#444; text-decoration:none; white-space:nowrap; }
  .site-ctx:hover { color:var(--accent); }
  .topbar-title { font-size:14px; color:#777; font-weight:600;
    overflow:hidden; text-overflow:ellipsis; white-space:nowrap; min-width:0; }
  .site-header-center { flex:1; display:flex; justify-content:center; align-items:center; }
  .site-greeting { font-size:14px; font-weight:600; color:#555; }
  #user-greeting { display:none; font-size:14px; font-weight:600; color:#555; }
  .site-header-right { flex:1; display:flex; align-items:center; justify-content:flex-end; gap:12px; }
  #site-clock { font-size:14px; font-weight:700; color:#333; font-variant-numeric:tabular-nums; letter-spacing:.3px; }
  .header-logout { background:transparent; border:1px solid var(--accent); border-radius:6px;
    padding:6px 16px; font-family:inherit; font-size:12px; font-weight:600; letter-spacing:.3px;
    color:var(--accent); cursor:pointer; transition:background .15s,color .15s,border-color .15s; }
  .header-logout:hover { background:var(--accent); color:#111; }
  .header-login-btn { font-family:inherit; font-size:12px; font-weight:600; padding:6px 16px;
    border-radius:6px; cursor:pointer; text-decoration:none; letter-spacing:.3px;
    border:1px solid var(--accent); background:transparent; color:var(--accent);
    transition:background .15s,color .15s,border-color .15s; }
  .header-login-btn:hover { background:var(--accent); color:#111; }
