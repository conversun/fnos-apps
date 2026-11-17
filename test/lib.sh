# Shared helpers for the fnOS VM test harness.
# Source this AFTER determining the harness dir. No `set -e` on purpose:
# the runner must survive per-app failures.
set -uo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
APPS_JSON_DEFAULT="$TEST_DIR/../apps.json"

load_config() {
    local cfg="${1:-$TEST_DIR/config.env}"
    if [ ! -f "$cfg" ]; then
        echo "ERROR: $cfg not found — copy config.env.example to config.env first." >&2
        exit 1
    fi
    # shellcheck disable=SC1090
    . "$cfg"
    : "${FNOS_VM_IP:?set FNOS_VM_IP in config.env}"
    : "${FNOS_VM_USER:?set FNOS_VM_USER}"
    : "${FNOS_VM_PASS:?set FNOS_VM_PASS}"
    : "${FNOS_TEST_VOLUME:=1}"
    : "${FNOS_ARCH:=x86}"
    : "${FNOS_MIRROR:=}"
    : "${FNOS_START_TIMEOUT:=40}"
    : "${FNOS_PORT_TIMEOUT:=30}"
    : "${APPS_JSON:=$APPS_JSON_DEFAULT}"
    command -v sshpass  >/dev/null || { echo "ERROR: sshpass required (brew install hudochenkov/sshpass/sshpass)" >&2; exit 1; }
    command -v python3  >/dev/null || { echo "ERROR: python3 required" >&2; exit 1; }
}

_SSH_OPTS=(-o StrictHostKeyChecking=no -o ConnectTimeout=8 -o LogLevel=ERROR)

# Run a bash script (stdin) as ROOT on the VM, forwarding positional args.
# Usage:  vm_root_args a b c <<'REMOTE' ... uses $1 $2 $3 ... REMOTE
vm_root_args() {
    local q="" a
    for a in "$@"; do q+=" $(printf '%q' "$a")"; done
    # Write the script (stdin) to a temp file on the VM, then run it as root with
    # `sudo bash <file>` — so the password (echo pipe -> sudo -S) and the script
    # source (the file) don't fight over stdin. Args follow the filename directly.
    sshpass -p "$FNOS_VM_PASS" ssh "${_SSH_OPTS[@]}" "$FNOS_VM_USER@$FNOS_VM_IP" \
        "f=\$(mktemp); cat > \"\$f\"; echo '$FNOS_VM_PASS' | sudo -S -p '' bash \"\$f\"$q; rc=\$?; rm -f \"\$f\"; exit \$rc"
}

# Resolve an app from apps.json. Prints TSV: appname<TAB>fpk_url<TAB>port<TAB>app_type
resolve_app() {
    python3 - "$1" "$FNOS_ARCH" "$FNOS_MIRROR" "$APPS_JSON" <<'PY'
import json, sys
slug, arch, mirror, path = sys.argv[1:5]
data = json.load(open(path))
apps = data if isinstance(data, list) else data.get("apps", list(data.values()) if isinstance(data, dict) else [])
a = next((x for x in apps if slug in (x.get("slug"), x.get("appname"), x.get("file_prefix"))), None)
if not a:
    sys.exit(f"app not found in apps.json: {slug}")
fp = a.get("file_prefix") or a["slug"]
rt = a["release_tag"]
fv = a.get("fpk_version") or a["version"]
url = f'{mirror}https://github.com/conversun/fnos-apps/releases/download/{rt}/{fp}_{fv}_{arch}.fpk'
print(a.get("appname") or a["slug"], url, a.get("service_port", 0), a.get("app_type", "native"), sep="\t")
PY
}

# List apps from apps.json. $1 = "native" | "docker" | "all". Prints one slug per line.
list_apps() {
    python3 - "${1:-native}" "$APPS_JSON" <<'PY'
import json, sys
want, path = sys.argv[1], sys.argv[2]
data = json.load(open(path))
apps = data if isinstance(data, list) else data.get("apps", list(data.values()) if isinstance(data, dict) else [])
for a in apps:
    slug = a.get("slug") or a.get("appname")
    if not slug or slug == "fnos-apps-store":   # store is tested separately
        continue
    if want == "all" or a.get("app_type", "native") == want:
        print(slug)
PY
}

