# MyAcademicWebsite

Personal website generated with Swift + Publish.

## Local preview

```bash
swift run
```

Generated output is written to `Output/`.

## GitHub Pages deployment

This repository includes a workflow at `.github/workflows/deploy-pages.yml`.

1. Push this project to a GitHub repository.
2. In GitHub: open **Settings -> Pages**.
3. Under **Build and deployment**, set **Source** to **GitHub Actions**.
4. Push to `main` to trigger deployment.

## Important

If your repository name is not `MyAcademicWebsite`, update:

- `url` in `MyAcademicWebsite/main.swift`

Use format:

`https://<github-username>.github.io/<repo-name>`
