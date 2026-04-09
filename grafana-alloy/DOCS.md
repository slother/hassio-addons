# Home Assistant Add-on: Grafana Alloy

## Overview

This add-on runs [Grafana Alloy](https://grafana.com/docs/alloy/) as a
telemetry collector inside Home Assistant OS. It automatically:

- Scrapes **Home Assistant Prometheus metrics** via the Supervisor API
- Collects **node/system metrics** (CPU, memory, disk, filesystem, network)
- Pushes everything to **Grafana Cloud** or any Prometheus remote_write endpoint
- Ships **systemd journal logs** to **Grafana Loki** (all HAOS logs including
  Home Assistant Core, add-ons, supervisor, and host system)

## Prerequisites

1. Enable the **Prometheus** integration in Home Assistant:
   Add to `configuration.yaml`:
   ```yaml
   prometheus:
   ```
2. A **Grafana Cloud** account (free tier works) or any Prometheus endpoint
   that accepts remote_write.

## Configuration

### Options

| Option               | Default | Description                                       |
|----------------------|---------|---------------------------------------------------|
| `prometheus_url`     | (empty) | Prometheus remote_write URL                       |
| `prometheus_username`| (empty) | Username (numeric ID for Grafana Cloud)            |
| `loki_url`           | (empty) | Loki push API URL                                 |
| `loki_username`      | (empty) | Username (numeric ID for Grafana Cloud Loki)       |
| `gcloud_api_key`     | (empty) | API key (used as basic_auth password)              |
| `log_level`          | `info`  | Alloy log level                                   |
| `scrape_interval`    | `60s`   | How often to scrape metrics                       |
| `custom_config_path` | (empty) | Path to custom Alloy config in `/config/`         |

### Grafana Cloud setup

1. Go to **grafana.com** → **My Account** → your stack
2. Under **Prometheus**, copy the **Remote Write Endpoint** and **Username**
3. Create an API key with **MetricsPublisher** role

### Grafana Cloud Loki setup

1. Go to **grafana.com** → **My Account** → your stack
2. Under **Loki**, copy the **Push URL** and **Username**
3. Use the same API key created for Prometheus (needs **MetricsPublisher** role)

Set `loki_url` to the push endpoint (e.g.,
`https://logs-prod-us-central1.grafana.net/loki/api/v1/push`) and
`loki_username` to the numeric user ID.

### Self-hosted endpoints

For self-hosted Prometheus, set only `prometheus_url`
(e.g., `http://prometheus:9090/api/v1/write`).
For self-hosted Loki, set only `loki_url`
(e.g., `http://loki:3100/loki/api/v1/push`).
Leave username and `gcloud_api_key` empty for no auth.

### Log labels

All journal entries shipped to Loki include these labels:

| Label              | Source                         |
|--------------------|--------------------------------|
| `job`              | `systemd-journal` (static)     |
| `unit`             | systemd unit name              |
| `hostname`         | machine hostname               |
| `syslog_identifier`| process identifier             |
| `transport`        | journal transport type         |
| `container_name`   | Docker container name (add-ons)|
| `level`            | log priority (debug, info, etc.)|

## Custom configuration

Create a `.alloy` file in your Home Assistant `/config/` directory and set
`custom_config_path` to the filename (e.g., `alloy/my-config.alloy`).

## Web UI

Alloy exposes a web UI on port 12345 (disabled by default in the port
mapping). Enable it in the add-on network configuration to debug pipelines.
