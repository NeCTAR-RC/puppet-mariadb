#!/usr/bin/env python
# Copyright (c) 2014 University of Melbourne
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

import os
import re
import sys
import subprocess
import logging

log = logging.getLogger(__file__)

line_matchers = {
    'flake8': re.compile(r'^([^\s]+):([\d]+):[\d]+: '),
    'puppet-lint': re.compile(r'^([^\s]+) - .* ([\d]+)$'),
}


def which(name, flags=os.X_OK):
    """taken from twisted/python/procutils.py"""
    result = []
    exts = filter(None, os.environ.get('PATHEXT', '').split(os.pathsep))
    path = os.environ.get('PATH', None)
    if path is None:
        return []
    for p in os.environ.get('PATH', '').split(os.pathsep):
        p = os.path.join(p, name)
        if os.access(p, flags):
            result.append(p)
        for e in exts:
            pext = p + e
            if os.access(pext, flags):
                result.append(pext)
    return result

try:
    GIT = which('git')[0]
except:
    GIT = ""


def git_diff_linenumbers(filename, revision=None):
    """Return a list of lines that have been added/changed in a file."""
    diff_command = ' '.join(['diff',
                             '--new-line-format="%dn "',
                             '--unchanged-line-format=""',
                             '--changed-group-format="%>"'])
    difftool_command = ["difftool", "-y", "-x", diff_command]

    def _call(*args):
        try:
            lines_output = subprocess.check_output(
                [GIT] + difftool_command + list(args) + ["--", filename])
        except subprocess.CalledProcessError:
            lines_output = ""
        return lines_output

    if revision:
        lines_output = _call(revision)
        return lines_output.split()
    else:
        lines_output = _call()
        # Check any files that are in the cache
        lines_output1 = _call("--cached")
        return lines_output.split() + lines_output1.split()


def lint(args):
    """Run lint checker over a file and return the output"""
    proc = subprocess.Popen(args,
                            stdout=subprocess.PIPE)
    (output, err) = proc.communicate()
    status = proc.wait()
    if status != 0 and len(output) == 0:
        log.exception()
    return output


def git_changed_files(revision=None):
    """Return a list of all the files changed in git"""
    if revision:
        files = subprocess.check_output(
            [GIT, "diff", "--name-only", revision])
        return [filename for filename in files.split('\n')
                if filename]
    else:
        files = subprocess.check_output(
            [GIT, "diff", "--name-only"])
        cached_files = subprocess.check_output(
            [GIT, "diff", "--name-only", "--cached"])
        return [filename for filename
                in set(files.split('\n')) | set(cached_files.split('\n'))
                if filename]


def list_all_files():
    for path, subdirs, files in os.walk(git_repository_root()):
        for name in files:
            yield os.path.join(path, name)


def git_repository_root():
    return subprocess.check_output(
        [GIT, "rev-parse", '--show-toplevel']).strip()


def git_current_rev():
    return subprocess.check_output([GIT, "rev-parse", "HEAD^"]).strip()


class AnyLine():
    def __init__(self, filename, revision):
        pass

    def __contains__(self, x):
        return True

WHITE_LIST = [re.compile(r'.*')]
BLACK_LIST = []

SPECIAL_CASE_ARGS = {}


def check_files(executable, line_match, revision=None,
                changed_lines=git_diff_linenumbers):
    exit_status = 0
    skipped_lines = 0
    lint_output = lint(executable)

    for line in lint_output.split('\n'):
        line_details = line_match.match(line)
        if not line_details:
            print line
            continue
        filename, lineno = line_details.groups()

        if not all(map(lambda x: x.match(filename),
                       WHITE_LIST)):
            log.info('SKIPPING %s' % filename)
            continue
        if any(map(lambda x: x.match(filename),
                   BLACK_LIST)):
            log.info('SKIPPING %s' % filename)
            continue
        included_lines = changed_lines(filename, revision)

        if lineno in included_lines:
            print line
            exit_status = 1
        else:
            skipped_lines += 1

    if skipped_lines > 0:
        print "....Skipped %s lines....." % skipped_lines
    sys.exit(exit_status)


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument(
        '-v', '--verbose', action='count', default=0,
        help='Increase verbosity (specify multiple times for more).')
    parser.add_argument(
        '-a', '--all', action='store_true', default=False,
        help='Check the entire repository, not just changed files.')
    parser.add_argument(
        '--linter', choices=line_matchers.keys(),
        default='puppet-lint')
    parser.add_argument(
        'executable',
        metavar='ARG', nargs='+',
        help='The executable to run, and any desired arguments.')
    parser.add_argument(
        '-g', '--git-executable', action='store', default=GIT,
        help='The executable to run.')

    args = parser.parse_args()

    log_level = logging.WARNING
    if args.verbose == 1:
        log_level = logging.INFO
    elif args.verbose >= 2:
        log_level = logging.DEBUG

    logging.basicConfig(level=log_level, format='%(message)s')

    if args.all:
        revision = None
        files = list_all_files()
        changed_lines = AnyLine
    else:
        revision = git_current_rev()
        files = git_changed_files(revision)
        changed_lines = git_diff_linenumbers

    if not args.executable:
        parser.error("No executable specified.")

    if not os.path.exists(which(args.executable[0])[0]):
        parser.error("Can't find executable at %s." % args.executable[0])

    GIT = args.git_executable
    if not os.path.exists(GIT):
        parser.error("Can't find executable at %s." % GIT)

    check_files(
        args.executable,
        line_matchers[args.linter],
        revision=revision,
        changed_lines=changed_lines)
