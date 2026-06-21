package de.myblog.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.*;
import java.nio.file.Files;

/**
 * Liefert hochgeladene Bilder aus ~/myblog-uploads/ aus.
 * URL-Schema: /MyBlog/files/{uuid}.{ext}
 */
public class FilesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String info = req.getPathInfo();   // "/{uuid}.jpg"
        if (info == null || info.equals("/") || info.contains("..")) {
            resp.sendError(404);
            return;
        }

        File file = new File(UploadServlet.UPLOAD_DIR + info.substring(1));
        if (!file.exists() || !file.isFile()) {
            resp.sendError(404);
            return;
        }

        String mime = Files.probeContentType(file.toPath());
        if (mime == null) mime = "application/octet-stream";
        resp.setContentType(mime);
        resp.setContentLengthLong(file.length());
        resp.setHeader("Cache-Control", "max-age=31536000");

        try (InputStream in = new FileInputStream(file);
             OutputStream out = resp.getOutputStream()) {
            in.transferTo(out);
        }
    }
}
