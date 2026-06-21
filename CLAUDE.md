# CLAUDE.md — MyBlog

This file provides guidance to Claude Code when working in this repository.

## Project Overview

**MyBlog** is a standalone Jakarta EE WAR (deployed to Tomcat) that provides a multi-blog CMS platform. Multiple thematically independent blogs can be hosted, each with its own authors and settings. Articles are written via a block-based editor (EditorJS) — no HTML/CSS knowledge required for authors.

Developed by E. Athanassiou. UI language: German. Commit style: `DD.M.YYYY VX.Y: <change list>`.

## Build & Deploy

- Build: `./mvnw clean package` → `target/MyBlog.war`
- Deploy: drop WAR into Tomcat `webapps/`
- Java: source/target 17 (Jakarta EE 10)
- Context root: `/MyBlog`

## Architecture Plan

### URL Structure
```
/MyBlog/                           Platform-Home (all public blogs)
/MyBlog/login                      Login
/MyBlog/{blog-slug}/               Blog index page
/MyBlog/{blog-slug}/{article-slug} Article view
/MyBlog/dashboard/                 My blogs (after login)
/MyBlog/dashboard/{blog-slug}/     Article list for this blog
/MyBlog/dashboard/{blog-slug}/new  New article (editor)
/MyBlog/dashboard/{blog-slug}/{id} Edit article
/MyBlog/admin/                     Platform admin
/MyBlog/api/*                      JSON API for EditorJS
/MyBlog/upload                     Image upload
```

### Servlet Architecture
```
BlogPlatformServlet   /MyBlog/
BlogServlet           /MyBlog/{slug}/*
DashboardServlet      /MyBlog/dashboard/*
ApiServlet            /MyBlog/api/*
UploadServlet         /MyBlog/upload
AdminServlet          /MyBlog/admin/*
```

### Service Layer
```
BlogService       CRUD blogs, membership management
ArticleService    CRUD articles + blocks
BlockRenderer     EditorJS JSON → HTML (core rendering logic)
UserService       Auth, session, role checks
CommentService    CRUD comments
```

## Database Schema (PostgreSQL)

Database: `myblog_db` at `jdbc:postgresql://localhost:5432/myblog_db`

```sql
users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(100),
    email VARCHAR(200) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT NOW()
)

blogs (
    id SERIAL PRIMARY KEY,
    slug VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    default_accent_color VARCHAR(7) DEFAULT '#e5a00d',
    cover_image VARCHAR(500),
    visibility VARCHAR(20) DEFAULT 'public',  -- 'public'|'private'|'invite'
    owner_id INT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW()
)

blog_members (
    blog_id INT REFERENCES blogs(id),
    user_id INT REFERENCES users(id),
    role VARCHAR(20) NOT NULL,  -- 'owner'|'admin'|'author'|'contributor'
    PRIMARY KEY (blog_id, user_id)
)

articles (
    id SERIAL PRIMARY KEY,
    blog_id INT REFERENCES blogs(id),
    author_id INT REFERENCES users(id),
    slug VARCHAR(200) NOT NULL,
    title VARCHAR(500) NOT NULL,
    subtitle VARCHAR(500),
    accent_color VARCHAR(7),
    status VARCHAR(20) DEFAULT 'draft',  -- 'draft'|'published'
    created_at TIMESTAMP DEFAULT NOW(),
    published_at TIMESTAMP,
    UNIQUE (blog_id, slug)
)

blocks (
    id SERIAL PRIMARY KEY,
    article_id INT REFERENCES articles(id) ON DELETE CASCADE,
    position INT NOT NULL,
    type VARCHAR(50) NOT NULL,
    data JSONB NOT NULL
)

comments (
    id SERIAL PRIMARY KEY,
    article_id INT REFERENCES articles(id) ON DELETE CASCADE,
    author_id INT REFERENCES users(id),
    parent_id INT REFERENCES comments(id),
    body TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
)

tags (id SERIAL PRIMARY KEY, blog_id INT REFERENCES blogs(id), name VARCHAR(100))
article_tags (article_id INT, tag_id INT, PRIMARY KEY (article_id, tag_id))
```

