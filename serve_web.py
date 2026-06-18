#!/usr/bin/env python3
"""Serve the Godot web build locally with the COOP/COEP headers required for SharedArrayBuffer."""

import http.server
import webbrowser
import argparse
import os

BUILDS_DIR = os.path.join(os.path.dirname(__file__), "builds", "web")

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=BUILDS_DIR, **kwargs)

    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        super().end_headers()

    def log_message(self, format, *args):
        pass  # suppress per-request noise


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Serve the Godot web build locally.")
    parser.add_argument("--port", type=int, default=8080)
    parser.add_argument("--no-browser", action="store_true", help="Don't open the browser automatically.")
    args = parser.parse_args()

    url = f"http://localhost:{args.port}"
    print(f"Serving builds/web/ at {url}  (Ctrl+C to stop)")

    if not args.no_browser:
        webbrowser.open(url)

    with http.server.HTTPServer(("", args.port), Handler) as srv:
        try:
            srv.serve_forever()
        except KeyboardInterrupt:
            print("\nStopped.")
