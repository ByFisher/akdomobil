from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from urllib.error import HTTPError
from urllib.request import Request, urlopen
import json
import html
import hmac
import hashlib
import time
from pathlib import Path


WEB_ROOT = Path(__file__).resolve().parent / "build" / "web"
API_ORIGIN = "http://localhost:3000"
AKDO_ROOT = Path(r"C:\Users\PC\Desktop\laravel\akdo")


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(WEB_ROOT), **kwargs)

    def _admin_headers(self):
        browser_cookie = self.headers.get("Cookie")
        if browser_cookie:
            return {"Cookie": browser_cookie}
        return self._synthetic_admin_headers()

    def _synthetic_admin_headers(self):
        env = {}
        env_path = AKDO_ROOT / ".env"
        if env_path.exists():
            for raw_line in env_path.read_text(
                encoding="utf-8",
            ).splitlines():
                line = raw_line.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                key, value = line.split("=", 1)
                env[key.strip()] = value.strip().strip('"').strip("'")

        secret = env.get("ADMIN_SESSION_SECRET")
        if not secret:
            return {}
        timestamp = str(int(time.time() * 1000))
        signature = hmac.new(
            secret.encode("utf-8"),
            timestamp.encode("utf-8"),
            hashlib.sha256,
        ).hexdigest()
        return {
            "Cookie": f"akdo-admin-session={timestamp}.{signature}",
        }

    def _proxy(self):
        length = int(self.headers.get("Content-Length", "0"))
        body = self.rfile.read(length) if length else None
        headers = {}
        for name in ("Content-Type", "Cookie", "Accept"):
            value = self.headers.get(name)
            if value:
                headers[name] = value

        request = Request(
            API_ORIGIN + self.path,
            data=body,
            headers=headers,
            method=self.command,
        )
        try:
            with urlopen(request, timeout=30) as response:
                status = response.status
                data = response.read()
                response_headers = response.headers
        except HTTPError as response:
            status = response.code
            data = response.read()
            response_headers = response.headers

        self.send_response(status)
        for name in ("Content-Type", "Set-Cookie"):
            values = response_headers.get_all(name) if response_headers else None
            if not values:
                continue
            for value in values:
                self.send_header(name, value)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def _json(self, status, payload):
        data = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def _admin_list_from_page(self, page_path, key):
        headers = {}
        cookie = self.headers.get("Cookie")
        if cookie:
            headers["Cookie"] = cookie
        request = Request(API_ORIGIN + page_path, headers=headers)
        try:
            with urlopen(request, timeout=30) as response:
                source = html.unescape(response.read().decode("utf-8", "replace"))
        except HTTPError as response:
            return self._json(response.code, {"error": "AKDO yönetim verisi alınamadı."})

        normalized = source.replace('\\"', '"')
        normalized = normalized.replace("\\u0022", '"')
        normalized = normalized.replace("\\u003a", ":")
        normalized = normalized.replace("\\u005b", "[")
        normalized = normalized.replace("\\u005d", "]")

        marker = '"' + key + '":'
        search_from = 0
        while True:
            start = normalized.find(marker, search_from)
            if start < 0:
                break
            array_start = normalized.find("[", start, start + 300)
            search_from = start + len(marker)
            if array_start < 0:
                continue

            depth = 0
            in_string = False
            escaped = False
            for index in range(array_start, len(normalized)):
                char = normalized[index]
                if in_string:
                    if escaped:
                        escaped = False
                    elif char == "\\":
                        escaped = True
                    elif char == '"':
                        in_string = False
                    continue
                if char == '"':
                    in_string = True
                elif char == "[":
                    depth += 1
                elif char == "]":
                    depth -= 1
                    if depth == 0:
                        try:
                            items = json.loads(normalized[array_start:index + 1])
                            if isinstance(items, list) and items:
                                valid = all(
                                    isinstance(item, dict)
                                    and (("name" in item and "id" in item)
                                         or ("title" in item and "id" in item))
                                    for item in items
                                )
                                if valid:
                                    return self._json(200, {key: items})
                        except json.JSONDecodeError:
                            pass
                        break
        return self._json(200, {key: []})

    def _extract_json_array(self, source, key):
        marker = '"' + key + '"'
        search_from = 0
        while True:
            start = source.find(marker, search_from)
            if start < 0:
                return []
            search_from = start + len(marker)
            colon = source.find(':', start, start + 100)
            array_start = source.find('[', colon if colon >= 0 else start, start + 500)
            if array_start < 0:
                continue
            depth = 0
            in_string = False
            escaped = False
            for index in range(array_start, len(source)):
                char = source[index]
                if in_string:
                    if escaped:
                        escaped = False
                    elif char == "\\":
                        escaped = True
                    elif char == '"':
                        in_string = False
                    continue
                if char == '"':
                    in_string = True
                elif char == "[":
                    depth += 1
                elif char == "]":
                    depth -= 1
                    if depth == 0:
                        try:
                            items = json.loads(source[array_start:index + 1])
                            if isinstance(items, list):
                                return items
                        except json.JSONDecodeError:
                            pass
                        break
        return []

    def _public_menu(self):
        query = self.path.split("?", 1)[1] if "?" in self.path else ""
        page_path = "/?"+query if query else "/"
        try:
            with urlopen(Request(API_ORIGIN + page_path), timeout=30) as response:
                source = html.unescape(response.read().decode("utf-8", "replace"))
        except HTTPError as response:
            return self._json(response.code, {"error": "Müşteri menüsü alınamadı."})

        normalized = source.replace('\\"', '"')
        normalized = normalized.replace("\\u0022", '"')
        normalized = normalized.replace("\\u003a", ":")
        normalized = normalized.replace("\\u005b", "[")
        normalized = normalized.replace("\\u005d", "]")
        categories = self._extract_json_array(normalized, "categories")
        products = self._extract_json_array(normalized, "products")
        return self._json(200, {
            "categories": categories,
            "products": products,
        })

    def _cash_requests(self):
        header_options = [self._admin_headers()]
        synthetic_headers = self._synthetic_admin_headers()
        if synthetic_headers and synthetic_headers != header_options[0]:
            header_options.append(synthetic_headers)

        source = None
        last_status = 404
        for headers in header_options:
            try:
                with urlopen(
                    Request(API_ORIGIN + "/login/kasa", headers=headers),
                    timeout=30,
                ) as response:
                    source = html.unescape(
                        response.read().decode("utf-8", "replace")
                    )
                    break
            except HTTPError as response:
                last_status = response.code

        if source is None:
            return self._json(
                last_status,
                {"error": "AkdoKasa talepleri alınamadı."},
            )

        normalized = source.replace('\\"', '"')
        normalized = normalized.replace("\\u0022", '"')
        normalized = normalized.replace("\\u003a", ":")
        normalized = normalized.replace("\\u005b", "[")
        normalized = normalized.replace("\\u005d", "]")
        requests = self._extract_json_array(normalized, "pendingRequests")
        return self._json(200, {"requests": requests})

    def do_GET(self):
        if self.path.startswith("/api/"):
            if self.path.startswith("/api/public/menu"):
                self._public_menu()
            elif self.path.startswith("/api/admin/cash/requests"):
                self._cash_requests()
            elif self.path.startswith("/api/admin/categories"):
                self._admin_list_from_page("/login/categories", "categories")
            elif self.path.startswith("/api/admin/products"):
                self._admin_list_from_page("/login/menu", "products")
            else:
                self._proxy()
        elif self.path.startswith("/uploads/"):
            self._proxy()
        else:
            super().do_GET()

    def do_POST(self):
        if self.path.startswith("/api/"):
            self._proxy()
        else:
            self.send_error(404)

    def do_PATCH(self):
        if self.path.startswith("/api/"):
            self._proxy()
        else:
            self.send_error(404)

    def do_DELETE(self):
        if self.path.startswith("/api/"):
            self._proxy()
        else:
            self.send_error(404)


if __name__ == "__main__":
    ThreadingHTTPServer(("0.0.0.0", 8081), Handler).serve_forever()
