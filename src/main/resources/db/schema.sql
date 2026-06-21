-- MyBlog · Stufe 1 Schema
-- Datenbank: myblog_db
-- Ausführen: psql -U postgres -d myblog_db -f schema.sql

-- ─── Erweiterungen ────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ─── Tabellen ─────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS users (
    id           SERIAL PRIMARY KEY,
    username     VARCHAR(50)  UNIQUE NOT NULL,
    display_name VARCHAR(100),
    email        VARCHAR(200) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url   VARCHAR(500),
    created_at   TIMESTAMP DEFAULT NOW()
);

-- Stufe 1: eine einzelne Blog-Instanz (id=1, kein slug-Routing nötig)
CREATE TABLE IF NOT EXISTS blogs (
    id                  SERIAL PRIMARY KEY,
    slug                VARCHAR(100) UNIQUE NOT NULL,
    name                VARCHAR(200) NOT NULL,
    description         TEXT,
    default_accent_color VARCHAR(7) DEFAULT '#e5a00d',
    cover_image         VARCHAR(500),
    visibility          VARCHAR(20) DEFAULT 'public',
    owner_id            INT REFERENCES users(id),
    created_at          TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS blog_members (
    blog_id INT REFERENCES blogs(id) ON DELETE CASCADE,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    role    VARCHAR(20) NOT NULL,   -- 'owner'|'admin'|'author'|'contributor'
    PRIMARY KEY (blog_id, user_id)
);

CREATE TABLE IF NOT EXISTS articles (
    id           SERIAL PRIMARY KEY,
    blog_id      INT REFERENCES blogs(id) ON DELETE CASCADE,
    author_id    INT REFERENCES users(id),
    slug         VARCHAR(200) NOT NULL,
    title        VARCHAR(500) NOT NULL,
    subtitle     VARCHAR(500),
    accent_color VARCHAR(7),
    status       VARCHAR(20) DEFAULT 'draft',   -- 'draft'|'published'
    created_at   TIMESTAMP DEFAULT NOW(),
    published_at TIMESTAMP,
    UNIQUE (blog_id, slug)
);

CREATE TABLE IF NOT EXISTS blocks (
    id         SERIAL PRIMARY KEY,
    article_id INT REFERENCES articles(id) ON DELETE CASCADE,
    position   INT  NOT NULL,
    type       VARCHAR(50) NOT NULL,
    data       JSONB NOT NULL
);

-- Stufe 5 (Kommentare) – Tabelle schon anlegen, bleibt leer
CREATE TABLE IF NOT EXISTS comments (
    id         SERIAL PRIMARY KEY,
    article_id INT REFERENCES articles(id) ON DELETE CASCADE,
    author_id  INT REFERENCES users(id),
    parent_id  INT REFERENCES comments(id),
    body       TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Stufe 6 (Tags) – Tabellen schon anlegen, bleiben leer
CREATE TABLE IF NOT EXISTS tags (
    id      SERIAL PRIMARY KEY,
    blog_id INT REFERENCES blogs(id) ON DELETE CASCADE,
    name    VARCHAR(100) NOT NULL,
    UNIQUE (blog_id, name)
);

CREATE TABLE IF NOT EXISTS article_tags (
    article_id INT REFERENCES articles(id) ON DELETE CASCADE,
    tag_id     INT REFERENCES tags(id)     ON DELETE CASCADE,
    PRIMARY KEY (article_id, tag_id)
);

-- ─── Indizes ──────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_articles_blog_status  ON articles(blog_id, status);
CREATE INDEX IF NOT EXISTS idx_articles_published_at ON articles(published_at DESC);
CREATE INDEX IF NOT EXISTS idx_blocks_article        ON blocks(article_id, position);

-- ─── Seed-Daten (Stufe 1) ─────────────────────────────────────

-- Erster Benutzer: Passwort wird separat per seed_user.sql gesetzt
INSERT INTO users (username, display_name, email, password_hash)
VALUES ('admin', 'Administrator', 'admin@myblog.local', 'CHANGE_ME')
ON CONFLICT (username) DO NOTHING;

-- Einziger Blog in Stufe 1 (id=1)
INSERT INTO blogs (id, slug, name, description, owner_id)
VALUES (1, 'main', 'Mein Blog', 'Willkommen bei MyBlog.', 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO blog_members (blog_id, user_id, role)
VALUES (1, 1, 'owner')
ON CONFLICT DO NOTHING;