# Resolve the wizard answers for an app slug. Prints a JSON array of
# {"key":...,"value":...}. Reads wizard-answers.env for per-app overrides;
# absent apps get a generic fill handled server-side (the wizard test submits
# what the app's own required fields demand).
wizard_answers_for() {
    local slug="$1" cfg="$TEST_DIR/wizard-answers.env"
    [ -f "$cfg" ] && . "$cfg"
    # Indirect expansion via eval: bash 3.2 (macOS) rejects ${!var:-default}.
    local var="WIZARD_ANSWERS_${slug//-/_}" val
    eval "val=\"\${$var:-[]}\""
    printf '%s' "$val"
}

# Test ONE app end-to-end on the VM. Emits `stage=RESULT` lines on stdout.
# Args: appname fpk_url service_port
test_one() {
    vm_root_args "$1" "$2" "${3:-0}" "$FNOS_TEST_VOLUME" \
                 "$FNOS_START_TIMEOUT" "$FNOS_PORT_TIMEOUT" "$FNOS_MIRROR" <<'REMOTE'
set +e
APP="$1"; URL="$2"; PORT="$3"; VOL="$4"; ST_TO="$5"; PT_TO="$6"; MIRROR="$7"
AC=/usr/local/bin/appcenter-cli
FPK="/tmp/fnostest_${APP}.fpk"

# Clean any prior install so the test starts from zero.
$AC uninstall "$APP" >/dev/null 2>&1

# download: try the mirror URL, then fall back to direct GitHub (mirrors rate-limit under load).
DIRECT="$URL"; [ -n "$MIRROR" ] && DIRECT="${URL#$MIRROR}"
dl=FAIL
for u in "$URL" "$DIRECT"; do curl -fsSL --retry 3 --retry-delay 2 --connect-timeout 20 -o "$FPK" "$u" && { dl=PASS; break; }; done
[ "$dl" = PASS ] && echo "download=PASS" || { echo "download=FAIL"; exit 0; }
if $AC install-fpk "$FPK" -v "$VOL" >/tmp/fnostest_inst.log 2>&1; then echo "install=PASS"; else echo "install=FAIL:$(tail -n1 /tmp/fnostest_inst.log)"; fi

chk=$($AC check "$APP" 2>/dev/null)
[ "$chk" = "Installed" ] && echo "register=PASS" || echo "register=FAIL:$chk"

s=SLOW; st=""   # soft: heavy apps may not reach status=running within the timeout
for _ in $(seq 1 $((ST_TO/2))); do st=$($AC status "$APP" 2>/dev/null); [ "$st" = "running" ] && { s=PASS; break; }; sleep 2; done
echo "start=$s:$st"

p=SKIP
if [ -n "$PORT" ] && [ "$PORT" != "0" ]; then
  p=DOWN   # soft signal (not a hard fail): fnOS apps are often gateway-fronted,
  for _ in $(seq 1 $((PT_TO/2))); do timeout 3 bash -c "echo >/dev/tcp/127.0.0.1/$PORT" 2>/dev/null && { p=PASS; break; }; sleep 2; done
           # so 127.0.0.1:<service_port> may not answer even when the app is running.
fi
echo "port=$p"

# Installed onto the requested volume? (target -> /volN/@appcenter/<app>)
tv=$(readlink "/var/apps/$APP/target" 2>/dev/null)
case "$tv" in
  /vol${VOL}/*)      echo "volume=PASS" ;;
  /usr/local/apps/*) echo "volume=PASS:root-install" ;;   # root-install apps live on the system disk, not /volN
  *)                 echo "volume=FAIL:$tv" ;;
esac

$AC uninstall "$APP" >/dev/null 2>&1 && echo "uninstall=PASS" || echo "uninstall=FAIL"
# Reclaim disk between apps. NOT `prune -a`: that deletes images which are
# still referenced by OTHER apps' stopped containers, and those containers
# can then never start again —
#   error creating overlay mount to /vol2/docker/overlay2/<id>/merged:
#   no such file or directory
# which is how astrbot and cowagent got bricked on the debug VM.
command -v docker >/dev/null 2>&1 && docker system prune -f >/dev/null 2>&1   # bound disk for docker apps (no-op for native)
rm -f "$FPK"
REMOTE
}

# ---------------------------------------------------------------------------
# Daemon-RPC based tests (data-preserving path). These prepend rpc.sh onto the
# remote heredoc so the RPC helpers are defined on the VM before use.
# ---------------------------------------------------------------------------

# _remote_rpc runs a remote heredoc with rpc.sh prepended.
_remote_rpc() {
    cat "$TEST_DIR/rpc.sh" - | vm_root_args "$@"
}

# Test wizard submission end-to-end for ONE app on the VM.
# Args: appname fpk_url wizard_answers_json
#   wizard_answers_json: JSON array of {"key":...,"value":...} submitted as
#   customParameters. Emits `stage=RESULT` lines on stdout.
test_wizard() {
    _remote_rpc "$1" "$2" "$3" "$FNOS_TEST_VOLUME" "$FNOS_START_TIMEOUT" "$FNOS_MIRROR" <<'REMOTE'
set +e
APP="$1"; URL="$2"; ANSWERS="$3"; VOL="$4"; ST_TO="$5"; MIRROR="$6"
AC=/usr/local/bin/appcenter-cli
FPK="/tmp/fnostest_wiz_${APP}.fpk"

$AC uninstall "$APP" >/dev/null 2>&1

DIRECT="$URL"; [ -n "$MIRROR" ] && DIRECT="${URL#$MIRROR}"
dl=FAIL
for u in "$URL" "$DIRECT"; do curl -fsSL --retry 3 --retry-delay 2 --connect-timeout 20 -o "$FPK" "$u" && { dl=PASS; break; }; done
[ "$dl" = PASS ] && echo "download=PASS" || { echo "download=FAIL"; exit 0; }

IFS=$'\t' read -r appname ver ptype installed < <(rpc_stage_fpk "$FPK")
[ -n "$appname" ] && echo "stage=PASS" || { echo "stage=FAIL"; rm -f "$FPK"; exit 0; }

# Fetch the wizard definition; empty array means the app has no wizard.
WIZ=$(rpc_fetch_wizard "$appname" "$ver" "$ptype")
has_wiz=$(echo "$WIZ" | python3 -c 'import json,sys;print("true" if json.load(sys.stdin) else "false")' 2>/dev/null || echo false)
echo "wizard_def=$has_wiz"

# Submit install with the wizard answers through the data-preserving channel.
st=$(rpc_install "$appname" "$ver" "$ptype" "$VOL" "$ANSWERS" true)
[ "$st" = "2" ] && echo "install=PASS" || echo "install=FAIL:status=$st"

chk=$($AC check "$APP" 2>/dev/null)
[ "$chk" = "Installed" ] && echo "register=PASS" || echo "register=FAIL:$chk"

s=SLOW; stt=""
for _ in $(seq 1 $((ST_TO/2))); do stt=$($AC status "$APP" 2>/dev/null); [ "$stt" = "running" ] && { s=PASS; break; }; sleep 2; done
echo "start=$s:$stt"

$AC uninstall "$APP" >/dev/null 2>&1 && echo "uninstall=PASS" || echo "uninstall=FAIL"
command -v docker >/dev/null 2>&1 && docker system prune -f >/dev/null 2>&1   # -f not -af: see note above
rm -f "$FPK"
REMOTE
}

# Test upgrade data-preservation for ONE app on the VM.
# Installs the fpk, writes a marker into the app's data dir, then offers the
# SAME package re-versioned as an upgrade and asserts the marker survives.
# Args: appname fpk_url
# Emits `stage=RESULT` lines on stdout.
test_upgrade() {
    _remote_rpc "$1" "$2" "$3" "$FNOS_TEST_VOLUME" "$FNOS_START_TIMEOUT" "$FNOS_MIRROR" <<'REMOTE'
set +e
APP="$1"; URL="$2"; ANSWERS="$3"; VOL="$4"; ST_TO="$5"; MIRROR="$6"
AC=/usr/local/bin/appcenter-cli
FPK="/tmp/fnostest_up_${APP}.fpk"
FPK2="/tmp/fnostest_up_${APP}_v2.fpk"
MARKER="fnostest-$(date +%s)"

$AC uninstall "$APP" >/dev/null 2>&1

DIRECT="$URL"; [ -n "$MIRROR" ] && DIRECT="${URL#$MIRROR}"
dl=FAIL
for u in "$URL" "$DIRECT"; do curl -fsSL --retry 3 --retry-delay 2 --connect-timeout 20 -o "$FPK" "$u" && { dl=PASS; break; }; done
[ "$dl" = PASS ] && echo "download=PASS" || { echo "download=FAIL"; exit 0; }

IFS=$'\t' read -r appname ver ptype installed < <(rpc_stage_fpk "$FPK")
[ -n "$appname" ] && echo "stage=PASS" || { echo "stage=FAIL"; rm -f "$FPK"; exit 0; }

# Install vN with the app's wizard answers (required wizard fields demand them).
st=$(rpc_install "$appname" "$ver" "$ptype" "$VOL" "$ANSWERS" true)
[ "$st" = "2" ] && echo "install=PASS" || echo "install=FAIL:status=$st"

# Wait for the app to reach a stable running state before offering an upgrade.
# A real upgrade targets a settled app, not one mid-startup: the daemon rejects
# update/task with 10500 while the freshly-installed service is still coming up.
for _ in $(seq 1 $((ST_TO/2))); do stt=$($AC status "$APP" 2>/dev/null); [ "$stt" = "running" ] && break; sleep 2; done
echo "settle=$stt"
# Write a marker into the app's data dir (search the known data mounts).
DATA_DIR=""
for d in "/vol${VOL}/@appdata/$appname" "/vol${VOL}/@appconf/$appname"; do
  [ -d "$d" ] && { DATA_DIR="$d"; break; }
done
if [ -n "$DATA_DIR" ]; then
  mkdir -p "$DATA_DIR" && echo "$MARKER" > "$DATA_DIR/.fnostest_marker"
  echo "marker=PASS:$DATA_DIR"
else
  echo "marker=SKIP:no-data-dir"
fi

# Offer the same package re-versioned as an upgrade.
NEWVER="${ver}.1"
if rpc_bump_fpk "$FPK" "$FPK2" "$NEWVER"; then echo "repack=PASS"; else echo "repack=FAIL"; fi
IFS=$'\t' read -r appname2 ver2 ptype2 inst2 < <(rpc_stage_fpk "$FPK2")
ust=$(rpc_upgrade "$appname" "$ver2" "$ptype2")
[ "$ust" = "2" ] && echo "upgrade=PASS" || echo "upgrade=FAIL:status=$ust"

# Marker survived the upgrade?
if [ -n "$DATA_DIR" ] && [ -f "$DATA_DIR/.fnostest_marker" ] && [ "$(cat "$DATA_DIR/.fnostest_marker")" = "$MARKER" ]; then
  echo "data=PASS"
elif [ -z "$DATA_DIR" ]; then
  echo "data=SKIP"
else
  echo "data=FAIL"
fi

s=SLOW; stt=""
for _ in $(seq 1 $((ST_TO/2))); do stt=$($AC status "$APP" 2>/dev/null); [ "$stt" = "running" ] && { s=PASS; break; }; sleep 2; done
echo "start=$s:$stt"

$AC uninstall "$APP" >/dev/null 2>&1 && echo "uninstall=PASS" || echo "uninstall=FAIL"
command -v docker >/dev/null 2>&1 && docker system prune -f >/dev/null 2>&1   # -f not -af: see note above
rm -f "$FPK" "$FPK2"
REMOTE
}
