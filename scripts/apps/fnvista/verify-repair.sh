#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
python3 - "$REPO_ROOT" "${1:?需要上游 FPK}" "${2:?需要构建目录}" "${3:-}" <<'PY'
import hashlib
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tarfile
import tempfile

repo, upstream, output = map(Path, sys.argv[1:4])

def members(path: Path) -> dict[str, bytes]:
    """Read archive file bytes without extracting untrusted paths."""
    result: dict[str, bytes] = {}
    with tarfile.open(path, "r:gz") as archive:
        for entry in archive:
            if entry.isfile():
                stream = archive.extractfile(entry)
                assert stream is not None
                with stream:
                    result[entry.name.removeprefix("./")] = stream.read()
    return result

original = members(upstream)
for arch in ("x86", "arm"):
    package = output / f"fnos-bing-wallpaper_1.0.1-r1_{arch}.fpk"
    built = members(package)
    assert built["app.tgz"] == original["app.tgz"], "upstream payload changed"
    with tarfile.open(fileobj=io.BytesIO(built["app.tgz"]), mode="r:gz") as payload:
        for entry in payload:
            if entry.isfile():
                stream = payload.extractfile(entry)
                assert stream is not None
                with stream:
                    assert stream.read(4) != b"\x7fELF", "unexpected architecture-bound ELF"
    for name, value in original.items():
        if name not in {"manifest", "cmd/uninstall_callback"}:
            assert built[name] == value, f"upstream control changed: {name}"
        if name.startswith(("config/", "wizard/")):
            json.loads(value)
        if name.startswith("cmd/"):
            subprocess.run(["bash", "-n"], input=value, check=True)
    assert built["cmd/uninstall_upstream"] == original["cmd/uninstall_callback"]
    assert set(built) - set(original) == {
        "cmd/uninstall_upstream", "cmd/uninstall-quiesce", "LICENSE",
    }
    manifest = dict(
        line.split("=", 1) for line in built["manifest"].decode().splitlines()
        if "=" in line and not line.startswith("#")
    )
    fields = {key.strip(): value.strip() for key, value in manifest.items()}
    assert fields["version"] == "1.0.1-r1"
    assert fields["platform"] == "all"
    assert fields["appname"] == "fnos-bing-wallpaper"
    assert fields["checksum"] == hashlib.md5(built["app.tgz"]).hexdigest()
    expected_manifest = original["manifest"].splitlines(keepends=True)
    expected_manifest = [
        b"version                    = 1.0.1-r1\n"
        if line.startswith(b"version ") else line for line in expected_manifest
    ]
    assert built["manifest"] == b"".join(expected_manifest)
    for name in ("uninstall_callback", "uninstall-quiesce"):
        assert built[f"cmd/{name}"] == (repo / "apps/fnvista/fnos/cmd" / name).read_bytes()
    print(f"PASS {arch}: payload SHA256 {hashlib.sha256(built['app.tgz']).hexdigest()}")
    print(f"PASS {arch}: FPK SHA256 {hashlib.sha256(package.read_bytes()).hexdigest()}")

cmd = repo / "apps/fnvista/fnos/cmd"

def embedded(name: str) -> str:
    """Run the shipped Python block, not a copied implementation."""
    return (cmd / name).read_text().split("<<'PY'\n", 1)[1].split("\nPY", 1)[0]

