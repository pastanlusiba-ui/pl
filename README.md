# MyAcademicWebsite

Personal website generated with Swift + Publish.

## Local preview

```bash
swift run
```

Generated output is written to `Output/`.

## Built-in form editor (auto-rebuild on save)

Run:

```bash
python3 tools/site_editor.py
```

Then open [http://127.0.0.1:8099](http://127.0.0.1:8099).

On each save:

1. `Data/site.json` is updated.
2. `swift run` is executed automatically.
3. `Output/` is regenerated.

Use this for logo path, profile image path, hero text, nav links, and contact fields.

## GitHub Pages deployment

This repository includes a workflow at `.github/workflows/deploy-pages.yml`.

1. Push this project to GitHub.
2. In GitHub, open **Settings -> Pages**.
3. Under **Build and deployment**, set **Source** to **GitHub Actions**.
4. Push to `main` to trigger deployment.

## Important

If your GitHub repo name changes, update `baseURL` in `Data/site.json`:

`https://<github-username>.github.io/<repo-name>`
