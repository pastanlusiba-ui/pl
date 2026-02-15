#!/usr/bin/env python3
import html
import json
import subprocess
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs

HOST = "127.0.0.1"
PORT = 8099
PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_PATH = PROJECT_ROOT / "Data" / "site.json"

DEFAULT_DATA = {
    "siteName": "Pastan Lusiba",
    "tagline": "Builder focused on practical AI, automation, and web systems.",
    "baseURL": "https://pastanlusiba-ui.github.io/pl",
    "logoText": "",
    "logoPath": "pastan-logo.png",
    "profileImagePath": "profile-placeholder.svg",
    "heroHeadline": "Practical AI and Automation for Real-World Workflows",
    "heroIntro": "I design and ship systems that turn ideas into maintainable products.",
    "email": "pastanlusiba@gmail.com",
    "github": "https://github.com/pastanlusiba-ui",
    "linkedin": "",
    "location": "United States",
    "navItems": [
        {"title": "Home", "path": "/"},
        {"title": "Work", "path": "work"},
        {"title": "Training", "path": "training"},
        {"title": "Publications", "path": "publications"},
        {"title": "Presentations", "path": "presentations"},
        {"title": "Blog", "path": "blog"},
        {"title": "Connect with me", "path": "connect"},
    ],
    "highlights": [
        {
            "category": "Publications",
            "tag": "Journal Article",
            "title": "Designing practical automation systems for implementation teams",
            "summary": "Draft manuscript focused on lightweight automation models for real operational settings.",
            "path": "publications",
            "imagePath": "highlight-publication-journal.svg",
        },
        {
            "category": "Blog",
            "tag": "Insight Post",
            "title": "What I learned building an auto-updating personal website",
            "summary": "A walkthrough of content architecture, deployment, and practical maintenance decisions.",
            "path": "blog",
            "imagePath": "highlight-blog.svg",
        },
        {
            "category": "Training",
            "tag": "Workshop",
            "title": "Applied workflow automation for small implementation teams",
            "summary": "Hands-on workshop design for building repeatable systems with immediate operational value.",
            "path": "training",
            "imagePath": "highlight-training.svg",
        },
    ],
}


def load_data():
    if not DATA_PATH.exists():
        return DEFAULT_DATA.copy()

    with DATA_PATH.open("r", encoding="utf-8") as f:
        data = json.load(f)

    merged = DEFAULT_DATA.copy()
    merged.update(data)
    if not isinstance(merged.get("navItems"), list):
        merged["navItems"] = DEFAULT_DATA["navItems"]
    if not isinstance(merged.get("highlights"), list):
        merged["highlights"] = DEFAULT_DATA["highlights"]
    return merged


def save_data(data):
    DATA_PATH.parent.mkdir(parents=True, exist_ok=True)
    with DATA_PATH.open("w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")


def nav_items_to_text(nav_items):
    lines = []
    for item in nav_items:
        title = str(item.get("title", "")).strip()
        path = str(item.get("path", "")).strip()
        if title and path:
            lines.append(f"{title}|{path}")
    return "\n".join(lines)


def text_to_nav_items(text):
    items = []
    for raw in text.splitlines():
        line = raw.strip()
        if not line:
            continue
        if "|" not in line:
            continue
        title, path = line.split("|", 1)
        title = title.strip()
        path = path.strip()
        if title and path:
            items.append({"title": title, "path": path})

    return items or DEFAULT_DATA["navItems"]


def highlight_items_to_text(highlights):
    lines = []
    for item in highlights:
        category = str(item.get("category", "")).strip()
        tag = str(item.get("tag", "")).strip()
        title = str(item.get("title", "")).strip()
        summary = str(item.get("summary", "")).strip()
        path = str(item.get("path", "")).strip()
        image_path = str(item.get("imagePath", "")).strip()
        if category and tag and title and summary and path:
            lines.append(f"{category}|{tag}|{title}|{summary}|{path}|{image_path}")
    return "\n".join(lines)


def text_to_highlight_items(text):
    items = []
    for raw in text.splitlines():
        line = raw.strip()
        if not line:
            continue
        parts = [part.strip() for part in line.split("|")]
        if len(parts) not in [5, 6]:
            continue

        category, tag, title, summary, path = parts[:5]
        image_path = parts[5] if len(parts) == 6 else ""
        if category and tag and title and summary and path:
            items.append(
                {
                    "category": category,
                    "tag": tag,
                    "title": title,
                    "summary": summary,
                    "path": path,
                    "imagePath": image_path,
                }
            )

    return items or DEFAULT_DATA["highlights"]


def get_field(fields, key, fallback=""):
    values = fields.get(key)
    if not values:
        return fallback
    return values[0].strip()


