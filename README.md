# go-dev

A template for container-based Go development with automatic UID/GID mapping. Files created inside the container are owned by you on the host — no root-owned artifacts, no permission errors.

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
