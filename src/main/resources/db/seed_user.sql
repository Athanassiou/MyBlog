-- Setzt das Passwort des Admin-Benutzers via pgcrypto (bcrypt, cost 12).
-- Einmalig ausführen – danach kann der Hash in users geändert werden.
--
-- Aufruf: psql -U postgres -d myblog_db -f seed_user.sql

UPDATE users
SET password_hash = crypt('admin123', gen_salt('bf', 12))
WHERE username = 'admin';
