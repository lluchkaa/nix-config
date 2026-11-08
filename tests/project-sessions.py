"""Run the project-session command against temporary projects and command adapters."""
import json
import os
from pathlib import Path
import subprocess
import shutil
import sys
import tempfile
import unittest

SESSIONIZER = Path(sys.argv.pop(1)).resolve()
REAL_TMUX = sys.argv.pop(1) if len(sys.argv) > 1 else None
STUB = r'''#!/usr/bin/env python3
import json, os, sys, subprocess
from pathlib import Path
name, args = Path(sys.argv[0]).name, sys.argv[1:]
with open(os.environ['CALL_LOG'], 'a') as log:
    log.write(json.dumps([name, args]) + '\n')
if name == 'fzf':
    paths = sys.stdin.buffer.read().decode().split('\0')[:-1]
    with open(os.environ['CALL_LOG'], 'a') as log:
        log.write(json.dumps(['candidates', paths]) + '\n')
    if os.environ.get('CANCEL'): sys.exit(130)
    pick = os.environ['PICK']
    assert pick in paths, (pick, paths)
    sys.stdout.buffer.write((pick + '\0').encode())
elif name == 'pgrep':
    raise AssertionError('Process-global tmux detection is forbidden')
elif name == 'tmux':
    if os.environ.get('REAL_TMUX_SOCKET') and args[0] in ['has-session', 'new-session']:
        sys.exit(subprocess.run([os.environ['REAL_TMUX_BIN'], '-S', os.environ['REAL_TMUX_SOCKET'], '-f', '/dev/null', *args]).returncode)
    state = Path(os.environ['SESSION_STATE'])
    sessions = json.loads(state.read_text()) if state.exists() else {}
    if args[0] == 'has-session':
        sys.exit(0 if args[-1].removeprefix('=') in sessions else 1)
    if args[0] == 'new-session':
        if os.environ.get('CREATE_FAIL'): sys.exit(2)
        sessions[args[args.index('-s') + 1]] = args[args.index('-c') + 1]
        state.write_text(json.dumps(sessions))
        if os.environ.get('CREATE_RACE'): sys.exit(1)
'''


class ProjectSessions(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name).resolve()
        self.home = self.root / 'home'
        self.projects = self.home / 'projects'
        self.projects.mkdir(parents=True)
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        stub = self.bin / 'stub'
        stub.write_text(STUB)
        stub.chmod(0o755)
        for name in ['tmux', 'fzf', 'pgrep']:
            (self.bin / name).symlink_to(stub)
        self.log = self.root / 'calls.jsonl'
        self.state = self.root / 'sessions.json'

    def project(self, relative, worktree=False):
        path = self.projects / relative
        path.mkdir(parents=True)
        if worktree:
            (path / '.git').write_text('gitdir: /example/main/.git/worktrees/branch\n')
        else:
            (path / '.git').mkdir()
        return path

    def run_sessionizer(self, project=None, **overrides):
        env = dict(os.environ, HOME=str(self.home), TMUX='', CALL_LOG=str(self.log),
                   SHELL=shutil.which('bash'),
                   SESSION_STATE=str(self.state), PATH=f'{self.bin}:{os.environ["PATH"]}')
        env.update(overrides)
        args = ['bash', str(SESSIONIZER)]
        if project is not None:
            args.append(str(project))
        return subprocess.run(args, env=env, cwd=self.root, capture_output=True, text=True, timeout=10)

    def calls(self, name):
        if not self.log.exists():
            return []
        return [args for command, args in map(json.loads, self.log.read_text().splitlines()) if command == name]

    def test_duplicate_basenames_get_distinct_sessions(self):
        for path in ['client-a/api', 'client-b/api']:
            result = self.run_sessionizer(self.project(path))
            self.assertEqual(result.returncode, 0, result.stderr)
        sessions = json.loads(self.state.read_text())
        self.assertEqual(len(sessions), 2)
        self.assertTrue(all(name.startswith('api-') for name in sessions))

    def test_alias_and_existing_session_share_identity(self):
        project = self.project('real project')
        alias = self.root / 'alias'
        alias.symlink_to(project, target_is_directory=True)
        self.assertEqual(self.run_sessionizer(project).returncode, 0)
        self.assertEqual(self.run_sessionizer(alias, TMUX='selected-server,1,0').returncode, 0)
        calls = self.calls('tmux')
        self.assertEqual(sum(args[0] == 'new-session' for args in calls), 1)
        self.assertEqual(sum(args[0] == 'attach-session' for args in calls), 1)
        self.assertEqual(sum(args[0] == 'switch-client' for args in calls), 1)
        self.assertEqual(list(json.loads(self.state.read_text()).values()), [str(project)])

    def test_discovery_includes_worktrees_and_prunes_dependencies(self):
        selected = self.project('company/branch with spaces', worktree=True)
        self.project('company/node_modules/ignored')
        result = self.run_sessionizer(PICK=str(selected))
        self.assertEqual(result.returncode, 0, result.stderr)
        candidates = self.calls('candidates')[0]
        self.assertIn(str(selected), candidates)
        self.assertNotIn(str(self.projects / 'company/node_modules/ignored'), candidates)
        self.assertEqual(self.calls('fzf'), [['--read0', '--print0']])

    def test_cancel_is_successful_and_never_touches_tmux(self):
        self.project('one')
        self.assertEqual(self.run_sessionizer(CANCEL='1').returncode, 0)
        self.assertEqual(self.calls('tmux'), [])

    def test_missing_project_fails_before_tmux(self):
        self.assertNotEqual(self.run_sessionizer(self.root / 'missing').returncode, 0)
        self.assertEqual(self.calls('tmux'), [])

    def test_concurrent_creation_reuses_the_session(self):
        result = self.run_sessionizer(self.project('race'), CREATE_RACE='1')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls('tmux')[-1][0], 'attach-session')

    def test_creation_failure_does_not_attach(self):
        result = self.run_sessionizer(self.project('failure'), CREATE_FAIL='1')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(any(args[0] == 'attach-session' for args in self.calls('tmux')))

    def test_relative_path_ignores_cdpath(self):
        project = self.project('relative')
        result = self.run_sessionizer(project.relative_to(self.root), CDPATH='/nonexistent')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(list(json.loads(self.state.read_text()).values()), [str(project)])

    @unittest.skipUnless(REAL_TMUX, 'real tmux path not supplied')
    def test_real_server_creates_and_reuses_exact_session(self):
        socket = self.root / 'tmux.sock'
        def cleanup():
            subprocess.run([REAL_TMUX, '-S', str(socket), 'kill-server'], capture_output=True)
        self.addCleanup(cleanup)
        project = self.project('real-server')
        for _ in range(2):
            result = self.run_sessionizer(project, REAL_TMUX_BIN=REAL_TMUX, REAL_TMUX_SOCKET=str(socket))
            self.assertEqual(result.returncode, 0, result.stderr)
        result = subprocess.run([REAL_TMUX, '-S', str(socket), 'list-sessions', '-F', '#{session_name}'],
                                capture_output=True, text=True, check=True)
        self.assertEqual(len(result.stdout.splitlines()), 1)
        self.assertTrue(result.stdout.startswith('real-server-'))


if __name__ == '__main__':
    unittest.main()
