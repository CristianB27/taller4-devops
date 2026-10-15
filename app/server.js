const http = require("http");

const PORT = Number(process.env.PORT) || 3000;

const info = () => ({
  status: "ok",
  environment: process.env.APP_ENV || "local",
  version: process.env.APP_VERSION || "unknown", // commit SHA horneado en la imagen
  message: process.env.APP_MESSAGE || "",
  secretConfigured: Boolean(process.env.APP_SECRET), // nunca exponemos el valor
  timestamp: new Date().toISOString(),
});

const escapeHtml = (s) =>
  String(s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));

const server = http.createServer((req, res) => {
  const url = (req.url || "/").split("?")[0];

  if (url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    return res.end(JSON.stringify(info()));
  }

  if (url === "/") {
    const i = info();
    res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
    return res.end(`<!doctype html>
<html lang="es"><head><meta charset="utf-8"><title>Taller 4 - ${escapeHtml(i.environment)}</title>
<style>body{font-family:system-ui,sans-serif;max-width:640px;margin:4rem auto;padding:0 1rem}
code{background:#eee;padding:2px 6px;border-radius:4px}</style></head>
<body>
<h1>Taller 4 · ambiente: ${escapeHtml(i.environment)}</h1>
<p>${escapeHtml(i.message)}</p>
<ul>
  <li>Versión (commit): <code>${escapeHtml(i.version)}</code></li>
  <li>Secreto configurado: <code>${i.secretConfigured}</code></li>
</ul>
<p><a href="/health">/health</a></p>
</body></html>`);
  }

  res.writeHead(404, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ error: "not found" }));
});

server.listen(PORT, "0.0.0.0", () => console.log(`Escuchando en :${PORT}`));

process.on("SIGTERM", () => server.close(() => process.exit(0)));
