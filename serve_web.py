#!/usr/bin/env python3
import http.server
import socketserver
import os
import webbrowser
from urllib.parse import urlparse

# Configuration
PORT = 8080
WEB_DIR = "build/web"

class MyHttpRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        # Ensure the directory is correctly set to the web build
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def end_headers(self):
        # Add CORS headers to allow testing API calls
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()

    def do_OPTIONS(self):
        # Handle OPTIONS method for CORS preflight requests
        self.send_response(200)
        self.end_headers()

def start_server():
    # Check if the web directory exists
    if not os.path.isdir(WEB_DIR):
        print(f"Error: Directory '{WEB_DIR}' not found.")
        print("Please ensure you've built the Flutter web app with 'flutter build web'")
        return False
    
    try:
        handler = MyHttpRequestHandler
        
        # Create a TCP server
        with socketserver.TCPServer(("", PORT), handler) as httpd:
            server_url = f"http://localhost:{PORT}"
            print(f"✅ Serving EatSafe web app at: {server_url}")
            print("▶️ Opening browser automatically...")
            
            # Open the default web browser
            webbrowser.open(server_url)
            
            print("⚠️ Press Ctrl+C to stop the server")
            # Start the server
            httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
        return True
    except Exception as e:
        print(f"❌ Error starting server: {e}")
        return False

if __name__ == "__main__":
    print("🚀 Starting EatSafe Web Server")
    start_server() 