## Block Types (EditorJS → BlockRenderer)

The `BlockRenderer` converts EditorJS JSON blocks to HTML using the design system below.

| EditorJS type | HTML output |
|---------------|-------------|
| `paragraph`   | `<p>` |
| `header`      | `<h3 id="sN">` with TOC entry (level 2), `<h4>` (level 3, no TOC) |
| `image`       | `<div style="text-align:center; margin:20px 0"><img ...></div>` |
| `imagePair`   | `<div class="img-row"><img><img></div>` (custom block) |
| `list`        | `<ul>` or `<ol>` |
| `code`        | `<pre><code>` |
| `quote`       | `<blockquote>` |
| `delimiter`   | `<hr>` |
| `pdfLink`     | `<a class="pdf-link">` with thumbnail + title (custom block) |
| `timeline`    | `<div class="timeline">` (custom block) |
| `infobox`     | `<div class="infobox">` with icon + accent border (custom block) |

TOC is auto-generated from all `header` blocks with level 2.

## Design System (Blog Article Template)

All articles share this CSS variable system. Copy from the reference template at `/Users/eathanassiou/myWWW/BlogEA/21_maven/maven.html`.

### CSS Variables
```css
:root {
    --accent:      #e5a00d;           /* per-article, set from articles.accent_color */
    --accent-dim:  rgba(229,160,13,.10);
    --sidebar-bg:  #f2f2f2;
    --sidebar-border: #e0e0e0;
    --body-bg:     #ffffff;
    --content-bg:  #ffffff;
    --text:        #1a1a1a;
    --muted:       #777;
    --border:      #e8e8e8;
}
.grey-mode {
    --body-bg: #ddd; --content-bg: #e8e8e8;
    --sidebar-bg: #d4d4d4; --sidebar-border: #bbb; --border: #ccc;
}
```

### Layout
- `body`: Raleway font, white background
- `.layout`: flex row — sidebar (210px sticky) + main content
- `nav`: sticky, 100vh, collapses to 44px via `nav.collapsed`
- `main`: `padding: 52px 64px 80px`

### Key Component Patterns

**Section heading (h3) with accent divider:**
```css
h3 { display: flex; align-items: center; gap: 12px; font-size: 20px; font-weight: 700; margin: 40px 0 18px; }
h3::after { content: ''; flex: 1; height: 2px; background: var(--accent); }
```

**Title row with circular nav arrows:**
```html
<div class="title-row">
    <a class="title-nav" href="PREV_URL" title="PREV_TITLE">‹</a>
    <h1>Article Title</h1>
    <a class="title-nav" href="NEXT_URL" title="NEXT_TITLE">›</a>
</div>
```
```css
.title-nav { width:34px; height:34px; border-radius:50%; border:1.5px solid var(--border);
    display:inline-flex; align-items:center; justify-content:center; font-size:18px; color:var(--muted); }
.title-nav:hover { color:var(--accent); border-color:var(--accent); background:var(--accent-dim); }
```

**Footer navigation (article-nav):**
```html
<div class="article-nav">
    <a href="PREV"><span class="nav-circle">‹</span>Prev Title</a>
    <a class="home" href="/BlogEA/index.html">⌂ Blog</a>
    <a href="NEXT">Next Title<span class="nav-circle">›</span></a>
</div>
```
```css
.article-nav { display:flex; justify-content:space-between; align-items:center;
    margin-top:60px; padding-top:28px; border-top:2px solid var(--accent); }
.nav-circle { width:34px; height:34px; border-radius:50%; border:1.5px solid var(--border);
    display:inline-flex; align-items:center; justify-content:center; font-size:18px; }
```

