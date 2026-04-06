# WebDAV

![Supports aarch64 Architecture](https://img.shields.io/badge/aarch64-yes-green.svg)
![Supports amd64 Architecture](https://img.shields.io/badge/amd64-yes-green.svg)

## About

A WebDAV server add-on for Home Assistant, powered by [rclone](https://rclone.org/).

### Features

- **Built-in SSL/TLS** — uses certificates managed by Home Assistant, no reverse proxy needed
- **Per-user directory isolation** — each user is confined to their own subfolder under `document_root`, preventing cross-user access
- **Multiple users** — define as many login accounts as you need
- **Automatic directory creation** — user directories are created on addon startup
- **Lightweight** — minimal Alpine-based image with rclone and htpasswd

### Use cases

- Backup target for [Kopia](https://kopia.io/), [Duplicati](https://www.duplicati.com/), or other backup tools
- Remote file access from mobile apps (e.g. [FE File Explorer](https://www.skyjos.com/owlfiles/))
- Syncing files between devices via WebDAV-compatible clients
- Exposing Home Assistant media/share directories over the network
