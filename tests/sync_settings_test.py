import importlib.util
import sys
import tempfile
import textwrap
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parent.parent / "sync-settings.py"
SPEC = importlib.util.spec_from_file_location("sync_settings", SCRIPT)
sync_settings = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
sys.modules[SPEC.name] = sync_settings
SPEC.loader.exec_module(sync_settings)


def file(content):
    """Remove indentation used to make multiline test data readable."""
    return textwrap.dedent(content).lstrip("\n")


def sync(repo, target, base=None):
    """Sync three strings and return the resulting repo, target, and base."""
    with tempfile.TemporaryDirectory() as temp_dir:
        temp = Path(temp_dir)
        repo_path = temp / "repo.conf"
        target_path = temp / "target.conf"
        state_dir = temp / "state"

        repo_path.write_text(repo, encoding="utf-8")
        if target is not None:
            target_path.write_text(target, encoding="utf-8")

        base_path = sync_settings.state_path(repo_path, target_path, state_dir)
        if base is not None:
            base_path.parent.mkdir(parents=True)
            base_path.write_text(base, encoding="utf-8")

        sync_settings.sync(repo_path, target_path, state_dir)

        return (
            repo_path.read_text(encoding="utf-8"),
            target_path.read_text(encoding="utf-8"),
            base_path.read_text(encoding="utf-8"),
        )


