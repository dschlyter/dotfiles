#!/usr/bin/python

# It's the sound of da police!

import subprocess
import sys

import datetime
import argparse

def parse_args():
    parser = argparse.ArgumentParser(description='Walks a git graph and lists all commits that seems to not have been merged with a pull request')
    parser.add_argument('-d', '--days', dest='days', nargs='?', default=14, metavar='days', type=int,
            help='number of days in the history to go back (default 14)')
    parser.add_argument('-f', '--from', dest='from_date',
            help='start from a specific date YYYY-MM-DD')
    parser.add_argument('-a', '--all', dest='all', action='store_true',
            help='scan full project history (ignore days)')

    args = parser.parse_args()
    args.start_date = (datetime.datetime.now() - datetime.timedelta(days=args.days)).isoformat()
    if (args.from_date):
        args.start_date = datetime.datetime.strptime(args.from_date, "%Y-%m-%d").isoformat()
    if (args.all):
        args.start_date = datetime.datetime.strptime("1970-01-01", "%Y-%m-%d").isoformat()
    return args

def run(command):
    if isinstance(command, str):
        command = command.split(" ")
    return subprocess.check_output(command)

args = parse_args()

SPLIT="$S$"

def main():
    commits = run(["git", "log", "--pretty=%ci %an %s "+SPLIT+"%H"+SPLIT+"%P"]).split("\n")
    if len(commits) < 2:
        print "No commits found"
        sys.exit(0)
    commit_index = index(commits)
    head_sha = parse(commits[0])['sha']
    criminal_commits = start_commit_dfs(head_sha, commit_index)
    print_commits(criminal_commits)

def parse(line):
    parts = line.split(SPLIT)
    msg = parts[0]
    sha = parts[1]
    parents = parts[2].split(" ")
    return {'sha': sha, 'msg':msg, 'parents': parents}

def index(commits):
    ret = dict()
    for line in commits:
        if not line:
            continue
        commit = parse(line)
        ret[commit['sha']] = commit
    return ret

def start_commit_dfs(sha, index):
    selected = []
    commit_dfs(sha, index, {}, selected)
    return selected

def commit_dfs(sha, index, visited, selected):
    if not sha or visited.get(sha):
        return
    visited[sha] = True

    commit = index[sha]
    if is_pr(commit):
        # when a pull request is issued the branch that is merged in is always the second parent
        # thus if we follow the first parent, we are still on the original branch
        commit_dfs(commit['parents'][0], index, visited, selected)
    else:
        if not is_old(commit):
            selected.append(commit)
        for parent_sha in commit['parents']:
            commit_dfs(parent_sha, index, visited, selected)

def is_old(commit):
    return args.start_date > commit['msg']

def is_pr(commit):
    return "Merge pull request" in commit['msg']

def print_commits(selected_commits):
    sorted_commits = sorted(selected_commits, key=lambda cm: cm['msg'], reverse=True)
    for commit in sorted_commits:
        print commit['msg']

main()