with tempfile.TemporaryDirectory(prefix="fnvista-behavior-") as temporary:
    root = Path(temporary)
    page = root / "index.html"
    clean = b'<html>\xff\r\n<style data-id="fnos-bing-wp-css">other</style></html>\n'
    injected = clean.replace(
        b"</html>",
        b'<style id="fnos-bing-wp-css">app css</style>'
        b'<script id="fnos-bing-wp-js">app\njs</script></html>',
    )
    page.write_bytes(injected)
    html_args = [sys.executable, "-", str(root / "absent.html"), str(page), str(root / "absent.zip")]
    subprocess.run(html_args, input=embedded("uninstall_callback"),
                   text=True, check=True)
    assert page.read_bytes() == clean, "HTML cleanup damaged unrelated bytes"
    subprocess.run(html_args, input=embedded("uninstall_callback"),
                   text=True, check=True)
    assert page.read_bytes() == clean, "HTML cleanup is not idempotent"
    print("PASS HTML: exact marker removal, unrelated bytes, repeat invocation")
    if sys.argv[4]:
        evidence = Path(sys.argv[4])
        page.write_bytes((evidence / "index-after-uninstall.html").read_bytes())
        subprocess.run(html_args, input=embedded("uninstall_callback"),
                       text=True, check=True)
        baseline = json.loads((evidence / "baseline.json").read_bytes())
        expected = baseline["files"]["/usr/trim/www/index.html"]["sha256"]
        assert hashlib.sha256(page.read_bytes()).hexdigest() == expected
        print(f"PASS recorded VM HTML: exact preinstall SHA256 {expected}")

    # Rooted fixture paths are substituted only for host filesystem isolation.
    # The shipped shell branching, copy operations and HTML/zip logic execute.
    for restore in ("true", "false", "unset"):
        sandbox = root / restore
        (sandbox / "cmd").mkdir(parents=True)
        www = sandbox / "usr/trim/www"
        (www / "static/bg").mkdir(parents=True)
        (www / "static/thumbnail_bg").mkdir()
        orig = sandbox / "var/lib/fnos-wallpaper/orig"
        orig.mkdir(parents=True)
        for backup, target in (
            ("wallpaper-1.webp.orig", "static/bg/wallpaper-1.webp"),
            ("thumb-1.webp.orig", "static/thumbnail_bg/wallpaper-1.webp"),
        ):
            (orig / backup).write_bytes(b"original " + backup.encode())
            (www / target).write_bytes(b"applied " + backup.encode())
        (www / "index.html").write_bytes(injected)
        # An actual zip update is required so cached system extraction is covered.
        zipdir = sandbox / "usr/trim/share/.restore"
        zipdir.mkdir(parents=True)
        subprocess.run(["zip", "-q", str(zipdir / "www.zip"), "index.html"],
                       cwd=www, check=True)
        source = (cmd / "uninstall_callback").read_text()
        source = source.replace("/usr/trim/", f"{sandbox}/usr/trim/")
        source = source.replace("/var/lib/fnos-wallpaper/", f"{sandbox}/var/lib/fnos-wallpaper/")
        source = source.replace("/usr/bin/chattr", f"{sandbox}/usr/bin/chattr")
        source = source.replace("/usr/sbin/chattr", f"{sandbox}/usr/sbin/chattr")
        source = source.replace("/sbin/chattr", f"{sandbox}/sbin/chattr")
        (sandbox / "cmd/uninstall_callback").write_text(source)
        (sandbox / "cmd/uninstall-quiesce").write_text("#!/bin/bash\nexit 0\n")
        (sandbox / "cmd/uninstall_upstream").write_text(
            '#!/bin/bash\nprintf upstream > "$(dirname "$0")/receipt"\n',
        )
        environment = dict(os.environ)
        environment.pop("wizard_restore", None)
        if restore != "unset":
            environment["wizard_restore"] = restore
        subprocess.run(["bash", str(sandbox / "cmd/uninstall_callback")],
                       env=environment, check=True)
        for backup, target in (
            ("wallpaper-1.webp.orig", "static/bg/wallpaper-1.webp"),
            ("thumb-1.webp.orig", "static/thumbnail_bg/wallpaper-1.webp"),
        ):
            prefix = b"applied " if restore == "false" else b"original "
            assert (www / target).read_bytes() == prefix + backup.encode()
        assert (www / "index.html").read_bytes() == clean
        archived = subprocess.check_output(["unzip", "-p", str(zipdir / "www.zip"), "index.html"])
        assert archived == clean, "restore archive can reintroduce HTML injection"
        assert (sandbox / "cmd/receipt").read_bytes() == b"upstream"
        print(f"PASS restore={restore}: exact wallpaper branch, live/archive HTML, upstream call")

    helper = root / "fnos-wallpaper-watchdog.sh"
    helper.write_text('sleep 300 &\necho $!\nwait\n')
    writer = subprocess.Popen(["bash", str(helper)], stdout=subprocess.PIPE, text=True)
    unrelated = subprocess.Popen(["sleep", "300"])
    try:
        # The writer emits the PID only after its child has been created.
        assert writer.stdout is not None
        child = int(writer.stdout.readline())
        subprocess.run([sys.executable, "-", str(root)], input=embedded("uninstall-quiesce"),
                       text=True, check=True, timeout=10)
        assert writer.wait(timeout=5) == -9, "app writer survived"
        child_state = subprocess.run(["ps", "-o", "stat=", "-p", str(child)],
                                     capture_output=True, text=True)
        assert not child_state.stdout.strip() or child_state.stdout.strip().startswith("Z")
        assert unrelated.poll() is None, "unrelated process killed"
        print("PASS quiesce: writer and descendant terminated, unrelated process preserved")
    finally:
        for process in (writer, unrelated):
            if process.poll() is None:
                process.kill()
            process.wait()
        if writer.stdout is not None:
            writer.stdout.close()
print("PASS dedicated repair verification (host sandbox, not fnOS VM QA)")
PY
