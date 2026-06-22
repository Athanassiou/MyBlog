#!/usr/bin/env python3
"""
Migration: 26 EA Blog articles from ~/myWWW/BlogEA/
into MyBlog database as blog 'ea-blog' (Mein Entwicklertagebuch).

Usage: python3 migrate_ea_blog.py
"""

import os, re, json, shutil, psycopg2, html as html_mod
from datetime import datetime

BLOG_EA_DIR   = os.path.expanduser("~/myWWW/BlogEA")
UPLOAD_DIR    = os.path.expanduser("~/myblog-uploads")
CONTEXT_PATH  = "/MyBlog"
BLOG_SLUG     = "ea-blog"
BLOG_NAME     = "Mein Entwicklertagebuch"
BLOG_DESC     = ("Biographischer Entwicklerblog von Eleutherios Athanassiou — "
                 "Programmieren, Lernen und Erinnern.")
BLOG_ACCENT   = "#e5a00d"
AUTHOR_ID     = 2        # user 'akis'

# (dir_name, article_slug, year, month, day [, explicit_html_filename])
ARTICLES = [
    ('01_bubblesort',       'bubblesort',       2022, 11,  1),
    ('02_days2go',          'days2go',          2022, 12,  1),
    ('03_webserver',        'webserver',        2022, 12,  5),
    ('04_postgres',         'postgres',         2022, 12, 10),
    ('05_sauro',            'sauro',            2023,  1, 10),
    ('06_f1results',        'f1results',        2023,  1, 15),
    ('07_tomcat',           'tomcat',           2023,  4,  1),
    ('08_jspcode',          'jspcode',          2023,  5,  1),
    ('09_jsoup',            'jsoup',            2023,  8,  1),
    ('10_GIT',              'git',              2023,  8, 15),
    ('11_Sort-Reloaded',    'sort-reloaded',    2023, 10,  1),
    ('12_photos',           'photos',           2023,  9,  1),
    ('13_tags',             'tags',             2023, 10, 10),
    ('14_indexing',         'indexing',         2023, 10, 20),
    ('15_opencv',           'opencv',           2023, 11,  1),
    ('16_GPI',              'gpi',              2024,  2,  1),
    ('17_browser',          'browser',          2024,  2, 15),
    ('17_browser',          'browser-2',        2024,  2, 16, 'browser-2.html'),
    ('17_browser',          'browser-3',        2024,  2, 17, 'browser-3.html'),
    ('18_MediaBrowser',     'mediabrowser',     2024,  5,  1),
    ('19_ubuntu',           'ubuntu',           2024,  8,  1),
    ('20_mynetflix',        'mynetflix',        2025,  2,  1),
    ('21_maven',            'maven',            2025, 10,  1),
    ('22_nas',              'nas',              2024, 11,  1),
    ('23_https',            'https',            2025,  3,  1),
    ('24_plex',             'plex',             2025,  4,  1),
    ('25_n3theme',          'n3theme',          2026,  6,  1),
    ('26_mediabrowser-app', 'mediabrowser-app', 2026,  6, 15),
]


# ─── Utility helpers ─────────────────────────────────────────────────────────

def copy_asset(src_path, dest_dir, prefix):
    """Copy a file to dest_dir with prefix_, return new filename or None."""
    if not os.path.exists(src_path):
        print(f"    WARNUNG: Datei nicht gefunden: {src_path}")
        return None
    basename = os.path.basename(src_path)
    new_name  = f"{prefix}_{basename}"
    dest_path = os.path.join(dest_dir, new_name)
    if not os.path.exists(dest_path):
        shutil.copy2(src_path, dest_path)
    return new_name


def asset_url(filename):
    return f"{CONTEXT_PATH}/files/{BLOG_SLUG}/{filename}"


def strip_outer_tag(s):
    """Remove the outermost HTML tag, return inner HTML."""
    s = s.strip()
    m = re.match(r'^<[^>]+>(.*)</[^>]+>$', s, re.DOTALL)
    return m.group(1).strip() if m else s


def get_attr(tag_str, attr):
    """Extract attribute value from HTML tag string."""
    m = re.search(rf'\b{re.escape(attr)}="([^"]*)"', tag_str)
    return m.group(1) if m else ''


# ─── Element extractor ───────────────────────────────────────────────────────

