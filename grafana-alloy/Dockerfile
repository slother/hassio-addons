ARG BUILD_ARCH=amd64
ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base/amd64:9.1.0

# Download Alloy binary on native amd64 (avoids QEMU issues on cross-build)
FROM --platform=linux/amd64 debian:bookworm-slim AS downloader
ARG BUILD_ARCH
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl unzip \
    && rm -rf /var/lib/apt/lists/* \
    && ALLOY_VERSION="1.15.0" \
    && ARCH="${BUILD_ARCH}" \
    && if [ "${BUILD_ARCH}" = "aarch64" ]; then ARCH="arm64"; fi \
    && curl -fsSL -o /tmp/alloy.zip \
        "https://github.com/grafana/alloy/releases/download/v${ALLOY_VERSION}/alloy-linux-${ARCH}.zip" \
    && cd /tmp \
    && unzip alloy.zip \
    && mv alloy-linux-${ARCH} /alloy \
    && chmod +x /alloy

# Final image
ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base/amd64:9.1.0
FROM ${BUILD_FROM}

COPY --from=downloader /alloy /usr/local/bin/alloy

# Copy root filesystem
COPY rootfs /

ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="slother (https://github.com/slother)" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Add-ons" \
    org.opencontainers.image.authors="slother (https://github.com/slother)" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/slother" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
