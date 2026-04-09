# Changelog

## 1.1.9

### Fixed
- override instance label on metrics with real hostname



## 1.1.8

### Fixed
- get hostname directly from Supervisor /host/info API



## 1.1.0

- Systemd journal log shipping to Loki (ported from ecohash/ha-addon-alloy)
- Journal field relabeling: unit, hostname, syslog_identifier, transport, container_name, level
- Grafana Cloud Loki support with basic_auth
- Auto-detection of journal path (/var/log/journal or /run/log/journal)

## 0.3.0

- Stripped down to Prometheus-only (removed Loki/Docker/journal)
- Home Assistant Prometheus metrics scraping via Supervisor API
- Node/system metrics (CPU, memory, disk, network)
- Grafana Cloud and self-hosted Prometheus support

## 0.1.0

- Initial release
- Grafana Alloy v1.15.0
