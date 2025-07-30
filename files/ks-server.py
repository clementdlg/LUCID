#!/usr/bin/env python3

import http.server
import socketserver
import os

PORT = 8000
KS_FILENAME = "ks.cfg"


class KickstartHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == f"/{KS_FILENAME}":
            if os.path.exists(KS_FILENAME):
                self.send_response(200)
                self.send_header("Content-type", "text/plain")
                self.end_headers()
                with open(KS_FILENAME, "rb") as f:
                    self.wfile.write(f.read())
            else:
                self.send_error(404, f"{KS_FILENAME} not found.")
        else:
            self.send_error(404, "File not found.")


if __name__ == "__main__":
    with socketserver.TCPServer(("", PORT), KickstartHandler) as httpd:
        print(f"Serving {KS_FILENAME} on port {PORT}")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nShutting down.")
            httpd.server_close()