**Sidebar footer (Grey Mode + Einklappen):**
```html
<div class="nav-footer">
    <button class="footer-btn" id="grey-btn" onclick="toggleGreyMode()">
        <span class="btn-icon">◑</span><span class="btn-label">Grey Mode</span>
    </button>
    <button class="footer-btn" id="sidebar-btn" onclick="toggleSidebar()">
        <span class="btn-icon" id="sidebar-icon">‹</span>
        <span class="btn-label" id="sidebar-label">Einklappen</span>
    </button>
</div>
```

**Image pair:**
```html
<div class="img-row">
    <img src="..." alt="...">
    <img src="..." alt="...">
</div>
```
```css
.img-row { display:flex; gap:16px; margin:20px 0 6px; flex-wrap:wrap; }
.img-row img { flex:1; min-width:0; width:0; border-radius:4px; }
```

**PDF link block:**
```html
<a class="pdf-link" href="FILE.pdf" target="_blank">
    <img src="THUMB.png" style="width:56px">
    <div>
        <div class="pdf-link-text">Titel</div>
        <div class="pdf-link-sub">PDF · Beschreibung</div>
    </div>
</a>
```
```css
.pdf-link { display:flex; align-items:center; gap:18px; background:#f4f7fc;
    border:1px solid var(--border); border-left:3px solid var(--accent);
    border-radius:3px; padding:16px 20px; text-decoration:none; }
```

**Sidebar JS (Grey Mode + Collapse):**
```javascript
function toggleGreyMode() {
    document.body.classList.toggle('grey-mode');
    document.getElementById('grey-btn').classList.toggle('active');
}
function toggleSidebar() {
    const nav = document.querySelector('nav');
    nav.classList.toggle('collapsed');
    const collapsed = nav.classList.contains('collapsed');
    document.getElementById('sidebar-icon').textContent  = collapsed ? '›' : '‹';
    document.getElementById('sidebar-label').textContent = collapsed ? 'Ausklappen' : 'Einklappen';
}
```

**TOC scroll-spy (IntersectionObserver):**
```javascript
const sections = document.querySelectorAll('h3[id]');
const links    = document.querySelectorAll('nav a.toc-link');
const observer = new IntersectionObserver(entries => {
    entries.forEach(e => {
        if (e.isIntersecting) {
            links.forEach(l => l.classList.remove('active'));
            const a = document.querySelector(`nav a[href="#${e.target.id}"]`);
            if (a) a.classList.add('active');
        }
    });
}, { rootMargin: '-10% 0px -75% 0px' });
sections.forEach(s => observer.observe(s));
```

## Existing Blog Reference

The 26 existing articles in `/Users/eathanassiou/myWWW/BlogEA/` are the design reference and will be migrated into MyBlog in a later stage. The blog slug for this existing content will be `ea-blog`. See `/Users/eathanassiou/myWWW/BlogEA/21_maven/maven.html` as the canonical template example.

## Accent Color Palette (existing articles)

Each article has its own accent. When creating new articles, the author picks from a color picker. Reference palette from the existing 26 articles:
- Gold `#e5a00d` (articles 25, 26)
- Medium blue `#2272c3` (article 21)
- Bright blue `#3b82f6`, Royal `#1d4ed8`, Steel `#0369a1`, Sky `#0ea5e9`, Indigo `#4f46e5`
- Green `#16a34a`, Emerald `#059669`, Forest `#15803d`
- Teal `#0891b2`, Dark teal `#0e7490`, Cyan `#06b6d4`
- Orange `#ea580c`, Amber `#d97706`, Rust `#c2410c`, Brown `#92400e`
- Red `#dc2626`, Crimson `#be123c`
- Purple `#7c3aed`, Slate `#475569`, Stone `#78716c`

## Build Stages

```
Stufe 1  Single Blog, Single Author  ← START HERE
Stufe 2  Multi-User + Rollen pro Blog
Stufe 3  Multi-Blog (blogs-Tabelle)
Stufe 4  Reiche Blöcke (Timeline, Infobox, Custom)
Stufe 5  Kommentare (Twitter-Style)
Stufe 6  Discovery (Suche, Tags, RSS)
```
