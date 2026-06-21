<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="de.myblog.model.Article, de.myblog.model.Block, java.util.List" %>
<%@ page import="org.json.JSONArray, org.json.JSONObject" %>
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<%
  Article article  = (Article) request.getAttribute("article");
  de.myblog.model.Blog edBlog = (de.myblog.model.Blog) request.getAttribute("blog");
  String blogSlug  = edBlog != null ? edBlog.slug : "main";
  boolean isNew    = (article == null);
  String pageTitle = isNew ? "Neuer Artikel" : article.title;
%>
<title><%= pageTitle %> · Dashboard · MyBlog</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Raleway:wght@400;600;700;800&display=swap" rel="stylesheet">
<style>
  :root {
    --accent:     <%= (!isNew && article.accentColor != null) ? article.accentColor : "#e5a00d" %>;
    --accent-dim: rgba(229,160,13,.10);
    --border:     #e8e8e8;
    --text:       #1a1a1a;
    --muted:      #777;
  }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: Raleway, sans-serif; background: #f5f5f5; color: var(--text); min-height: 100vh; }

  /* ── Topbar ── */
  .topbar {
    background: #fff;
    border-bottom: 1px solid var(--border);
    padding: 0 24px;
    height: 52px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    position: sticky;
    top: 0;
    z-index: 20;
  }
  .topbar-left { display: flex; align-items: center; gap: 16px; }
  .topbar-brand { font-size: 16px; font-weight: 800; color: var(--accent); letter-spacing: -.3px; text-decoration: none; }
  .topbar-sep { color: var(--border); }
  .topbar-title { font-size: 14px; color: var(--muted); font-weight: 600; max-width: 340px;
                  overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .topbar-actions { display: flex; gap: 8px; }

  /* ── Buttons ── */
  .btn {
    display: inline-flex; align-items: center; gap: 6px;
    border-radius: 5px; padding: 8px 16px;
    font-family: inherit; font-size: 13px; font-weight: 600;
    cursor: pointer; border: 1px solid transparent;
    transition: opacity .15s, background .15s, border-color .15s;
    text-decoration: none;
  }
  .btn-primary { background: var(--accent); color: #fff; }
  .btn-primary:hover { opacity: .88; }
  .btn-ghost { background: #fff; color: var(--text); border-color: var(--border); }
  .btn-ghost:hover { border-color: var(--accent); color: var(--accent); background: var(--accent-dim); }
  .btn-publish { background: #16a34a; color: #fff; }
  .btn-publish:hover { opacity: .88; }
  .btn-unpublish { background: #fff; color: #6b7280; border-color: var(--border); }
  .btn-unpublish:hover { border-color: #dc2626; color: #dc2626; }

  /* ── Layout ── */
  .editor-wrap { max-width: 860px; margin: 0 auto; padding: 32px 24px 80px; }

  /* ── Meta-Karte ── */
  .meta-card {
    background: #fff;
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 24px 28px;
    margin-bottom: 24px;
  }
  .meta-row { display: flex; gap: 16px; flex-wrap: wrap; margin-bottom: 14px; }
  .meta-row:last-child { margin-bottom: 0; }
  .field { display: flex; flex-direction: column; gap: 5px; flex: 1; min-width: 180px; }
  .field label {
    font-size: 11px; font-weight: 700; text-transform: uppercase;
    letter-spacing: .5px; color: var(--muted);
  }
  .field input[type=text] {
    border: 1px solid var(--border); border-radius: 5px;
    padding: 9px 12px; font-family: inherit; font-size: 14px;
    color: var(--text); outline: none; transition: border-color .15s;
  }
  .field input:focus { border-color: var(--accent); }
  .field-title input { font-size: 16px; font-weight: 700; }

  /* Farb-Picker */
  .color-row { display: flex; align-items: center; gap: 10px; }
  input[type=color] {
    width: 36px; height: 36px; border: 1px solid var(--border);
    border-radius: 5px; padding: 2px; cursor: pointer; background: none;
  }
  .color-hex {
    border: 1px solid var(--border); border-radius: 5px;
    padding: 9px 12px; font-family: monospace; font-size: 13px;
    width: 100px; outline: none; color: var(--text);
    transition: border-color .15s;
  }
  .color-hex:focus { border-color: var(--accent); }
  .color-preview {
    width: 20px; height: 20px; border-radius: 50%;
    border: 1px solid var(--border);
    background: var(--accent);
    flex-shrink: 0;
  }

  /* ── Editor-Bereich ── */
  .editor-card {
    background: #fff;
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 32px 40px;
    min-height: 400px;
  }
  #editorjs { outline: none; }

  /* ── Neu-Artikel Dialog ── */
  .new-overlay {
    position: fixed; inset: 0; background: rgba(0,0,0,.35);
    display: flex; align-items: center; justify-content: center; z-index: 100;
  }
  .new-card {
    background: #fff; border-radius: 10px; padding: 36px 40px;
    width: 100%; max-width: 440px; box-shadow: 0 8px 40px rgba(0,0,0,.15);
  }
  .new-card h2 { font-size: 20px; font-weight: 800; margin-bottom: 22px; }
</style>
</head>
<body>

<div class="topbar">
  <div class="topbar-left">
    <a class="topbar-brand" href="<%= request.getContextPath() %>/dashboard/" style="text-decoration:none">MyBlog</a>
    <span class="topbar-sep">/</span>
    <a href="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/" style="font-size:14px;font-weight:700;color:#1a1a1a;text-decoration:none"><%= blogSlug %></a>
    <span class="topbar-sep">/</span>
    <span class="topbar-title" id="topbar-title"><%= isNew ? "Neuer Artikel" : (article.title != null ? article.title : "Artikel") %></span>
  </div>
  <div class="topbar-actions">
    <% if (!isNew) { %>
    <a class="btn btn-ghost" href="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/">← Zurück</a>
    <button class="btn btn-primary" onclick="saveArticle()">Speichern</button>
    <% if ("published".equals(article.status)) { %>
    <form method="post" action="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/<%= article.id %>/unpublish" style="display:inline">
      <button class="btn btn-unpublish" type="submit">Zurückziehen</button>
    </form>
    <% } else { %>
    <button class="btn btn-publish" onclick="saveAndPublish()">Veröffentlichen</button>
    <% } %>
    <% } %>
  </div>
</div>

<div class="editor-wrap">

  <% if (!isNew) { %>
  <!-- ── Meta-Formular (bestehender Artikel) ── -->
  <form id="meta-form" method="post" action="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/<%= article.id %>">
    <input type="hidden" id="blocks-input" name="blocks" value="">
    <input type="hidden" id="publish-flag" name="_publish" value="">

    <div class="meta-card">
      <div class="meta-row">
        <div class="field field-title" style="flex:2">
          <label for="title">Titel</label>
          <input type="text" id="title" name="title" required
                 value="<%= article.title != null ? article.title : "" %>"
                 oninput="document.getElementById('topbar-title').textContent = this.value || 'Artikel'">
        </div>
      </div>
      <div class="meta-row">
        <div class="field" style="flex:2">
          <label for="subtitle">Untertitel</label>
          <input type="text" id="subtitle" name="subtitle"
                 value="<%= article.subtitle != null ? article.subtitle : "" %>">
        </div>
        <div class="field">
          <label for="slug">Slug (URL)</label>
          <input type="text" id="slug" name="slug" required
                 value="<%= article.slug != null ? article.slug : "" %>">
        </div>
      </div>
      <div class="meta-row" style="align-items:flex-end">
        <div class="field">
          <label>Akzentfarbe</label>
          <div class="color-row">
            <input type="color" id="color-picker"
                   value="<%= article.accentColor != null ? article.accentColor : "#e5a00d" %>"
                   oninput="syncColor(this.value)">
            <input type="text" class="color-hex" id="color-hex" name="accentColor" maxlength="7"
                   value="<%= article.accentColor != null ? article.accentColor : "#e5a00d" %>"
                   oninput="syncColorFromHex(this.value)">
            <div class="color-preview" id="color-preview"></div>
          </div>
        </div>
      </div>
    </div>
  </form>

  <!-- ── EditorJS-Bereich ── -->
  <div class="editor-card">
    <div id="editorjs"></div>
  </div>

  <% } else { %>
  <!-- ── Dialog: Neuer Artikel anlegen ── -->
  <div class="new-overlay">
    <div class="new-card">
      <h2>Neuer Artikel</h2>
      <form method="post" action="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/new">
        <div class="field" style="margin-bottom:14px">
          <label for="new-title">Titel</label>
          <input type="text" id="new-title" name="title" required autofocus
                 style="border:1px solid #e8e8e8;border-radius:5px;padding:10px 13px;font-family:inherit;font-size:15px;font-weight:700;width:100%;outline:none"
                 oninput="autoSlug(this.value)">
        </div>
        <div class="field" style="margin-bottom:20px">
          <label for="new-slug">Slug (URL)</label>
          <input type="text" id="new-slug" name="slug" required
                 style="border:1px solid #e8e8e8;border-radius:5px;padding:10px 13px;font-family:monospace;font-size:13px;width:100%;outline:none">
        </div>
        <div style="display:flex;gap:10px">
          <input type="hidden" name="accentColor" value="#e5a00d">
          <a class="btn btn-ghost" href="<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/" style="flex:1;justify-content:center">Abbrechen</a>
          <button class="btn btn-primary" type="submit" style="flex:2;justify-content:center">Artikel anlegen</button>
        </div>
      </form>
    </div>
  </div>
  <% } %>

</div><!-- /editor-wrap -->

<% if (!isNew) { %>
<!-- ── EditorJS ── -->
<script src="https://cdn.jsdelivr.net/npm/@editorjs/editorjs@latest/dist/editorjs.umd.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@editorjs/header@latest/dist/header.umd.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@editorjs/list@latest/dist/list.umd.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@editorjs/quote@latest/dist/quote.umd.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@editorjs/code@latest/dist/code.umd.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@editorjs/delimiter@latest/dist/delimiter.umd.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@editorjs/image@latest/dist/image.umd.min.js"></script>

<!-- ── Custom EditorJS Tools ── -->
<script>
// ─── ImagePairTool ───────────────────────────────────────────
class ImagePairTool {
  static get toolbox() {
    return { title: 'Bildpaar', icon: '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="3" width="9" height="14" rx="1"/><rect x="13" y="3" width="9" height="14" rx="1"/></svg>' };
  }
  constructor({ data, config }) {
    this.data = { left: data.left||{url:'',alt:''}, right: data.right||{url:'',alt:''} };
    this.uploadUrl = config.uploadUrl || '/upload';
    this.wrapper = null;
  }
  render() {
    this.wrapper = document.createElement('div');
    this.wrapper.style.cssText = 'display:flex;gap:12px;margin:4px 0';
    ['left','right'].forEach(side => {
      const box = document.createElement('div');
      box.style.cssText = 'flex:1;display:flex;flex-direction:column;gap:6px';
      const img = document.createElement('img');
      img.src = this.data[side].url || '';
      img.style.cssText = 'width:100%;border-radius:4px;' + (this.data[side].url ? '' : 'display:none');
      const lbl = document.createElement('label');
      lbl.style.cssText = 'cursor:pointer;padding:7px;border:1.5px dashed #ccc;border-radius:4px;text-align:center;font-size:12px;color:#777;display:block';
      lbl.textContent = this.data[side].url ? 'Bild ersetzen' : 'Bild hochladen';
      const inp = document.createElement('input');
      inp.type='file'; inp.accept='image/*'; inp.style.display='none';
      inp.onchange = async e => {
        const f = e.target.files[0]; if (!f) return;
        const fd = new FormData(); fd.append('image', f);
        const r = await fetch(this.uploadUrl, {method:'POST',body:fd});
        const j = await r.json();
        if (j.success) {
          this.data[side] = { url: j.file.url, alt: altInp.value };
          img.src = j.file.url; img.style.display='block';
          lbl.textContent = 'Bild ersetzen';
        }
      };
      lbl.appendChild(inp);
      const altInp = document.createElement('input');
      altInp.type='text'; altInp.placeholder='Beschreibung (alt)';
      altInp.value = this.data[side].alt||'';
      altInp.style.cssText = 'border:1px solid #e8e8e8;border-radius:4px;padding:5px 8px;font-size:12px;width:100%;box-sizing:border-box';
      altInp.oninput = () => { this.data[side] = {...this.data[side], alt: altInp.value}; };
      box.append(img, lbl, altInp);
      this.wrapper.append(box);
    });
    return this.wrapper;
  }
  save() { return this.data; }
}

// ─── PdfLinkTool ────────────────────────────────────────────
class PdfLinkTool {
  static get toolbox() {
    return { title: 'PDF-Link', icon: '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="9" y1="13" x2="15" y2="13"/><line x1="9" y1="17" x2="12" y2="17"/></svg>' };
  }
  constructor({ data }) {
    this.data = { url: data.url||'', title: data.title||'', description: data.description||'', thumb: data.thumb||'' };
    this.wrapper = null;
  }
  render() {
    this.wrapper = document.createElement('div');
    this.wrapper.style.cssText = 'border:1px solid #e8e8e8;border-left:3px solid var(--accent);border-radius:4px;padding:14px;display:flex;flex-direction:column;gap:7px;background:#f4f7fc';
    const hdr = document.createElement('div');
    hdr.style.cssText = 'font-weight:700;font-size:11px;text-transform:uppercase;letter-spacing:.5px;color:#777;margin-bottom:2px';
    hdr.textContent = 'PDF-Link';
    this.wrapper.append(hdr);
    [['url','PDF-URL (z.B. /files/dokument.pdf)'],
     ['title','Titel'],
     ['description','Beschreibung (z.B. PDF · 2 MB)'],
     ['thumb','Thumbnail-URL (optional)']
    ].forEach(([key, ph]) => {
      const inp = document.createElement('input');
      inp.type='text'; inp.placeholder=ph; inp.value=this.data[key]||'';
      inp.style.cssText = 'border:1px solid #e8e8e8;border-radius:4px;padding:6px 9px;font-size:13px;width:100%;box-sizing:border-box;background:#fff';
      inp.oninput = () => { this.data[key] = inp.value; };
      this.wrapper.append(inp);
    });
    return this.wrapper;
  }
  save() { return this.data; }
}

// ─── TimelineTool ────────────────────────────────────────────
class TimelineTool {
  static get toolbox() {
    return { title: 'Timeline', icon: '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="2" x2="12" y2="22"/><polyline points="17 7 12 2 7 7"/><line x1="5" y1="10" x2="12" y2="10"/><line x1="5" y1="14" x2="12" y2="14"/><line x1="5" y1="18" x2="12" y2="18"/></svg>' };
  }
  constructor({ data }) {
    this.data = { entries: (data.entries||[]).map(e=>({...e})) };
    this.listWrap = null;
  }
  render() {
    const wrap = document.createElement('div');
    wrap.style.cssText = 'border:1px solid #e8e8e8;border-radius:4px;padding:14px';
    const hdr = document.createElement('div');
    hdr.style.cssText = 'font-weight:700;font-size:11px;text-transform:uppercase;letter-spacing:.5px;color:#777;margin-bottom:10px';
    hdr.textContent = 'Timeline';
    this.listWrap = document.createElement('div');
    this.listWrap.style.cssText = 'display:flex;flex-direction:column;gap:6px';
    this.data.entries.forEach(e => this._addRow(e.year, e.text));
    const addBtn = document.createElement('button');
    addBtn.type='button'; addBtn.textContent='+ Eintrag';
    addBtn.style.cssText = 'margin-top:8px;padding:5px 10px;border:1.5px dashed #ccc;border-radius:4px;cursor:pointer;font-size:12px;background:none;width:100%;color:#777';
    addBtn.onclick = () => this._addRow('','');
    wrap.append(hdr, this.listWrap, addBtn);
    return wrap;
  }
  _addRow(year, text) {
    const row = document.createElement('div');
    row.style.cssText = 'display:flex;gap:8px;align-items:center';
    const yInp = document.createElement('input');
    yInp.type='text'; yInp.placeholder='Jahr'; yInp.value=year||'';
    yInp.style.cssText = 'width:80px;border:1px solid #e8e8e8;border-radius:4px;padding:5px 8px;font-size:13px;flex-shrink:0';
    const tInp = document.createElement('input');
    tInp.type='text'; tInp.placeholder='Ereignis …'; tInp.value=text||'';
    tInp.style.cssText = 'flex:1;border:1px solid #e8e8e8;border-radius:4px;padding:5px 8px;font-size:13px';
    const del = document.createElement('button');
    del.type='button'; del.textContent='×';
    del.style.cssText = 'width:22px;height:22px;border:none;background:none;cursor:pointer;color:#aaa;font-size:16px;flex-shrink:0;padding:0;line-height:1';
    del.onclick = () => row.remove();
    row.append(yInp, tInp, del);
    this.listWrap.append(row);
  }
  save() {
    const entries = [];
    this.listWrap.querySelectorAll('div').forEach(row => {
      const [y,t] = row.querySelectorAll('input');
      if (y && t && (y.value||t.value)) entries.push({year:y.value, text:t.value});
    });
    return { entries };
  }
}

// ─── InfoboxTool ─────────────────────────────────────────────
class InfoboxTool {
  static get toolbox() {
    return { title: 'Infobox', icon: '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>' };
  }
  static get STYLES() {
    return {
      info:    { icon:'ℹ', bg:'#f0f7ff', border:'#2272c3', label:'Info' },
      warning: { icon:'⚠', bg:'#fffbeb', border:'#d97706', label:'Warnung' },
      tip:     { icon:'✓', bg:'#f0fdf4', border:'#16a34a', label:'Tipp' }
    };
  }
  constructor({ data }) {
    this.data = { style: data.style||'info', icon: data.icon||'ℹ', text: data.text||'' };
    this.wrapper = null;
    this.textEl = null;
  }
  render() {
    this.wrapper = document.createElement('div');
    this._rebuild();
    return this.wrapper;
  }
  _rebuild() {
    const cfg = InfoboxTool.STYLES[this.data.style] || InfoboxTool.STYLES.info;
    this.wrapper.innerHTML = '';
    this.wrapper.style.cssText = `border-radius:4px;padding:14px 16px;border-left:3px solid ${cfg.border};background:${cfg.bg}`;
    const sel = document.createElement('select');
    sel.style.cssText = 'border:1px solid #e8e8e8;border-radius:4px;padding:3px 8px;font-size:12px;margin-bottom:10px;font-family:inherit;background:#fff';
    Object.entries(InfoboxTool.STYLES).forEach(([k,v]) => {
      const o = document.createElement('option');
      o.value=k; o.textContent=v.label; if(k===this.data.style) o.selected=true;
      sel.append(o);
    });
    sel.onchange = () => {
      this.data.style = sel.value;
      this.data.icon  = InfoboxTool.STYLES[sel.value].icon;
      const cur = this.textEl ? this.textEl.value : this.data.text;
      this.data.text = cur;
      this._rebuild();
    };
    const row = document.createElement('div');
    row.style.cssText = 'display:flex;gap:10px;align-items:flex-start';
    const icon = document.createElement('span');
    icon.textContent = cfg.icon;
    icon.style.cssText = 'font-size:18px;line-height:1.5;flex-shrink:0';
    this.textEl = document.createElement('textarea');
    this.textEl.value = this.data.text||'';
    this.textEl.placeholder = 'Text …';
    this.textEl.style.cssText = 'flex:1;border:none;background:transparent;font-family:inherit;font-size:14px;resize:vertical;min-height:56px;outline:none;line-height:1.6';
    this.textEl.oninput = () => { this.data.text = this.textEl.value; };
    row.append(icon, this.textEl);
    this.wrapper.append(sel, row);
  }
  save() { return { style:this.data.style, icon:this.data.icon, text:this.textEl ? this.textEl.value : this.data.text }; }
}
</script>

<script>
// ── Bestehende Blöcke aus Java übergeben ──
const existingBlocks = <%
  if (article.blocks != null && !article.blocks.isEmpty()) {
      JSONArray arr = new JSONArray();
      for (Block b : article.blocks) {
          JSONObject entry = new JSONObject();
          entry.put("type", b.type);
          try { entry.put("data", new JSONObject(b.data)); }
          catch (Exception e) { entry.put("data", new JSONObject()); }
          arr.put(entry);
      }
      out.print(arr.toString());
  } else {
      out.print("[]");
  }
%>;

// ── EditorJS initialisieren ──
const editor = new EditorJS({
  holder: 'editorjs',
  placeholder: 'Artikel schreiben …',
  data: { blocks: existingBlocks },
  tools: {
    header:    { class: Header,    inlineToolbar: true,
                 config: { levels: [2,3], defaultLevel: 2 } },
    list:      { class: List,      inlineToolbar: true },
    quote:     { class: Quote,     inlineToolbar: true },
    code:      { class: CodeTool },
    delimiter: { class: Delimiter },
    image: {
      class: ImageTool,
      config: { endpoints: { byFile: '<%= request.getContextPath() %>/upload' } }
    },
    imagePair: {
      class: ImagePairTool,
      config: { uploadUrl: '<%= request.getContextPath() %>/upload' }
    },
    pdfLink:  { class: PdfLinkTool },
    timeline: { class: TimelineTool },
    infobox:  { class: InfoboxTool }
  }
});

// ── Speichern ──
async function saveArticle() {
  const data   = await editor.save();
  document.getElementById('blocks-input').value = JSON.stringify(data);
  document.getElementById('meta-form').submit();
}

async function saveAndPublish() {
  const data = await editor.save();
  document.getElementById('blocks-input').value = JSON.stringify(data);
  // Publizieren via separatem Form-Post nach dem Speichern
  const form = document.getElementById('meta-form');
  form.action = '<%= request.getContextPath() %>/dashboard/<%= blogSlug %>/<%= article.id %>';
  await saveArticle();
  // Publish-Redirect danach im Servlet
}

// ── Farb-Sync ──
function syncColor(hex) {
  document.getElementById('color-hex').value = hex;
  document.getElementById('color-preview').style.background = hex;
  document.documentElement.style.setProperty('--accent', hex);
}
function syncColorFromHex(val) {
  if (/^#[0-9a-fA-F]{6}$/.test(val)) {
    document.getElementById('color-picker').value = val;
    document.getElementById('color-preview').style.background = val;
    document.documentElement.style.setProperty('--accent', val);
  }
}
// Init
syncColor(document.getElementById('color-picker').value);
</script>
<% } else { %>
<script>
// ── Slug-Autogenerierung (Neuer Artikel) ──
function autoSlug(title) {
  const umlauts = { ä:'ae', ö:'oe', ü:'ue', ß:'ss', Ä:'ae', Ö:'oe', Ü:'ue' };
  let slug = title.toLowerCase()
    .replace(/[äöüßÄÖÜ]/g, m => umlauts[m] || m)
    .replace(/[^a-z0-9\s-]/g, '')
    .trim()
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-');
  document.getElementById('new-slug').value = slug;
}
</script>
<% } %>

</body>
</html>
