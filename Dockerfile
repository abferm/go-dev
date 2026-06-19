FROM golang:1.26.0-bookworm AS dev
WORKDIR /app
RUN apt-get update && \
    apt-get install -y sudo gosu && \
    rm -rf /var/lib/apt/lists/*

# Set up development user; UID/GID are adjusted at startup by entrypoint.sh
RUN groupadd -g 1000 developer && \
    useradd -r -u 1000 -g 1000 -m -s /bin/bash developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer
RUN chown -R developer:developer /go && chmod -R a+rwX /go

ENV GO11MODULE=on
RUN go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.63.0 && \
    golangci-lint --version

COPY scripts/with-host-ids /with-host-ids
ENTRYPOINT ["/with-host-ids"]
CMD ["bash"]
