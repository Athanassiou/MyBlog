<%-- Footer mit Dark/Grey-Mode-Toggle fuer alle Dashboard-Seiten.
     Verwendet denselben localStorage-Key 'greyMode' wie Homepage und Artikel. --%>
<footer class="site-footer">
  <button class="footer-toggle" id="grey-btn" onclick="toggleGreyMode()">&#9681; Grey Mode</button>
</footer>
<script>
(function(){
  var btn = document.getElementById('grey-btn');
  if(document.body.classList.contains('grey-mode')){
    btn.classList.add('active');
    btn.textContent = '\u25d1 Dark Mode';
  }
})();
function toggleGreyMode(){
  var on = document.body.classList.toggle('grey-mode');
  var btn = document.getElementById('grey-btn');
  btn.classList.toggle('active', on);
  btn.textContent = on ? '\u25d1 Dark Mode' : '\u25d1 Grey Mode';
  localStorage.setItem('greyMode', on ? '1' : '0');
}
</script>
