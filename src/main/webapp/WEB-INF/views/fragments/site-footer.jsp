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
    btn.textContent = '◑ Dark Mode';
  }
})();
function toggleGreyMode(){
  var on = document.body.classList.toggle('grey-mode');
  var btn = document.getElementById('grey-btn');
  btn.classList.toggle('active', on);
  btn.textContent = on ? '◑ Dark Mode' : '◑ Grey Mode';
  localStorage.setItem('greyMode', on ? '1' : '0');
}
</script>