def extract_element(html_str, pos):
    """
    Extract a complete HTML element starting at pos (must be '<').
    Returns (element_str, next_pos).
    """
    if pos >= len(html_str) or html_str[pos] != '<':
        return None, pos + 1

    tag_end = html_str.find('>', pos)
    if tag_end == -1:
        return None, pos + 1

    opening_tag = html_str[pos:tag_end + 1]

    # Self-closing by tag name
    tag_name_m = re.match(r'<(\w+)', opening_tag)
    if not tag_name_m:
        return None, tag_end + 1
    tag_name = tag_name_m.group(1).lower()

    void_tags = {'img', 'hr', 'br', 'input', 'meta', 'link', 'area',
                 'base', 'col', 'embed', 'param', 'source', 'track', 'wbr'}
    if tag_name in void_tags or opening_tag.endswith('/>'):
        return opening_tag, tag_end + 1

    # Find matching closing tag (depth-tracking)
    depth = 1
    search_pos = tag_end + 1
    open_re  = re.compile(rf'<{re.escape(tag_name)}[\s>/]', re.IGNORECASE)
    close_re = re.compile(rf'</{re.escape(tag_name)}\s*>', re.IGNORECASE)

    while depth > 0 and search_pos < len(html_str):
        rest = html_str[search_pos:]
        m_open  = open_re.search(rest)
        m_close = close_re.search(rest)

        if m_close is None:
            return html_str[pos:], len(html_str)

        if m_open and m_open.start() < m_close.start():
            depth += 1
            search_pos += m_open.end()
        else:
            depth -= 1
            search_pos += m_close.end()

    return html_str[pos:search_pos], search_pos


# ─── Section removal ─────────────────────────────────────────────────────────

def remove_section(html_str, class_name):
    """Remove first <div class="class_name">...</div> block."""
    needle = f'<div class="{class_name}"'
    start = html_str.find(needle)
    if start == -1:
        return html_str
    _, end_pos = extract_element(html_str, start)
    return html_str[:start] + html_str[end_pos:]


# ─── Block parsers ───────────────────────────────────────────────────────────

def parse_image_src(src, source_dir, article_slug, dest_dir):
    """Resolve image src to a /MyBlog/files/... URL, copying file if local."""
    if not src:
        return ''
    if src.startswith('/') and not src.startswith('/BlogEA'):
        return src          # already absolute non-BlogEA URL
    if src.startswith('./') or not src.startswith('/'):
        local = os.path.join(source_dir, src.lstrip('./'))
        fname = copy_asset(local, dest_dir, article_slug)
        return asset_url(fname) if fname else ''
    # /BlogEA/... path — resolve relative to BlogEA root
    rel = src.replace('/BlogEA/', '', 1)
    local = os.path.join(BLOG_EA_DIR, rel)
    fname = copy_asset(local, dest_dir, article_slug)
    return asset_url(fname) if fname else src


def parse_div(elem, source_dir, article_slug, dest_dir):
    """Convert a <div> element to zero or more blocks."""
    inner = strip_outer_tag(elem)

    # img-row → imagePair
    if 'class="img-row"' in elem:
        imgs = re.findall(r'<img\b([^>]*?)/?>', inner, re.IGNORECASE)
        urls, alts = [], []
        for img_attrs in imgs:
            src = get_attr('<img ' + img_attrs + '>', 'src')
            alt = get_attr('<img ' + img_attrs + '>', 'alt')
            url = parse_image_src(src, source_dir, article_slug, dest_dir)
            if url:
                urls.append(url)
                alts.append(alt)
        if len(urls) >= 2:
            return [{'type': 'imagePair', 'data': {
                'left':  {'url': urls[0], 'alt': alts[0]},
                'right': {'url': urls[1], 'alt': alts[1]},
            }}]
        if len(urls) == 1:
            return [{'type': 'image', 'data': {'file': {'url': urls[0]}, 'caption': alts[0]}}]
        return []

    # text-align:center with <img> → single image block(s)
    if 'text-align:center' in elem or 'text-align: center' in elem:
        imgs = re.findall(r'<img\b([^>]*?)/?>', inner, re.IGNORECASE)
        blocks = []
        for img_attrs in imgs:
            src = get_attr('<img ' + img_attrs + '>', 'src')
            alt = get_attr('<img ' + img_attrs + '>', 'alt')
            url = parse_image_src(src, source_dir, article_slug, dest_dir)
            if url:
                blocks.append({'type': 'image', 'data': {'file': {'url': url}, 'caption': alt}})
        return blocks

    # feature-row → header+paragraph per feature-box
    if 'feature-row' in elem:
        blocks = []
        # Simple non-greedy match works because feature-box has no nested divs
        boxes = re.findall(r'<div class="feature-box">(.*?)</div>', inner, re.DOTALL)
        for box in boxes:
            h4 = re.search(r'<h4[^>]*>(.*?)</h4>', box, re.DOTALL)
            p  = re.search(r'<p[^>]*>(.*?)</p>',   box, re.DOTALL)
            if h4:
                txt = html_mod.unescape(re.sub(r'<[^>]+>', '', h4.group(1))).strip()
                blocks.append({'type': 'header', 'data': {'text': txt, 'level': 3}})
            if p:
                blocks.append({'type': 'paragraph', 'data': {'text': p.group(1).strip()}})
        return blocks

    # skip remaining known-navigation divs silently
    skip_classes = ['article-topline', 'title-row', 'article-nav', 'article-meta',
                    'nav-footer', 'nav-section']
    for sc in skip_classes:
        if f'class="{sc}"' in elem:
            return []

    # Unknown div — emit as paragraph if there is text
    text = re.sub(r'<[^>]+>', '', inner).strip()
    if text:
        return [{'type': 'paragraph', 'data': {'text': html_mod.unescape(text)}}]
    return []