def render_form(data, message="", build_output=""):
    def esc(value):
        return html.escape(str(value), quote=True)

    nav_text = nav_items_to_text(data.get("navItems", []))
    highlights_text = highlight_items_to_text(data.get("highlights", []))
    message_html = f'<div class="notice">{html.escape(message)}</div>' if message else ""
    output_html = (
        f"<pre>{html.escape(build_output)}</pre>" if build_output else ""
    )

    return f"""<!doctype html>
<html>
<head>
  <meta charset=\"utf-8\" />
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />
  <title>Site Editor</title>
  <style>
    body {{ font-family: system-ui, sans-serif; max-width: 920px; margin: 2rem auto; padding: 0 1rem; line-height: 1.5; }}
    h1 {{ margin-bottom: 0.25rem; }}
    p.meta {{ color: #556; margin-top: 0; }}
    form {{ display: grid; gap: 0.75rem; }}
    label {{ font-weight: 600; }}
    input, textarea {{ width: 100%; padding: 0.55rem; border: 1px solid #bcc7d3; border-radius: 8px; font: inherit; }}
    textarea {{ min-height: 110px; }}
    .grid {{ display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem; }}
    .notice {{ background: #e6f4ea; border: 1px solid #7fc38e; color: #22543d; padding: 0.75rem; border-radius: 8px; }}
    button {{ margin-top: 0.6rem; padding: 0.7rem 1rem; border: 0; border-radius: 999px; background: #0b7285; color: #fff; font-weight: 700; cursor: pointer; }}
    pre {{ white-space: pre-wrap; background: #101418; color: #d6e2ef; padding: 0.8rem; border-radius: 8px; overflow-x: auto; }}
    .help {{ color: #4a5568; font-size: 0.92rem; }}
    @media (max-width: 760px) {{ .grid {{ grid-template-columns: 1fr; }} }}
  </style>
</head>
<body>
  <h1>Website Editor</h1>
  <p class=\"meta\">Update your data, click save, and the site rebuilds automatically.</p>
  {message_html}
  <form method=\"post\" action=\"/save\">
    <div class=\"grid\">
      <div>
        <label>Site name</label>
        <input name=\"siteName\" value=\"{esc(data.get('siteName', ''))}\" />
      </div>
      <div>
        <label>Tagline</label>
        <input name=\"tagline\" value=\"{esc(data.get('tagline', ''))}\" />
      </div>
    </div>

    <div class=\"grid\">
      <div>
        <label>Base URL</label>
        <input name=\"baseURL\" value=\"{esc(data.get('baseURL', ''))}\" />
      </div>
      <div>
        <label>Location</label>
        <input name=\"location\" value=\"{esc(data.get('location', ''))}\" />
      </div>
    </div>

    <div class=\"grid\">
      <div>
        <label>Logo text</label>
        <input name=\"logoText\" value=\"{esc(data.get('logoText', ''))}\" />
      </div>
      <div>
        <label>Logo file in Resources</label>
        <input name=\"logoPath\" value=\"{esc(data.get('logoPath', ''))}\" />
      </div>
    </div>

    <div class=\"grid\">
      <div>
        <label>Profile image file in Resources</label>
        <input name=\"profileImagePath\" value=\"{esc(data.get('profileImagePath', ''))}\" />
      </div>
      <div>
        <label>Email</label>
        <input name=\"email\" value=\"{esc(data.get('email', ''))}\" />
      </div>
    </div>

    <div class=\"grid\">
      <div>
        <label>GitHub URL</label>
        <input name=\"github\" value=\"{esc(data.get('github', ''))}\" />
      </div>
      <div>
        <label>LinkedIn URL</label>
        <input name=\"linkedin\" value=\"{esc(data.get('linkedin', ''))}\" />
      </div>
    </div>

    <div>
      <label>Hero headline</label>
      <input name=\"heroHeadline\" value=\"{esc(data.get('heroHeadline', ''))}\" />
    </div>

    <div>
      <label>Hero intro</label>
      <textarea name=\"heroIntro\">{html.escape(data.get('heroIntro', ''))}</textarea>
    </div>

    <div>
      <label>Navigation items</label>
      <textarea name=\"navItemsText\">{html.escape(nav_text)}</textarea>
      <div class=\"help\">One per line using <code>Title|path</code>. Example: <code>Work|work</code>, <code>Home|/</code>.</div>
    </div>

    <div>
      <label>Highlights slider items</label>
      <textarea name=\"highlightsText\">{html.escape(highlights_text)}</textarea>
      <div class=\"help\">One per line using <code>Category|Tag|Title|Summary|path|imagePath</code>. Example: <code>Publications|Journal Article|Title|Short summary|publications|highlight-publication-journal.svg</code>.</div>
    </div>

    <button type=\"submit\">Save and rebuild website</button>
  </form>

  <p><a href=\"{esc(data.get('baseURL', ''))}\" target=\"_blank\">Open live site</a> | <a href=\"file://{PROJECT_ROOT / 'Output' / 'index.html'}\">Open local output</a></p>

  {output_html}
</body>
</html>
"""


class EditorHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path not in ["/", "/index.html"]:
            self.send_error(404)
            return

        data = load_data()
        body = render_form(data)
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.end_headers()
        self.wfile.write(body.encode("utf-8"))

    def do_POST(self):
        if self.path != "/save":
            self.send_error(404)
            return

        content_length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(content_length).decode("utf-8")
        fields = parse_qs(raw)

        data = load_data()
        for key in [
            "siteName",
            "tagline",
            "baseURL",
            "logoText",
            "logoPath",
            "profileImagePath",
            "heroHeadline",
            "heroIntro",
            "email",
            "github",
            "linkedin",
            "location",
        ]:
            data[key] = get_field(fields, key, str(data.get(key, "")))

        data["navItems"] = text_to_nav_items(get_field(fields, "navItemsText", ""))
        data["highlights"] = text_to_highlight_items(get_field(fields, "highlightsText", ""))
        save_data(data)

        result = subprocess.run(
            ["swift", "run"],
            cwd=PROJECT_ROOT,
            capture_output=True,
            text=True,
        )

        combined = (result.stdout + "\n" + result.stderr).strip()
        tail = "\n".join(combined.splitlines()[-80:])

        message = "Saved and rebuilt successfully." if result.returncode == 0 else "Saved, but rebuild failed. Check output below."
        body = render_form(data, message=message, build_output=tail)

        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.end_headers()
        self.wfile.write(body.encode("utf-8"))

    def log_message(self, fmt, *args):
        return


def main():
    server = ThreadingHTTPServer((HOST, PORT), EditorHandler)
    print(f"Editor running at http://{HOST}:{PORT}")
    server.serve_forever()


if __name__ == "__main__":
    main()
