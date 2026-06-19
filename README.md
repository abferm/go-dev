# go-dev

A template for container-based Go development that solves the volume permission problem by creating a container user whose UID/GID matches your host user.

## How it works

The project directory is bind-mounted into the container at `/app`. Without the developer user setup, files created inside the container (e.g., build artifacts, `go install` binaries) would be owned by `root`, making them unwritable or undeletable from the host.

To avoid this, the container creates a `developer` user with the same UID/GID as your host user, and all processes run as that user. `sudo` is available (passwordless) inside the container when elevated permissions are needed.

## File overview

| File | Role |
|---|---|
| `Dockerfile` | Builds the dev image: installs `sudo`, creates `developer:<UID:GID>`, sets `USER developer`, installs `golangci-lint`. |
| `docker-compose.yml` | Defines the `dev` service. Builds with `UID`/`GID` build args, passes them as the container runtime user, mounts `.` to `/app`, and sleeps forever to keep the container alive. |
| `Makefile` | Convenience wrapper. Automatically exports your host `UID`/`GID` as env vars before calling `docker compose`. Targets: `up` (build + start), `down` (stop), `shell` (open a shell). See `make help`. |
| `.devcontainer/devcontainer.json` | VS Code Dev Containers config. Points to `docker-compose.yml`, sets the workspace to `/app`, and installs the Go and Docker VS Code extensions. |

## Quick start

```bash
make up     # build and start the container
make shell  # open a shell inside the container
make down   # stop the container
```

For VS Code: open the repo root and run **Dev Containers: Reopen in Container**. The devcontainer config will use the same compose + Dockerfile.


