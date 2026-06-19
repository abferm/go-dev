# Start from the official Go image — it already has Go installed and ready
FROM golang:1.26.0-bookworm AS dev

# Every command after this runs in the /app folder inside the container
WORKDIR /app

RUN apt-get update && \
    apt-get install -y sudo && \
    rm -rf /var/lib/apt/lists/*
# sudo: lets the developer user run commands as root (e.g. apt install)

# Create a user named "developer" with a fixed ID (1000) and a home folder.
# The with-host-ids script (see below) will change this ID to match your
# computer's user ID when the container starts, so file ownership lines up.
RUN groupadd -g 9999 developer && \
    useradd -r -u 9999 -g 9999 -m -s /bin/bash developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer

# /go is where Go stores installed tools (like golangci-lint) and cached
# modules. Own it to the developer user so the build-time install works.
RUN chown -R developer:developer /go

# Pre-install a Go linter so it's ready to use the first time you shell in
RUN go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.63.0 && \
    golangci-lint --version

# Everything Go writes at runtime (installed tools, module cache) goes
# into the developer's home directory, which the entrypoint will chown
# to match your host UID/GID. The pre-installed linter stays in /go/bin.
ENV GOPATH=/home/developer/go
ENV PATH=$PATH:/go/bin:/home/developer/go/bin

# Copy in the startup script that matches the developer user's ID to yours
COPY scripts/with-host-ids /with-host-ids

# Run the container as the developer user by default.
# docker compose exec will inherit this user automatically.
USER developer

# Every time the container starts, run with-host-ids to adjust the
# developer user's UID/GID to match your host user. It uses sudo for
# the few commands that need root, then hands off to whatever command
# was given (the CMD below).
ENTRYPOINT ["/with-host-ids"]

# If you don't tell the container what to do, it just starts a bash shell.
# (docker-compose.yml overrides this to "sleep infinity" so it stays alive.)
CMD ["bash"]
