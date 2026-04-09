#!/command/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Grafana Alloy Add-on: Generate configuration
# ==============================================================================

readonly CONFIG_FILE="/etc/alloy/config.alloy"
readonly CUSTOM_CONFIG_PATH=$(bashio::config 'custom_config_path')
readonly LOG_LEVEL=$(bashio::config 'log_level')

# If a custom config path is set and the file exists, use it
if bashio::var.has_value "${CUSTOM_CONFIG_PATH}" \
    && [ -f "/config/${CUSTOM_CONFIG_PATH}" ]; then
    bashio::log.info "Using custom configuration from /config/${CUSTOM_CONFIG_PATH}"
    cp "/config/${CUSTOM_CONFIG_PATH}" "${CONFIG_FILE}"
    exit 0
fi

bashio::log.info "Generating Alloy configuration from addon options..."

readonly PROM_URL=$(bashio::config 'prometheus_url')
readonly PROM_USERNAME=$(bashio::config 'prometheus_username')
readonly SCRAPE_INTERVAL=$(bashio::config 'scrape_interval')
readonly LOKI_URL=$(bashio::config 'loki_url')
readonly LOKI_USERNAME=$(bashio::config 'loki_username')

# Get real hostname from Supervisor API
HA_HOSTNAME=$(curl -sSf -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
    http://supervisor/host/info 2>/dev/null | jq -r '.data.hostname // empty') \
    || true
if [ -z "${HA_HOSTNAME}" ]; then
    HA_HOSTNAME=$(bashio::host.hostname 2>/dev/null) || true
fi
HA_HOSTNAME="${HA_HOSTNAME:-homeassistant}"
bashio::log.info "Host hostname: ${HA_HOSTNAME}"

# --- Build Prometheus blocks ---
PROM_BLOCK=""
if bashio::var.has_value "${PROM_URL}"; then
    PROM_AUTH=""
    if bashio::var.has_value "${PROM_USERNAME}"; then
        PROM_AUTH="
    basic_auth {
      username = \"${PROM_USERNAME}\"
      password = sys.env(\"GCLOUD_API_KEY\")
    }"
    fi

    PROM_BLOCK="
// ---------------------------------------------------------------------------
// Node / system metrics
// ---------------------------------------------------------------------------
prometheus.exporter.unix \"node\" {
  enable_collectors = [\"cpu\", \"loadavg\", \"meminfo\", \"diskstats\", \"filesystem\", \"netdev\"]
}

prometheus.scrape \"node\" {
  targets         = prometheus.exporter.unix.node.targets
  scrape_interval = \"${SCRAPE_INTERVAL}\"
  forward_to      = [prometheus.relabel.instance.receiver]
}

// ---------------------------------------------------------------------------
// Home Assistant Prometheus metrics (via Supervisor API)
// ---------------------------------------------------------------------------
prometheus.scrape \"homeassistant\" {
  targets = [{
    __address__ = \"supervisor\",
    __scheme__  = \"http\",
  }]
  metrics_path    = \"/core/api/prometheus\"
  scrape_interval = \"${SCRAPE_INTERVAL}\"
  scrape_timeout  = \"30s\"

  bearer_token = sys.env(\"SUPERVISOR_TOKEN\")

  forward_to = [prometheus.relabel.instance.receiver]
}

// ---------------------------------------------------------------------------
// Alloy self-monitoring
// ---------------------------------------------------------------------------
prometheus.exporter.self \"alloy\" {}

prometheus.scrape \"alloy\" {
  targets    = prometheus.exporter.self.alloy.targets
  forward_to = [prometheus.relabel.instance.receiver]
}

// ---------------------------------------------------------------------------
// Override instance label with real hostname
// ---------------------------------------------------------------------------
prometheus.relabel \"instance\" {
  rule {
    target_label = \"instance\"
    replacement  = \"${HA_HOSTNAME}\"
  }
  forward_to = [prometheus.remote_write.default.receiver]
}

// ---------------------------------------------------------------------------
// Remote write to Grafana Cloud / Prometheus
// ---------------------------------------------------------------------------
prometheus.remote_write \"default\" {
  external_labels = {
    instance = \"${HA_HOSTNAME}\",
  }
  endpoint {
    url = \"${PROM_URL}\"${PROM_AUTH}
  }
}"
fi

# --- Build Loki blocks ---
LOKI_BLOCK=""
if bashio::var.has_value "${LOKI_URL}"; then
    # Detect journal path
    JOURNAL_PATH="/var/log/journal"
    if [ ! -d "${JOURNAL_PATH}" ] || [ -z "$(ls -A "${JOURNAL_PATH}" 2>/dev/null)" ]; then
        JOURNAL_PATH="/run/log/journal"
    fi
    bashio::log.info "Journal path: ${JOURNAL_PATH}"

    LOKI_AUTH=""
    if bashio::var.has_value "${LOKI_USERNAME}"; then
        LOKI_AUTH="
    basic_auth {
      username = \"${LOKI_USERNAME}\"
      password = sys.env(\"GCLOUD_API_KEY\")
    }"
    fi

    LOKI_BLOCK="
// ---------------------------------------------------------------------------
// Systemd journal log shipping
// ---------------------------------------------------------------------------
loki.source.journal \"journal\" {
  path         = \"${JOURNAL_PATH}\"
  forward_to   = [loki.process.journal.receiver]
  relabel_rules = loki.relabel.journal.rules
  labels       = {
    job      = \"integrations/unix\",
    instance = \"${HA_HOSTNAME}\",
  }
}

loki.relabel \"journal\" {
  forward_to = []

  rule {
    source_labels = [\"__journal__systemd_unit\"]
    target_label  = \"unit\"
  }
  rule {
    source_labels = [\"__journal__hostname\"]
    target_label  = \"hostname\"
  }
  rule {
    source_labels = [\"__journal_syslog_identifier\"]
    target_label  = \"syslog_identifier\"
  }
  rule {
    source_labels = [\"__journal__transport\"]
    target_label  = \"transport\"
  }
  rule {
    source_labels = [\"__journal_container_name\"]
    target_label  = \"container_name\"
  }
  rule {
    source_labels = [\"__journal_priority_keyword\"]
    target_label  = \"level\"
  }
}

loki.process \"journal\" {
  stage.drop {
    expression = \"^\\\\s*\$\"
  }

  forward_to = [loki.write.loki.receiver]
}

loki.write \"loki\" {
  endpoint {
    url = \"${LOKI_URL}\"${LOKI_AUTH}
  }
}"
fi

# --- Check endpoint is configured ---
if ! bashio::var.has_value "${PROM_URL}" && ! bashio::var.has_value "${LOKI_URL}"; then
    bashio::log.warning \
        "No Prometheus or Loki URL configured. Alloy will start but won't send data anywhere."
fi

cat > "${CONFIG_FILE}" << EOF
// Grafana Alloy configuration — auto-generated by Home Assistant addon
// To customize, create your own config.alloy and set custom_config_path

logging {
  level = "${LOG_LEVEL}"
}
${PROM_BLOCK}
${LOKI_BLOCK}
EOF

bashio::log.info "Configuration generated successfully"
