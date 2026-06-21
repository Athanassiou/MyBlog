package de.myblog.util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import javax.naming.Context;
import javax.naming.InitialContext;

import java.sql.Connection;
import java.sql.SQLException;

public final class DB {

    private static volatile HikariDataSource pool;

    private DB() {}

    public static Connection get() throws SQLException {
        if (pool == null) {
            synchronized (DB.class) {
                if (pool == null) {
                    try {
                        // Treiber explizit laden — nötig wenn HikariCP ihn im WAR-Classloader nicht findet
                        Class.forName("org.postgresql.Driver");
                    } catch (ClassNotFoundException e) {
                        throw new SQLException("PostgreSQL-Treiber nicht gefunden", e);
                    }
                    HikariConfig cfg = new HikariConfig();
                    cfg.setJdbcUrl(getDbUrl());
                    cfg.setMaximumPoolSize(10);
                    cfg.setMinimumIdle(2);
                    pool = new HikariDataSource(cfg);
                }
            }
        }
        return pool.getConnection();
    }

    private static String getDbUrl() {
        try {
            Context envCtx = (Context) new InitialContext().lookup("java:comp/env");
            return (String) envCtx.lookup("DB_URL");
        } catch (Exception e) {
            throw new RuntimeException("JNDI-Eintrag DB_URL nicht gefunden", e);
        }
    }
}
