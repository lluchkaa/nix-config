"""Exercise Node initialization in a real Zsh with optional nvm installations."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

TEMPLATE = Path(sys.argv.pop(1)).read_text()
NVM = r'''
printf 'loaded:%s\n' "$*" >> "$NVM_TEST_LOG"
[[ "$1" == --no-use ]] || export PATH="$NVM_TEST_VERSION_BIN:$PATH"
nvm() {
  case "$1" in
    use) export PATH="$NVM_TEST_VERSION_BIN:$PATH" ;;
    current) command node ;;
    *) print -r -- "nvm:$*" ;;
  esac
}
'''


class NodeRuntime(unittest.TestCase):
    def run_shell(self, commands, install=None, custom=False):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            baseline, versioned = root / 'baseline', root / 'versioned'
            for folder, label in [(baseline, 'baseline'), (versioned, 'versioned')]:
                folder.mkdir()
                for name in ['node', 'npm', 'npx']:
                    executable = folder / name
                    executable.write_text(f'#!/bin/sh\necho {label}-{name}\n')
                    executable.chmod(0o755)
            config = root / 'config'
            nvm_dir = root / 'custom-nvm' if custom else config / 'nvm'
            brew = root / 'brew-nvm.sh'
            if install:
                destination = brew if install == 'brew' else nvm_dir / 'nvm.sh'
                destination.parent.mkdir(parents=True, exist_ok=True)
                destination.write_text(NVM)
            init = root / 'init.zsh'
            init.write_text(TEMPLATE.replace('@brewNvm@', f'"{brew}"'))
            log = root / 'nvm.log'
            env = dict(os.environ, HOME=str(root), XDG_CONFIG_HOME=str(config),
                       PATH=f'{baseline}:{os.environ["PATH"]}', NVM_TEST_LOG=str(log),
                       NVM_TEST_VERSION_BIN=str(versioned))
            env.pop('NVM_DIR', None)
            if custom:
                env['NVM_DIR'] = str(nvm_dir)
            result = subprocess.run(['zsh', '-dfc', 'source "$1"; ' + commands, 'node-check', str(init)],
                                    env=env, capture_output=True, text=True, timeout=10)
            return result, log.read_text().splitlines() if log.exists() else []

    def test_node_commands_do_not_load_nvm(self):
        result, log = self.run_shell('node; npm; npx; node', install='user')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(), ['baseline-node', 'baseline-npm', 'baseline-npx', 'baseline-node'])
        self.assertEqual(log, [])

    def test_nvm_loads_once_and_does_not_select_a_default(self):
        result, log = self.run_shell('nvm current; nvm current; node', install='user')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(), ['baseline-node'] * 3)
        self.assertEqual(log, ['loaded:--no-use'])

    def test_explicit_nvm_use_switches_runtime(self):
        result, log = self.run_shell('nvm use 22; node; npm; npx', install='user')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(), ['versioned-node', 'versioned-npm', 'versioned-npx'])
        self.assertEqual(log, ['loaded:--no-use'])

    def test_brew_fallback(self):
        result, log = self.run_shell('nvm current', install='brew')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), 'baseline-node')
        self.assertEqual(log, ['loaded:--no-use'])

    def test_custom_nvm_directory_is_preserved(self):
        result, log = self.run_shell('nvm use 22; node', install='user', custom=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), 'versioned-node')
        self.assertEqual(log, ['loaded:--no-use'])

    def test_missing_nvm_keeps_baseline_and_reports_failure(self):
        result, log = self.run_shell('nvm use 22; result=$?; node; exit $result')
        self.assertEqual(result.returncode, 127)
        self.assertEqual(result.stdout.strip(), 'baseline-node')
        self.assertIn('no installation found', result.stderr)
        self.assertEqual(log, [])


if __name__ == '__main__':
    unittest.main()