def parse_pdf_link(elem, source_dir, article_slug, dest_dir):
    """Convert <a class="pdf-link"> to a pdfLink block."""
    href = get_attr(elem, 'href')

    # Resolve PDF path
    if href.startswith('/BlogEA/JSPDoc/'):
        pdf_basename = os.path.basename(href)
        pdf_src = os.path.join(BLOG_EA_DIR, 'JSPDoc', pdf_basename)
        fname = copy_asset(pdf_src, dest_dir, article_slug)
        href = asset_url(fname) if fname else href
    elif href.startswith('./') or not href.startswith('/'):
        pdf_src = os.path.join(source_dir, href.lstrip('./'))
        fname = copy_asset(pdf_src, dest_dir, article_slug)
        href = asset_url(fname) if fname else href

    # Thumbnail
    thumb_m = re.search(r'<img\b([^>]*?)/?>', elem, re.IGNORECASE)
    thumb_url = ''
    if thumb_m:
        src = get_attr('<img ' + thumb_m.group(1) + '>', 'src')
        thumb_url = parse_image_src(src, source_dir, article_slug, dest_dir)

    title_m = re.search(r'class="pdf-link-text"[^>]*>(.*?)<', elem, re.DOTALL)
    desc_m  = re.search(r'class="pdf-link-sub"[^>]*>(.*?)<',  elem, re.DOTALL)
    title = html_mod.unescape(re.sub(r'<[^>]+>', '', title_m.group(1)).strip()) if title_m else ''
    desc  = html_mod.unescape(re.sub(r'<[^>]+>', '', desc_m.group(1)).strip())  if desc_m  else ''

    return [{'type': 'pdfLink', 'data': {
        'url': href, 'title': title, 'description': desc, 'thumb': thumb_url,
    }}]


def parse_list(elem, style):
    """Convert <ul>/<ol> to a list block, preserving inline HTML in items."""
    inner = strip_outer_tag(elem)
    items = re.findall(r'<li[^>]*>(.*?)</li>', inner, re.DOTALL)
    items = [i.strip() for i in items if i.strip()]
    if not items:
        return []
    return [{'type': 'list', 'data': {'style': style, 'items': items}}]


# ─── Main content parser ─────────────────────────────────────────────────────

