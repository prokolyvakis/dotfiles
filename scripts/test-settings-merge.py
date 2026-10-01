#!/usr/bin/env python3
"""Exercise the rendered ~/.claude/settings.json merger in a synthetic home.

Runs the real chezmoi template (home/dot_claude/modify_settings.json.tmpl) with
HOME pointed at a temporary directory, both as the rendered script and through
`chezmoi apply`, so the checks observe output bytes and preserved input rather
than the template text. No live settings, state or config are touched.
"""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]
SOURCE = REPO / "home"
TEMPLATE = SOURCE / "dot_claude" / "modify_settings.json.tmpl"
TARGET = Path(".claude") / "settings.json"


class SettingsMergeTests(unittest.TestCase):
    def setUp(self):
        self.assertIsNotNone(shutil.which("chezmoi"), "chezmoi is required")
        self.temporary = tempfile.TemporaryDirectory(prefix="dotfiles merge ")
        self.addCleanup(self.temporary.cleanup)
        self.home = Path(self.temporary.name).resolve() / "home with spaces"
        (self.home / ".claude").mkdir(parents=True)
        self.env = {
            "PATH": os.environ["PATH"], "HOME": str(self.home),
            "XDG_CONFIG_HOME": str(self.home / ".config"),
            "XDG_DATA_HOME": str(self.home / ".local/share"),
        }
        rendered = subprocess.run(
            ["chezmoi", "execute-template", f"--source={SOURCE}"],
            input=TEMPLATE.read_text(encoding="utf-8"), cwd=REPO, env=self.env,
            text=True, capture_output=True, check=True)
        self.script = self.home / "rendered_modify.py"
        self.script.write_text(rendered.stdout, encoding="utf-8")
        self.data = json.loads(subprocess.run(
            ["chezmoi", "execute-template", f"--source={SOURCE}", "{{ .agents.claude | toJson }}"],
            cwd=REPO, env=self.env, text=True, capture_output=True, check=True).stdout)

    def merge(self, text):
        return subprocess.run([sys.executable, str(self.script)], input=text, text=True,
                              capture_output=True, timeout=15)

    def apply(self):
        """Run the real chezmoi apply for the settings target only, isolated in the synthetic home."""
        return subprocess.run(
            ["chezmoi", "apply", f"--source={SOURCE}", f"--destination={self.home}",
             f"--persistent-state={self.home / 'state.boltdb'}", "--force",
             str(self.home / TARGET)],
            cwd=REPO, env=self.env, text=True, capture_output=True, timeout=60)

    def settings_file(self):
        return self.home / TARGET

    # CFG-01: invalid JSON is rejected without replacement output.
    def test_invalid_json_fails_without_output(self):
        for text in ("{not json", "[]", '{"enabledPlugins": []}',
                     '{"extraKnownMarketplaces": "x"}', "null"):
            with self.subTest(text=text):
                result = self.merge(text)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(result.stdout, "")
                self.assertIn("leaving settings.json unchanged", result.stderr)

    def test_invalid_json_leaves_file_untouched_through_chezmoi(self):
        original = b'{ "model": "user-choice", broken\n'
        self.settings_file().write_bytes(original)
        result = self.apply()
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.settings_file().read_bytes(), original)

    # CFG-02 / CFG-03: valid input changes only owned keys; disables and unknown entries survive.
    def test_valid_merge_changes_only_owned_keys(self):
        managed_plugin = self.data["plugins"][0]
        existing = {
            "permissions": {"allow": ["Bash(git status)"]},
            "hooks": {"Stop": [{"hooks": [{"type": "command", "command": "peon.sh"}]}]},
            "customKey": {"nested": [1, 2, 3]},
            "model": "user-choice",
            "enabledPlugins": {managed_plugin: False, "unknown@elsewhere": True},
            "extraKnownMarketplaces": {"other": {"source": {"source": "github", "repo": "x/y"}}},
        }
        result = self.merge(json.dumps(existing))
        self.assertEqual(result.returncode, 0, result.stderr)
        merged = json.loads(result.stdout)
        for key in ("permissions", "hooks", "customKey"):
            self.assertEqual(merged[key], existing[key])
        for key, value in self.data["settings"].items():
            self.assertEqual(merged[key], value)
        self.assertIs(merged["enabledPlugins"][managed_plugin], False, "explicit disable preserved")
        self.assertIs(merged["enabledPlugins"]["unknown@elsewhere"], True)
        for plugin in self.data["plugins"][1:]:
            self.assertIs(merged["enabledPlugins"][plugin], True)
        self.assertEqual(merged["extraKnownMarketplaces"]["other"], existing["extraKnownMarketplaces"]["other"])
        self.assertEqual(merged["statusLine"]["command"], f"bash {self.home}/.claude/statusline-command.sh")
        record = json.loads(result.stderr.split("owned values changed ", 1)[1])
        self.assertEqual(record["before"]["model"], "user-choice")
        self.assertNotIn("customKey", record["before"])
        self.assertNotIn(f"enabledPlugins.{managed_plugin}", record["after"])

    def test_empty_input_initialises(self):
        result = self.merge("")
        self.assertEqual(result.returncode, 0, result.stderr)
        merged = json.loads(result.stdout)
        self.assertEqual(set(self.data["plugins"]), set(merged["enabledPlugins"]))

    # CFG-04: a directory marketplace whose path is missing is unavailable, not registered.
    def test_missing_directory_source_is_not_registered(self):
        local = [m for m in self.data["marketplaces"] if "source_path" in m]
        self.assertTrue(local, "profile declares a directory marketplace")
        name = local[0]["name"]
        result = self.merge("{}")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn(name, json.loads(result.stdout)["extraKnownMarketplaces"])
        self.assertIn(f"marketplace {name}", result.stderr)
        existing = {"extraKnownMarketplaces": {name: {"source": {"source": "directory", "path": "/elsewhere"}}}}
        result = self.merge(json.dumps(existing))
        self.assertEqual(json.loads(result.stdout)["extraKnownMarketplaces"][name]["source"]["path"], "/elsewhere")
        (self.home / local[0]["source_path"]).mkdir(parents=True)
        result = self.merge("{}")
        self.assertEqual(json.loads(result.stdout)["extraKnownMarketplaces"][name]["source"]["path"],
                         str(self.home / local[0]["source_path"]))
        github = [m for m in self.data["marketplaces"] if "source" in m and m["name"] != "claude-plugins-official"]
        for market in github:
            self.assertEqual(json.loads(result.stdout)["extraKnownMarketplaces"][market["name"]]["source"]["repo"],
                             market["source"])

    # CFG-05: repeated apply through chezmoi is byte-stable and preserves a later unowned edit.
    def test_repeated_apply_is_stable_and_preserves_unowned_edits(self):
        self.settings_file().write_text(json.dumps({"permissions": {"allow": ["Bash(ls)"]}}, indent=2) + "\n")
        first = self.apply()
        self.assertEqual(first.returncode, 0, first.stdout + first.stderr)
        once = self.settings_file().read_bytes()
        merged = json.loads(once)
        self.assertEqual(merged["permissions"], {"allow": ["Bash(ls)"]})
        self.assertEqual(merged["model"], self.data["settings"]["model"])
        second = self.apply()
        self.assertEqual(second.returncode, 0, second.stdout + second.stderr)
        self.assertEqual(self.settings_file().read_bytes(), once)
        self.assertNotIn("owned values changed", second.stderr)
        merged["permissions"]["allow"].append("Bash(pwd)")
        merged["enabledPlugins"][self.data["plugins"][0]] = False
        self.settings_file().write_text(json.dumps(merged, indent=2) + "\n")
        third = self.apply()
        self.assertEqual(third.returncode, 0, third.stdout + third.stderr)
        final = json.loads(self.settings_file().read_text())
        self.assertEqual(final["permissions"]["allow"], ["Bash(ls)", "Bash(pwd)"])
        self.assertIs(final["enabledPlugins"][self.data["plugins"][0]], False)
        self.assertFalse((Path.home() / ".config/chezmoi").exists() and
                         str(Path.home()) == str(self.home), "no state outside the synthetic home")


    # CFG-05 / rollback: re-applying an earlier profile touches only the owned
    # values it changed and keeps a user edit made in between; nothing else is
    # deleted.
    def test_profile_rollback_preserves_concurrent_unowned_edit(self):
        existing = {
            "hooks": {"Stop": [{"hooks": [{"type": "command", "command": "peon.sh"}]}]},
            "permissions": {"allow": ["Bash(ls)"]},
            "enabledPlugins": {"user-plugin@elsewhere": True},
        }
        current = json.loads(self.merge(json.dumps(existing)).stdout)
        current["permissions"]["allow"].append("Bash(pwd)")          # concurrent unowned edit
        current["enabledPlugins"]["user-plugin@elsewhere"] = False    # concurrent user decision
        previous_source = Path(self.temporary.name) / "previous source"
        shutil.copytree(SOURCE, previous_source)
        data = previous_source / ".chezmoidata.yaml"
        text = data.read_text(encoding="utf-8")
        self.assertIn(f'model: "{self.data["settings"]["model"]}"', text)
        data.write_text(text.replace(f'model: "{self.data["settings"]["model"]}"', 'model: "previous-model"'),
                        encoding="utf-8")
        rendered = subprocess.run(
            ["chezmoi", "execute-template", f"--source={previous_source}"],
            input=TEMPLATE.read_text(encoding="utf-8"), cwd=REPO, env=self.env,
            text=True, capture_output=True, check=True)
        script = self.home / "previous_modify.py"
        script.write_text(rendered.stdout, encoding="utf-8")
        result = subprocess.run([sys.executable, str(script)], input=json.dumps(current), text=True,
                                capture_output=True, timeout=15)
        self.assertEqual(result.returncode, 0, result.stderr)
        rolled = json.loads(result.stdout)
        self.assertEqual(rolled["model"], "previous-model")
        self.assertEqual(rolled["permissions"]["allow"], ["Bash(ls)", "Bash(pwd)"])
        self.assertEqual(rolled["hooks"], existing["hooks"])
        self.assertIs(rolled["enabledPlugins"]["user-plugin@elsewhere"], False)
        for plugin in self.data["plugins"]:
            self.assertIn(plugin, rolled["enabledPlugins"])
        record = json.loads(result.stderr.split("owned values changed ", 1)[1])
        self.assertEqual(set(record["before"]), {"model"}, "only the owned value that changed is recorded")


if __name__ == "__main__":
    unittest.main()
