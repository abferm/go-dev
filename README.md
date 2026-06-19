# go-dev

A container-based Go development environment that just works — no permission errors, no wrappers, no manual setup.

`docker compose up -d` and you're in a fully-equipped Go workspace where files
you create belong to *you*, not root. The same Dockerfile also produces a
minimal production image (≈11 MB on Alpine) via multi-stage build.

## Features

- **Zero-permission setup** — an entrypoint script matches the container user's
  UID/GID to your host user automatically. No build args, no Makefile, no
  `--user` flags.
- **Multi-stage Dockerfile** — a single `Dockerfile` targets `dev` (full
  toolchain, linter, git) or `production` (Alpine + binary only, ≈11 MB).
- **Pre-installed tooling** — `golangci-lint`, `gopls`, `goimports`, `golint`, `delve`, `sudo`, and `git` are ready to use.
- **VS Code Dev Containers** — `.devcontainer/devcontainer.json` connects as
  `developer` with Go and Docker extensions.
- **Host git config** — your global `~/.gitconfig` is mounted read-only inside
  the container.
- **Educational comments** — every file includes "explain like I'm 5" inline
  comments describing what each piece does and why.
- **Plain `docker compose`** — no wrappers, no helper scripts, no Makefile.

## How it works

The project directory is bind-mounted into the container at `/app`. A startup script ([`scripts/with-host-ids`](scripts/with-host-ids)) runs every time the container starts:

1. Reads the UID/GID of the mounted `/app` directory (which matches your host user).
2. Adjusts the `developer` user inside the container to match those IDs (using `sudo`).
3. Hands off to the container's command as `developer`.

No build args, no manual UID/GID configuration needed.

## Quick start

```bash
docker compose up -d              # build and start the dev container
docker compose exec dev bash      # open a shell as developer
docker compose down               # stop the container
```

For VS Code: open the repo root and run **Dev Containers: Reopen in Container**.

## Production build

A multi-stage Dockerfile produces a tiny production image (≈11 MB on Alpine):

```bash
docker build --target production -t my-app .
```

The build stage compiles a statically-linked binary with `go install`, and the final stage copies only that binary into a fresh Alpine image.

## File overview

| File | Role |
|---|---|
| `Dockerfile` | Three-stage build: `dev` (full Go toolchain, linter, dev user), `build` (compiles binary), `production` (Alpine + binary only). |
| `docker-compose.yml` | Defines the `dev` service. Mounts the project, your `~/.gitconfig`, and keeps the container alive. |
| `scripts/with-host-ids` | Startup script that matches the container's `developer` UID/GID to your host user at runtime. |
| `.devcontainer/devcontainer.json` | VS Code Dev Containers config — connects as `developer` with Go + Docker extensions. |
| `.dockerignore` | Keeps the build context lean (excludes `.git`, docs, etc.). |
| `go.mod` / `main.go` | Minimal Go module and entry point to demonstrate the template in action. |

## sudo inside the container

The `developer` user has passwordless `sudo` access, so you can install system packages or run commands as root when needed.

## Host git config

Your global `~/.gitconfig` is mounted read-only into the developer's home directory, so `git` commands inside the container use your identity.

## Using this template for other languages

Most of the plumbing here is language-agnostic. The pieces that transfer directly:

- [`scripts/with-host-ids`](scripts/with-host-ids) — works with any base image that has `sudo`.
- [`docker-compose.yml`](docker-compose.yml) — bind mounts, gitconfig, `sleep infinity` — no Go references.
- [`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json) — just swap `image` and extensions.
- [`.dockerignore`](.dockerignore) — ignores source control, docs, and Docker files.

To adapt for a different language:

1. **Change the base image** in `Dockerfile` — `python:3.12-slim`, `node:22-bookworm`, `rust:latest`, etc.
2. **Install that language's tools** — replace the `go install` lines with `pip install`, `npm install -g`, `cargo install`, etc.
3. **Adjust the build stage** — compile with the language's toolchain (`go build`, `npm run build`, `cargo build --release`).
4. **Adjust the production stage** — use the appropriate slim/runtime base image and copy in the compiled artifact.

The entrypoint, user setup, UID/GID mapping, `.dockerignore`, and compose file stay unchanged.
