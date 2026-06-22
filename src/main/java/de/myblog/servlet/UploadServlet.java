package de.myblog.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;
import org.json.JSONObject;

import javax.naming.Context;
import javax.naming.InitialContext;
import java.io.File;
import java.io.IOException;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,       // 1 MB — ab hier auf Disk
    maxFileSize       = 1024 * 1024 * 20,  // 20 MB pro Datei
    maxRequestSize    = 1024 * 1024 * 25   // 25 MB pro Request
)
public class UploadServlet extends HttpServlet {

    static final String UPLOAD_DIR = resolveUploadDir();

    private static String resolveUploadDir() {
        try {
            Context env = (Context) new InitialContext().lookup("java:comp/env");
            String root = (String) env.lookup("ROOT");
            if (root != null && !root.isBlank()) return root.endsWith("/") ? root : root + "/";
        } catch (Exception ignored) {}
        return System.getProperty("user.home") + "/myblog-uploads/";
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json;charset=UTF-8");

        if (req.getSession(false) == null || req.getSession(false).getAttribute("userId") == null) {
            resp.setStatus(403);
            resp.getWriter().write(new JSONObject().put("success", 0).toString());
            return;
        }

        Part part = req.getPart("image");
        if (part == null || part.getSize() == 0) {
            resp.setStatus(400);
            resp.getWriter().write(new JSONObject().put("success", 0).toString());
            return;
        }

        File dest = uniqueFile(sanitize(part.getSubmittedFileName()));
        dest.getParentFile().mkdirs();
        part.write(dest.getAbsolutePath());

        String url = req.getContextPath() + "/files/" + dest.getName();
        resp.getWriter().write(new JSONObject()
            .put("success", 1)
            .put("file", new JSONObject().put("url", url))
            .toString());
    }

    /** Originaldateiname bereinigen: nur sichere Zeichen, Leerzeichen → Unterstrich. */
    private String sanitize(String name) {
        if (name == null || name.isBlank()) return "upload.bin";
        name = new File(name).getName();                        // Pfad-Traversal verhindern
        name = name.replaceAll("[^a-zA-Z0-9._-]", "_");        // Sonderzeichen raus
        return name.toLowerCase();
    }

    /** Gibt eine Datei zurück die noch nicht existiert — bei Kollision wird -1, -2, … angehängt. */
    private File uniqueFile(String name) {
        int dot = name.lastIndexOf('.');
        String base = dot > 0 ? name.substring(0, dot) : name;
        String ext  = dot > 0 ? name.substring(dot)    : "";

        File f = new File(UPLOAD_DIR + name);
        int counter = 1;
        while (f.exists()) {
            f = new File(UPLOAD_DIR + base + "-" + counter + ext);
            counter++;
        }
        return f;
    }
}