def parse_blocks(html_content, source_dir, article_slug, dest_dir):
    """Extract list of EditorJS block dicts from the article HTML."""

    m = re.search(r'<main\b[^>]*>(.*?)</main>', html_content, re.DOTALL | re.IGNORECASE)
    if not m:
        return []
    content = m.group(1)

    # Remove navigation/meta sections
    for cls in ('article-topline', 'title-row', 'article-nav'):
        content = remove_section(content, cls)

    # Remove subtitle (already extracted separately)
    content = re.sub(r'<p\s+class="subtitle"[^>]*>.*?</p>', '', content, flags=re.DOTALL)

    blocks = []
    pos = 0

    while pos < len(content):
        # Skip whitespace
        rest = content[pos:]
        stripped = rest.lstrip()
        if not stripped:
            break
        pos += len(rest) - len(stripped)

        # Skip HTML comments
        if content[pos:pos+4] == '<!--':
            end = content.find('-->', pos)
            pos = end + 3 if end != -1 else len(content)
            continue

        if content[pos] != '<':
            # Bare text — skip to next tag
            next_lt = content.find('<', pos)
            pos = next_lt if next_lt != -1 else len(content)
            continue

        # Peek at tag name + attrs
        peek = re.match(r'<(/?\w+)([^>]*?)(/?)>', content[pos:], re.DOTALL)
        if not peek:
            pos += 1
            continue

        tag_name  = peek.group(1).lower()
        tag_attrs = peek.group(2)

        # Closing tags at top level — skip
        if tag_name.startswith('/'):
            pos += len(peek.group(0))
            continue

        # Extract full element
        elem, new_pos = extract_element(content, pos)
        pos = new_pos

        if elem is None:
            continue

        # ── Dispatch by tag name ──────────────────────────────

        if tag_name == 'h3':
            inner = re.sub(r'<[^>]+>', '', strip_outer_tag(elem)).strip()
            blocks.append({'type': 'header', 'data': {'text': html_mod.unescape(inner), 'level': 2}})

        elif tag_name == 'h4':
            inner = re.sub(r'<[^>]+>', '', strip_outer_tag(elem)).strip()
            blocks.append({'type': 'header', 'data': {'text': html_mod.unescape(inner), 'level': 3}})

        elif tag_name == 'hr':
            blocks.append({'type': 'delimiter', 'data': {}})

        elif tag_name == 'p':
            if 'class="subtitle"' in tag_attrs:
                continue
            inner = strip_outer_tag(elem).strip()
            if inner:
                blocks.append({'type': 'paragraph', 'data': {'text': inner}})

        elif tag_name == 'pre':
            code_inner = strip_outer_tag(elem)
            code_inner = re.sub(r'</?code[^>]*>', '', code_inner)
            code_inner = html_mod.unescape(code_inner)
            blocks.append({'type': 'code', 'data': {'code': code_inner}})

        elif tag_name == 'ul':
            blocks.extend(parse_list(elem, 'unordered'))

        elif tag_name == 'ol':
            blocks.extend(parse_list(elem, 'ordered'))

        elif tag_name == 'img':
            src = get_attr(elem, 'src')
            alt = get_attr(elem, 'alt')
            url = parse_image_src(src, source_dir, article_slug, dest_dir)
            if url:
                blocks.append({'type': 'image', 'data': {'file': {'url': url}, 'caption': alt}})

        elif tag_name == 'div':
            blocks.extend(parse_div(elem, source_dir, article_slug, dest_dir))

        elif tag_name == 'a':
            full_open = f'<{tag_name}{tag_attrs}>'
            if 'class="pdf-link"' in full_open or 'class="pdf-link"' in elem[:100]:
                blocks.extend(parse_pdf_link(elem, source_dir, article_slug, dest_dir))
            # else: standalone <a> at top level — ignore (not a content block)

        # script, style, nav, etc. — silently skip

    return blocks


# ─── Article meta extraction ─────────────────────────────────────────────────

def parse_article_meta(html_content):
    """Return (title, subtitle, date_str, accent_color) from article HTML."""
    accent_m = re.search(r'--accent:\s*([#\w]+)\s*;', html_content)
    accent   = accent_m.group(1).strip() if accent_m else BLOG_ACCENT

    date_m   = re.search(r'class="article-meta"[^>]*>\s*<span>(.*?)</span>',
                          html_content, re.DOTALL)
    date_str = date_m.group(1).strip() if date_m else None

    # Title from <div class="title-row"><h1>...</h1></div>
    title_m = re.search(r'<div class="title-row"[^>]*>.*?<h1[^>]*>(.*?)</h1>',
                         html_content, re.DOTALL)
    if not title_m:
        title_m = re.search(r'<h1[^>]*>(.*?)</h1>', html_content, re.DOTALL)
    title = html_mod.unescape(re.sub(r'<[^>]+>', '', title_m.group(1))).strip() \
            if title_m else None

    sub_m    = re.search(r'<p\s+class="subtitle"[^>]*>(.*?)</p>', html_content, re.DOTALL)
    subtitle = html_mod.unescape(re.sub(r'<[^>]+>', '', sub_m.group(1))).strip() \
               if sub_m else None

    return title, subtitle, date_str, accent


# ─── Main ────────────────────────────────────────────────────────────────────

