# WebDAV

## Installation

Follow these steps to get the add-on installed on your system:

1. Click the Home Assistant My button below to open the add-on on your Home Assistant instance.   
   [![Open your Home Assistant instance and show the dashboard of an add-on.](https://my.home-assistant.io/badges/supervisor_addon.svg)](https://my.home-assistant.io/redirect/supervisor_addon/?addon=bb4914d7_webdav&repository_url=https%3A%2F%2Fgithub.com%2Fslother%2Fhassio-addons)  
2. Click the `Install` button to install the add-on.  
3. Go to the `Configuration` tab and set the options to your preferences  
4. Click the `Save` button to store your configuration.  
5. Go back to the `Info` tab and start this add-on.  
6. Check the logs in the `Log` tab to see if everything went well.   

## Configuration

Example add-on configuration:  

```yaml
ssl: false
certfile: fullchain.pem
keyfile: privkey.pem
metrics: false
document_root: /share/webdav
logins:
  - username: dummyUser
    password: '!secret password'
```

Example with SSL enabled:  

```yaml
ssl: true
certfile: fullchain.pem
keyfile: privkey.pem
metrics: false
document_root: /share/webdav
logins:
  - username: dummyUser
    password: '!secret password'
```

> [!TIP]  
> You may also use [home assistant secrets](https://www.home-assistant.io/docs/configuration/secrets/) in your addon-configuration.  
> At least for your password it is highly recommended to use it.  

## Options

### Option: `ssl` (mandatory)

Enable or disable SSL/TLS encryption.  
When enabled, the addon will use the certificate and key files from the `/ssl/` directory.  

### Option: `certfile` (mandatory)

The filename of the SSL certificate in the `/ssl/` directory.  
Default: `fullchain.pem`  

### Option: `keyfile` (mandatory)

The filename of the SSL private key in the `/ssl/` directory.  
Default: `privkey.pem`  

### Option: `document_root` (mandatory)

Set here the root directory for your WebDAV server.  

### Option: `logins.username` (mandatory)

A username to authenticate against the WebDAV server.  
It is possible to define multiple username/password options, but at least one username/password is needed to start the WebDAV server.  

### Option: `logins.password` (mandatory)

A password to authenticate against the WebDAV server.  
It is possible to define multiple username/password options, but at least one username/password is needed to start the WebDAV server.  

### Option: `metrics` (mandatory)

Enable or disable Prometheus metrics endpoint.  
When enabled, rclone exposes metrics at `http://<host>:5572/metrics` in Prometheus format.  
Default: `false`  

Example Prometheus scrape config:

```yaml
scrape_configs:
  - job_name: rclone
    static_configs:
      - targets: ['<homeassistant-ip>:5572']
```

> [!NOTE]  
> Make sure to map port `5572` in the add-on network configuration when enabling metrics.  

### Port `8080`, EntryPoint `WebDAV`

Port 8080 is used for WebDAV access.  

### Port `5572`, EntryPoint `Prometheus metrics`

Port 5572 is used for the Prometheus metrics endpoint.  
Disabled by default — set `metrics: true` and map the port to enable.  

## Per-user directory isolation

Each user automatically gets their own isolated directory under `document_root`.  
For example, with `document_root: /share/webdav`:  

| User | Sees only |
|------|-----------|
| `kopia` | `/share/webdav/kopia/` |
| `immich` | `/share/webdav/immich/` |

Users cannot access each other's directories.  
Directories are created automatically when the addon starts.  

## Changelog & Releases

Releases are based on [Semantic Versioning](https://semver.org/lang/de/spec/v2.0.0.html), and use the format of `MAJOR.MINOR.PATCH`.  
In a nutshell, the version will be incremented based on the following:  

- `MAJOR`: Incompatible or major changes.  
- `MINOR`: Backwards-compatible new features and enhancements.  
- `PATCH`: Backwards-compatible bugfixes and package updates.  

## Support

Got questions?  
You can simply [open an issue here](https://github.com/slother/hassio-addons/issues) on GitHub.
