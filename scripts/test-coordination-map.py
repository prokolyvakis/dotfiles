"""The managed-mode coordination map names every declared Claude plugin exactly once."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


def declared_plugins():
    lines = (ROOT / "home/.chezmoidata.yaml").read_text().splitlines()
    start = lines.index("    plugins:") + 1
    plugins = []
    for line in lines[start:]:
        match = re.fullmatch(r"      - (\S+)", line)
        if not match:
            break
        plugins.append(match[1])
    return plugins


def managed_rows():
    text = (ROOT / "home/dot_claude/coordination.md").read_text()
    section = text.split("## Managed mode", 1)[1].split("\n## ", 1)[0]
    return re.findall(r"^\| `([^`]+)` \|", section, re.M)


class CoordinationMapTests(unittest.TestCase):
    def test_every_declared_plugin_has_one_managed_rule(self):
        declared = declared_plugins()
        self.assertEqual(len(declared), 25)
        rows = managed_rows()
        self.assertEqual(len(rows), len(set(rows)), "Duplicate managed-mode row")
        bare = {plugin.split("@")[0] for plugin in declared}
        named = {row.split("@")[0] for row in rows}
        self.assertEqual(named, bare)


if __name__ == "__main__":
    unittest.main()
