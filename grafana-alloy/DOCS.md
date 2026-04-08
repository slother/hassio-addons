# Home Assistant Add-on: Grafana Alloy

## Overview

This add-on runs [Grafana Alloy](https://grafana.com/docs/alloy/) as a
telemetry collector inside Home Assistant OS. It automatically:

- Scrapes **Home Assistant Prometheus metrics** via the Supervisor API
- Collects **node/system metrics** (CPU, memory, disk, filesystem, network)
- Collects **systemd journal logs** and **Docker container logs**
- Pushes everything to **Grafana Cloud** (or any Prometheus/Loki endpoint)

## Prerequisites

1. Enable the **Prometheus** integration in Home Assistant:
   Add to `configuration.yaml`:
   ```yaml
   prometheus:
   ```
2. A **Grafana Cloud** account (free tier works) with Prometheus and Loki
   endpoints.

## Configuration

### Required options

| Option               | Description                                      |
|----------------------|--------------------------------------------------|
| `prometheus_url`     | Grafana Cloud Prometheus remote_write URL         |
| `prometheus_username`| Grafana Cloud Prometheus username (numeric ID)    |
| `loki_url`           | Grafana Cloud Loki push URL                       |
| `loki_username`      | Grafana Cloud Loki username (numeric ID)          |
| `gcloud_api_key`     | Grafana Cloud API key (used for both endpoints)   |

### Optional options

| Option              | Default | Description                               |
|---------------------|---------|-------------------------------------------|
| `log_level`         | `info`  | Alloy log level                           |
| `scrape_interval`   | `60s`   | How often to scrape metrics               |
| `custom_config_path`| (empty) | Path to custom Alloy config in `/config/` |

### Finding your Grafana Cloud credentials

1. Go to **grafana.com** → **My Account** → your stack
2. Under **Prometheus**, copy the **Remote Write Endpoint** and **Username**
3. Under **Loki**, copy the **Push URL** and **Username**
4. Create an API key with **MetricsPublisher** and **LogsPublisher** roles

## Custom configuration

If you need full control over the Alloy config, create a `.alloy` file in
your Home Assistant `/config/` directory and set `custom_config_path` to the
filename (e.g., `alloy/my-config.alloy`).

## Web UI

Alloy exposes a web UI on port 12345 (disabled by default in the port
mapping). Enable it in the add-on network configuration to debug pipelines.