def main():
    conn = psycopg2.connect(dbname='myblog_db', host='localhost', port=5432)
    conn.autocommit = False
    cur = conn.cursor()

    # Ensure upload subdirectory exists
    ea_upload_dir = os.path.join(UPLOAD_DIR, BLOG_SLUG)
    os.makedirs(ea_upload_dir, exist_ok=True)
    print(f"Upload-Verzeichnis: {ea_upload_dir}")

    # Create or find blog
    cur.execute("SELECT id FROM blogs WHERE slug=%s", (BLOG_SLUG,))
    row = cur.fetchone()
    if row:
        blog_id = row[0]
        print(f"Blog '{BLOG_SLUG}' existiert bereits (id={blog_id})")
    else:
        cur.execute(
            "INSERT INTO blogs (slug, name, description, default_accent_color, visibility, owner_id) "
            "VALUES (%s,%s,%s,%s,'public',%s) RETURNING id",
            (BLOG_SLUG, BLOG_NAME, BLOG_DESC, BLOG_ACCENT, AUTHOR_ID)
        )
        blog_id = cur.fetchone()[0]
        cur.execute(
            "INSERT INTO blog_members (blog_id, user_id, role) VALUES (%s,%s,'owner') "
            "ON CONFLICT DO NOTHING",
            (blog_id, AUTHOR_ID)
        )
        print(f"Blog '{BLOG_SLUG}' angelegt (id={blog_id})")

    # Migrate articles
    total_articles = 0
    total_blocks   = 0

    for entry in ARTICLES:
        dir_name, article_slug, year, month, day = entry[:5]
        explicit_html = entry[5] if len(entry) > 5 else None

        article_dir = os.path.join(BLOG_EA_DIR, dir_name)
        if not os.path.isdir(article_dir):
            print(f"  SKIP {dir_name}: Verzeichnis nicht gefunden")
            continue

        if explicit_html:
            html_file = os.path.join(article_dir, explicit_html)
            if not os.path.exists(html_file):
                print(f"  SKIP {dir_name}/{explicit_html}: Datei nicht gefunden")
                continue
        else:
            # Find the main article HTML file: must contain article-topline
            html_files = [f for f in os.listdir(article_dir) if f.endswith('.html')]
            html_file = None
            for hf in sorted(html_files):
                candidate = os.path.join(article_dir, hf)
                with open(candidate, encoding='utf-8', errors='ignore') as f:
                    sample = f.read(4096)
                if 'article-topline' in sample:
                    html_file = candidate
                    break
            if html_file is None:
                print(f"  SKIP {dir_name}: kein HTML mit article-topline")
                continue
        with open(html_file, encoding='utf-8') as f:
            html_content = f.read()

        title, subtitle, date_str, accent = parse_article_meta(html_content)
        pub_date = datetime(year, month, day, 12, 0, 0)

        print(f"\n  [{dir_name}]")
        print(f"    Titel:    {title!r}")
        print(f"    Datum:    {date_str!r} → {pub_date.date()}")
        print(f"    Akzent:   {accent}")

        # Skip if already migrated
        cur.execute("SELECT id FROM articles WHERE blog_id=%s AND slug=%s", (blog_id, article_slug))
        if cur.fetchone():
            print(f"    → bereits vorhanden, überspringe")
            continue

        # Parse blocks
        blocks = parse_blocks(html_content, article_dir, article_slug, ea_upload_dir)
        print(f"    → {len(blocks)} Blöcke")
        for b in blocks:
            print(f"       {b['type']}", end='')
            if b['type'] == 'header':
                print(f"  h{b['data']['level']}: {b['data']['text'][:50]!r}", end='')
            elif b['type'] == 'paragraph':
                txt = re.sub(r'<[^>]+>', '', b['data']['text'])[:50]
                print(f"  {txt!r}", end='')
            elif b['type'] in ('image', 'imagePair', 'pdfLink'):
                print(f"  → {list(b['data'].values())[0]}", end='')
            print()

        # Insert article
        cur.execute(
            "INSERT INTO articles "
            "(blog_id, author_id, slug, title, subtitle, accent_color, "
            "status, created_at, published_at) "
            "VALUES (%s,%s,%s,%s,%s,%s,'published',%s,%s) RETURNING id",
            (blog_id, AUTHOR_ID, article_slug,
             title or dir_name, subtitle, accent,
             pub_date, pub_date)
        )
        article_id = cur.fetchone()[0]

        # Insert blocks
        for i, block in enumerate(blocks):
            cur.execute(
                "INSERT INTO blocks (article_id, position, type, data) VALUES (%s,%s,%s,%s)",
                (article_id, i, block['type'],
                 json.dumps(block['data'], ensure_ascii=False))
            )

        total_articles += 1
        total_blocks   += len(blocks)

    conn.commit()
    cur.close()
    conn.close()

    print(f"\n{'='*50}")
    print(f"Migration abgeschlossen: {total_articles} Artikel, {total_blocks} Blöcke")


if __name__ == '__main__':
    main()
