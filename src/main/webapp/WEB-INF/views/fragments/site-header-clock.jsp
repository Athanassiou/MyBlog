<%-- Uhr-JavaScript für den N3 Site-Header.
     Wird kurz vor </body> eingebunden. --%>
<script>
(function() {
  const el = document.getElementById('site-clock');
  if (!el) return;
  function tick() {
    const now = new Date();
    const date = now.toLocaleDateString('de-DE', { weekday:'short', day:'2-digit', month:'2-digit', year:'numeric' });
    const time = now.toLocaleTimeString('de-DE', { hour:'2-digit', minute:'2-digit', second:'2-digit' });
    el.innerHTML = '<span style="color:var(--accent)">' + date + '</span>'
                 + '<span style="color:#999"> · </span>' + time;
  }
  tick(); setInterval(tick, 1000);
})();
</script>
