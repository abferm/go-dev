# go-dev

A template for container-based Go development with automatic UID/GID mapping, so bind-mounted files never end up owned by root.

## How it works

The project directory is bind-mounted into the container at `/app`. Without UID/GID matching, files created inside the container (build artifacts, `go install` binaries, etc.) would be owned by root and unwritable from the host.

To solve this, the image ships a small [entrypoint script](./entrypoint.sh) that runs at container start:

1. It reads the owning UID/GID of the mounted `/app` directory (which matches your host user).
2. It adjusts the `developer` user inside the container to match those IDs.
3. It uses `gosu` to drop privileges and execute the container's `CMD` as `developer`.

No build args, no Makefile, no host-side wrappers needed.

## File overview

| File | Role |
|---|---|
| `with-host-ids` | Startup script: detects host UID/GID from the bind mount, updates the `developer` user, then drops privileges via `gosu`. |
| `Dockerfile` | Builds the dev image. Installs `sudo` + `gosu`, creates a static `developer` user, installs `golangci-lint`, and sets `entrypoint.sh` as the entrypoint. |
| `docker-compose.yml` | Defines the `dev` service. Builds without any UID/GID params, mounts `.` to `/app`, and sleeps forever. The entrypoint handles UID/GID mapping automatically. |
| `.devcontainer/devcontainer.json` | VS Code Dev Containers config. Connects as `developer` (which the entrypoint has already set up with the right UID/GID). |

## Quick start

```bash
docker compose up -d              # build and start the container
docker compose exec dev bash      # open a shell inside the container
docker compose down               # stop the container
```

For VS Code: open the repo root and run **Dev Containers: Reopen in Container**.

## sudo inside the container

The `developer` user has passwordless `sudo` access, so you can install system packages or run commands as root when needed.
