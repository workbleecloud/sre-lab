import json
import os
from http.server import HTTPServer, BaseHTTPRequestHandler

SERVICE_NAME = "sre-lab-api"
SERVICE_VERSION = "1.0.0"
PORT = int(os.getenv("PORT", "8000"))


class RequestHandler(BaseHTTPRequestHandler):
    def send_json_response(self, status_code, data):
        self.send_response(status_code)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write((json.dumps(data) + "\n").encode())

    def do_GET(self):
        if self.path == "/":
            response = {
                "service": SERVICE_NAME,
                "version": SERVICE_VERSION,
                "status": "running"
            }
            self.send_json_response(200, response)

        elif self.path == "/health":
            response = {
                "status": "healthy"
            }
            self.send_json_response(200, response)

        else:
            response = {
                "error": "Not Found"
            }
            self.send_json_response(404, response)


def main():
    print("SRE Python service starting")
    print(f"Service: {SERVICE_NAME}")
    print(f"Version: {SERVICE_VERSION}")
    print(f"Port: {PORT}")

    server = HTTPServer(("0.0.0.0", PORT), RequestHandler)
    server.serve_forever()


if __name__ == "__main__":
    main()
