#!/usr/bin/env python3
"""Serve the Godot web build locally with the COOP/COEP headers required for SharedArrayBuffer."""

import http.server
import webbrowser
import argparse
import os
import subprocess
import shutil

REPO_ROOT = os.path.dirname(os.path.abspath(__file__))
BUILDS_DIR = os.path.join(REPO_ROOT, "builds", "web")
GAME_DIR = os.path.join(REPO_ROOT, "game")

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=BUILDS_DIR, **kwargs)

    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        super().end_headers()

    def log_message(self, format, *args):
        pass  # suppress per-request noise


def find_godot():
    """Find Godot executable."""
    if shutil.which("godot"):
        return "godot"
    home = os.path.expanduser("~")
    local = os.path.join(home, "bin", "godot.exe")
    if os.path.isfile(local):
        return local
    return None


def export_web(godot_path):
    """Re-export the web build."""
    os.makedirs(BUILDS_DIR, exist_ok=True)
    output = os.path.join(BUILDS_DIR, "index.html")
    print("Exporting web build...")
    result = subprocess.run(
        [godot_path, "--headless", "--path", GAME_DIR, "--export-release", "Web", output],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"Export failed (exit {result.returncode})")
        if result.stderr:
            print(result.stderr[-500:])
        return False
    print("Web build exported.")
    return True


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Serve the Godot web build locally.")
    parser.add_argument("--port", type=int, default=8080)
    parser.add_argument("--no-browser", action="store_true", help="Don't open the browser automatically.")
    parser.add_argument("--no-export", action="store_true", help="Skip re-exporting, serve existing build.")
    parser.add_argument("--godot", type=str, default=None, help="Path to Godot executable.")
    args = parser.parse_args()

    if not args.no_export:
        godot = args.godot or find_godot()
        if godot:
            export_web(godot)
        else:
            print("Godot not found, serving existing build. Pass --godot or add to PATH.")

    if not os.path.isfile(os.path.join(BUILDS_DIR, "index.html")):
        print(f"No web build found at {BUILDS_DIR}. Run with Godot available or export manually.")
        raise SystemExit(1)

    url = f"http://localhost:{args.port}"
    print(f"Serving builds/web/ at {url}  (Ctrl+C to stop)")

    if not args.no_browser:
        webbrowser.open(url)

    with http.server.HTTPServer(("", args.port), Handler) as srv:
        try:
            srv.serve_forever()
        except KeyboardInterrupt:
            print("\nStopped.")