class SyncSettingsTests(unittest.TestCase):
    def test_repo_change_is_copied_to_target(self):
        repo = file("""
            # BEGIN_DOTFILES
            theme = dark
            autosave = true
            # END_DOTFILES

            repo_only = unchanged
        """)
        target = file("""
            # BEGIN_DOTFILES
            theme = dark
            # END_DOTFILES

            machine_only = unchanged
        """)
        base = file("""
            # BEGIN_DOTFILES
            theme = dark
            # END_DOTFILES

            old_repo_only = ignored
        """)
        expected_target = file("""
            # BEGIN_DOTFILES
            theme = dark
            autosave = true
            # END_DOTFILES

            machine_only = unchanged
        """)

        repo2, target2, base2 = sync(repo, target, base)

        self.assertEqual(repo, repo2)
        self.assertEqual(expected_target, target2)
        self.assertEqual(repo, base2)

    def test_target_change_is_copied_to_repo(self):
        repo = file("""
            # BEGIN_DOTFILES
            theme = dark
            # END_DOTFILES

            repo_only = unchanged
        """)
        target = file("""
            # BEGIN_DOTFILES
            theme = light
            # END_DOTFILES

            machine_only = unchanged
        """)
        base = file("""
            # BEGIN_DOTFILES
            theme = dark
            # END_DOTFILES
        """)
        expected_repo = file("""
            # BEGIN_DOTFILES
            theme = light
            # END_DOTFILES

            repo_only = unchanged
        """)

        repo2, target2, base2 = sync(repo, target, base)

        self.assertEqual(expected_repo, repo2)
        self.assertEqual(target, target2)
        self.assertEqual(expected_repo, base2)

    def test_changes_to_different_lines_are_combined(self):
        repo = file("""
            # BEGIN_DOTFILES
            theme = dark
            telemetry = false
            font_size = 12
            # END_DOTFILES
        """)
        target = file("""
            # BEGIN_DOTFILES
            theme = system
            telemetry = false
            font_size = 14
            # END_DOTFILES
        """)
        base = file("""
            # BEGIN_DOTFILES
            theme = system
            telemetry = false
            font_size = 12
            # END_DOTFILES
        """)
        expected = file("""
            # BEGIN_DOTFILES
            theme = dark
            telemetry = false
            font_size = 14
            # END_DOTFILES
        """)

        repo2, target2, base2 = sync(repo, target, base)

        self.assertEqual(expected, repo2)
        self.assertEqual(expected, target2)
        self.assertEqual(expected, base2)

    def test_lines_added_on_both_sides_are_combined(self):
        repo = file("""
            # BEGIN_DOTFILES
            repo_content = 1
            common_content = 2
            # END_DOTFILES
        """)
        target = file("""
            # BEGIN_DOTFILES
            common_content = 2
            target_content = 3
            # END_DOTFILES
        """)
        base = file("""
            # BEGIN_DOTFILES
            common_content = 2
            # END_DOTFILES
        """)
        expected = file("""
            # BEGIN_DOTFILES
            repo_content = 1
            common_content = 2
            target_content = 3
            # END_DOTFILES
        """)

        repo2, target2, base2 = sync(repo, target, base)

        self.assertEqual(expected, repo2)
        self.assertEqual(expected, target2)
        self.assertEqual(expected, base2)

    def test_repo_wins_when_the_same_line_conflicts(self):
        repo = file("""
            # BEGIN_DOTFILES
            font_size = 14
            # END_DOTFILES
        """)
        target = file("""
            # BEGIN_DOTFILES
            font_size = 16
            # END_DOTFILES
        """)
        base = file("""
            # BEGIN_DOTFILES
            font_size = 12
            # END_DOTFILES
        """)

        repo2, target2, base2 = sync(repo, target, base)

        self.assertEqual(repo, repo2)
        self.assertEqual(repo, target2)
        self.assertEqual(repo, base2)

    def test_first_sync_uses_repo_as_the_base(self):
        repo = file("""
            # BEGIN_DOTFILES
            theme = dark
            # END_DOTFILES

            repo_only = unchanged
        """)
        target = file("""
            # BEGIN_DOTFILES
            theme = light
            # END_DOTFILES

            machine_only = unchanged
        """)
        expected_repo = file("""
            # BEGIN_DOTFILES
            theme = light
            # END_DOTFILES

            repo_only = unchanged
        """)

        repo2, target2, base2 = sync(repo, target)

        self.assertEqual(expected_repo, repo2)
        self.assertEqual(target, target2)
        self.assertEqual(expected_repo, base2)

    def test_repo_block_is_appended_when_target_has_no_blocks(self):
        repo = file("""
            # BEGIN_DOTFILES:editor
            editor = vim
            # END_DOTFILES:editor

            repo_only = unchanged
        """)
        target = file("""
            machine_only = unchanged
        """)
        expected_target = file("""
            machine_only = unchanged
            # BEGIN_DOTFILES:editor
            editor = vim
            # END_DOTFILES:editor
        """)

        repo2, target2, base2 = sync(repo, target)

        self.assertEqual(repo, repo2)
        self.assertEqual(expected_target, target2)
        self.assertEqual(repo, base2)

    def test_target_block_is_appended_to_repo(self):
        repo = file("""
            # BEGIN_DOTFILES:editor
            editor = vim
            # END_DOTFILES:editor
        """)
        target = file("""
            # BEGIN_DOTFILES:editor
            editor = vim
            # END_DOTFILES:editor

            # BEGIN_DOTFILES:terminal
            shell = zsh
            # END_DOTFILES:terminal

            machine_only = unchanged
        """)
        expected_repo = file("""
            # BEGIN_DOTFILES:editor
            editor = vim
            # END_DOTFILES:editor
            # BEGIN_DOTFILES:terminal
            shell = zsh
            # END_DOTFILES:terminal
        """)

        repo2, target2, base2 = sync(repo, target)

        self.assertEqual(expected_repo, repo2)
        self.assertEqual(target, target2)
        self.assertEqual(expected_repo, base2)

    def test_missing_target_is_created_from_repo(self):
        repo = file("""
            # BEGIN_DOTFILES
            editor = vim
            # END_DOTFILES

            repo_only = unchanged
        """)

        repo2, target2, base2 = sync(repo, None)

        self.assertEqual(repo, repo2)
        self.assertEqual(repo, target2)
        self.assertEqual(repo, base2)

if __name__ == "__main__":
    unittest.main()
