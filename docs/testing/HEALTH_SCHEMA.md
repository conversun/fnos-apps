# health.json — App Health Probe Contract

Each app may declare `apps/<slug>/fnos/health.json` to describe how the test
harness should determine whether the app is running correctly after install.

The file is **optional**. When absent, defaults apply (see "Defaults" below).

## Why

The fpk-runner test harness installs the .fpk inside a sandbox, starts the
service, and must decide: "is the app actually working?" Without per-app
guidance the harness only knows:

- the PID file exists (which `wait_for_status` already checks), AND
- the manifest declares `service_port`.

That is not sufficient. Many failures (e.g. moviepilot #141 port conflict,
smartdns #142 missing plugin) leave a PID alive briefly while the daemon
crashes. We need an explicit health contract.

## Schema

```jsonc
{
  // REQUIRED: how to probe.
  // - "http": GET http://localhost:<port><path>, accept any status in expect_status
  // - "tcp":  open TCP connection to <port>, success on connect
  // - "skip": no probe (use only for special apps; document why in `note`)
  "type": "http",

  // OPTIONAL: probe path (http only). Default "/".
  "path": "/",

  // OPTIONAL: accepted HTTP status codes. Default [200, 301, 302, 401, 403].
  //   401/403 are accepted because many apps require auth on root, which is
  //   still proof of "server is up".
  "expect_status": [200, 302],

  // OPTIONAL: override probe port. Default = manifest service_port.
  //   Use for apps that bind a different debug port internally.
  "port": 9999,

  // OPTIONAL: total seconds to wait for the probe to succeed.
  //   Default 60. Increase for slow-starting apps (databases, Java apps).
  "startup_timeout_seconds": 60,

  // OPTIONAL: seconds to wait BEFORE starting probes (post-install warmup).
  //   Default 0. Useful for docker-compose apps that need image pull/extract.
  "post_install_warmup_seconds": 0,

  // OPTIONAL: architectures to skip entirely. Empty array by default.
  //   Use when upstream provides no binary for that arch.
  "skip_arch": ["arm"],

  // OPTIONAL: human-readable explanation for `type: skip` or `skip_arch`.
  "note": "Plex uses a proprietary handshake; TCP probe is enough."
}
```

## Defaults (when health.json is absent)

| Field | Default |
|---|---|
| `type` | `"http"` |
| `scheme` | `"http"` |
| `path` | `"/"` |
| `expect_status` | `[200, 301, 302, 401, 403]` |
| `port` | `manifest.service_port` |
| `startup_timeout_seconds` | `60` |
| `post_install_warmup_seconds` | `0` (native) / `15` (docker app) |
| `skip_arch` | `[]` |
| `note` | `""` |

These defaults work for most well-behaved web apps. Override when the app
deviates.

## Examples

### obsidian — TLS-only web UI

```json
{
  "type": "http",
  "scheme": "https",
  "expect_status": [200, 301, 302],
  "note": "Obsidian serves HTTPS only on container port 3001."
}
```

### gopeed — vanilla Go HTTP server

```json
{
  "type": "http",
  "path": "/",
  "expect_status": [200, 302],
  "startup_timeout_seconds": 30
}
```

### plex — opaque protocol, TCP-only check

```json
{
  "type": "tcp",
  "startup_timeout_seconds": 90,
  "note": "Plex serves a proprietary protocol on 32400. TCP-listen is the strongest portable signal."
}
```

### moviepilot — slow Python boot + docker warmup

```json
{
  "type": "http",
  "path": "/",
  "expect_status": [200, 302],
  "startup_timeout_seconds": 180,
  "post_install_warmup_seconds": 30
}
```

### syncthing — REST GUI on 8384

```json
{
  "type": "http",
  "path": "/rest/system/ping",
  "expect_status": [200],
  "startup_timeout_seconds": 45
}
```

### clamav (arm) — skip arch with no upstream image

```json
{
  "type": "skip",
  "skip_arch": ["arm"],
  "note": "ClamAV official image has no arm64 build (issue #107)."
}
```

## Validation

`scripts/test/health-schema.sh` validates every `health.json` against this
contract. The check is part of `scripts/test/static-check.sh` and runs in CI.

## Future fields (not implemented yet)

These are reserved for later expansion; do not use today.

- `command` — execute a custom in-container probe binary.
- `requires_data_share` — declare an external mount the test must provide.
- `default_credentials` — bootstrap user/pass for login probes.
- `pre_probe_commands` — initialise state (e.g. seed config).
