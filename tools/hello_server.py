#!/usr/bin/env python3
"""Minimal HTTP server to test inbound connectivity."""
import http.server
import json
import sys

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8888

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        body = json.dumps({"status": "ok", "message": "hello from workshop", "path": self.path})
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(body.encode())

    def log_message(self, format, *args):
        print(f"[{self.log_date_time_string()}] {args[0]}")

print(f"Listening on 0.0.0.0:{PORT}")
http.server.HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
