#!/usr/bin/with-contenv bashio
# ==============================================================================
# Prepare the rclone WebDAV service
# ==============================================================================

readonly HTPASSWD_FILE="/etc/rclone/.htpasswd"

bashio::log.info "Using rclone version:"
rclone version | head -1

if ! bashio::config.has_value 'logins[0].username' || \
    ! bashio::config.has_value 'logins[0].password'; then
  bashio::exit.nok "No username or password is defined!"
fi

root_dir=$(bashio::config "document_root")
bashio::log.info "Ensure directory ${root_dir}/ exists ..."
mkdir -v -p "${root_dir}"
chmod -R 755 "${root_dir}"

if bashio::config.true 'ssl'; then
  certfile=$(bashio::config "certfile")
  keyfile=$(bashio::config "keyfile")

  if ! bashio::fs.file_exists "/ssl/${certfile}"; then
    bashio::exit.nok "SSL certificate not found: /ssl/${certfile}"
  fi
  if ! bashio::fs.file_exists "/ssl/${keyfile}"; then
    bashio::exit.nok "SSL key not found: /ssl/${keyfile}"
  fi
  bashio::log.info "SSL enabled with cert=/ssl/${certfile} key=/ssl/${keyfile}"
fi

bashio::log.info "Creating htpasswd file ..."
> "${HTPASSWD_FILE}"

for id in $(bashio::config 'logins|keys'); do
  bashio::config.require.username "logins[${id}].username"
  bashio::config.require.password "logins[${id}].password"
  username=$(bashio::config "logins[${id}].username")
  password=$(bashio::config "logins[${id}].password")

  htpasswd -bB "${HTPASSWD_FILE}" "${username}" "${password}" > /dev/null 2>&1

  bashio::log.info "Ensure directory ${root_dir}/${username}/ exists ..."
  mkdir -v -p "${root_dir}/${username}"
  chmod 755 "${root_dir}/${username}"

  bashio::log.info "Added user: ${username} (root: ${root_dir}/${username})"
done

chmod +x /etc/rclone/auth-proxy.sh
