FROM golang:1.26.0-bookworm AS dev
WORKDIR /app
RUN apt-get update && \
    apt-get install -y sudo && \
    rm -rf /var/lib/apt/lists/*

# Set up development user to prevent repository permissions issues
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID developer && \
    useradd -r -u $UID -g $GID -m -s /bin/bash developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer
RUN chown -R $UID:$GID /go

USER developer
# From this point on use sudo when root permissions are required

ENV GO11MODULE=on
RUN go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.63.0 && \
    golangci-lint --version
CMD ["bash"]
