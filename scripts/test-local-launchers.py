"""The local-model launchers refuse loudly and never start a host on another model.

Renders both launcher templates with chezmoi, then runs them against a closed
port, a fake runtime that lacks the model, and a fake runtime that has it. A
fake `claude` and `codex` on PATH record whether they were started.
"""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import json
import os
import subprocess
import tempfile
import threading
import unittest

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "home"
TEMPLATES = SOURCE / "dot_local/bin"
FAKE_HOST = """#!/bin/sh
{ echo "argv: $*"; env | grep -E '^(ANTHROPIC_|CLAUDE_CODE_SUBAGENT_MODEL)' | sort; } > "$FAKE_HOST_LOG"
"""


class Runtime(BaseHTTPRequestHandler):
    """A stand-in runtime: it has a version and exactly the models in `pulled`."""

    pulled: set = set()

    def log_message(self, *arguments):
        pass

    def do_GET(self):
        known = self.path == "/api/version" or self.path.removeprefix("/v1/models/") in self.pulled
        self.send_response(200 if known else 404)
        self.end_headers()
        self.wfile.write(b"{}")


class LauncherTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.base = Path(temporary.name)
        self.log = self.base / "host.log"
        for name in ("claude", "codex"):
            fake = self.base / name
            fake.write_text(FAKE_HOST)
            fake.chmod(0o755)
        for name in ("claude-local", "codex-local"):
            rendered = subprocess.run(
                ["chezmoi", "execute-template", "--source", str(SOURCE)],
                input=(TEMPLATES / f"executable_{name}.tmpl").read_text(),
                capture_output=True, text=True, check=True,
            ).stdout
            (self.base / name).write_text(rendered)
            (self.base / name).chmod(0o755)
        self.server = ThreadingHTTPServer(("127.0.0.1", 0), Runtime)
        threading.Thread(target=self.server.serve_forever, daemon=True).start()
        self.addCleanup(self.server.server_close)
        self.addCleanup(self.server.shutdown)
        self.endpoint = f"http://127.0.0.1:{self.server.server_port}"
        Runtime.pulled = set()

    def launch(self, name, *arguments, endpoint=None):
        env = {
            "PATH": f"{self.base}:/usr/bin:/bin",
            "FAKE_HOST_LOG": str(self.log),
            "LOCAL_MODEL_ENDPOINT": endpoint or self.endpoint,
        }
        return subprocess.run([str(self.base / name), *arguments], env=env, capture_output=True, text=True, timeout=30)

    def families(self):
        data = subprocess.run(
            ["chezmoi", "execute-template", "--source", str(SOURCE), "{{ .local_models | toJson }}"],
            capture_output=True, text=True, check=True,
        ).stdout
        return {family["name"]: family["tag"] for family in json.loads(data)["families"]}

    def test_no_runtime_means_no_session(self):
        for name in ("claude-local", "codex-local"):
            with self.subTest(name):
                result = self.launch(name, endpoint="http://127.0.0.1:9")
                self.assertEqual(result.returncode, 1)
                self.assertIn("refusing to start: no local model runtime answers", result.stderr)
                self.assertFalse(self.log.exists(), "The host was started without a runtime")

    def test_missing_model_means_no_session(self):
        for name in ("claude-local", "codex-local"):
            with self.subTest(name):
                result = self.launch(name)
                self.assertEqual(result.returncode, 1)
                self.assertIn("does not have", result.stderr)
                self.assertFalse(self.log.exists(), "The host was started without its model")

    def test_unknown_family_is_refused(self):
        result = self.launch("claude-local", "-f", "nope")
        self.assertEqual(result.returncode, 2)
        self.assertFalse(self.log.exists())

    def test_each_host_starts_on_the_requested_model_only(self):
        families = self.families()
        self.assertGreaterEqual(len(families), 2, "Two families, so a writer and a reviewer can differ")
        Runtime.pulled = set(families.values())
        for family, tag in families.items():
            with self.subTest(family):
                self.assertEqual(self.launch("claude-local", "-f", family, "-p", "hi").returncode, 0)
                seen = self.log.read_text()
                self.assertIn(f"argv: --model {tag} -p hi", seen)
                self.assertIn(f"ANTHROPIC_BASE_URL={self.endpoint}", seen)
                for variable in ("ANTHROPIC_MODEL", "ANTHROPIC_DEFAULT_HAIKU_MODEL", "CLAUDE_CODE_SUBAGENT_MODEL"):
                    self.assertIn(f"{variable}={tag}", seen, "A background model would leave the local endpoint's model")
                self.assertEqual(self.launch("codex-local", "-f", family, "exec", "hi").returncode, 0)
                self.assertIn(f'model_provider="ollama" -m {tag}', self.log.read_text())

    def test_the_default_model_setting_does_not_read_the_local_block(self):
        merger = (SOURCE / "dot_claude/modify_settings.json.tmpl").read_text()
        self.assertNotIn("local_models", merger, "Local models must never reach the managed settings")


if __name__ == "__main__":
    unittest.main()
