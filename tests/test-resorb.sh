#!/bin/bash
set -euo pipefail

# Test script for git resorb
# Creates temporary repos in /tmp and cleans up after

SCRIPT_DIR="$HOME/.git-scripts"
TEST_DIR="/tmp/test-resorb-$$"
REMOTE_DIR="$TEST_DIR/remote.git"
REPO_DIR="$TEST_DIR/repo"

cleanup() {
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

setup_remote_repo() {
    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR"

    # Create a bare remote
    git init --bare "$REMOTE_DIR" 2>/dev/null

    # Clone it as our working repo
    git clone "$REMOTE_DIR" "$REPO_DIR" 2>/dev/null
    cd "$REPO_DIR"

    # Initial commits on master
    git commit --allow-empty -m "initial" 2>/dev/null
    echo "base" > base.txt
    git add .
    git commit -m "base file"
    git push 2>/dev/null
}

# ============================================================
echo "=== Test 1: Basic resorb with explicit branch name ==="
# ============================================================

setup_remote_repo
cd "$REPO_DIR"

# Create feature branch with 5 commits
git checkout -b feature
echo "aaa" > a.txt && git add . && git commit -m "commit A"
echo "bbb" > b.txt && git add . && git commit -m "commit B (to sprout)"
echo "ccc" > c.txt && git add . && git commit -m "commit C"
echo "ddd" > d.txt && git add . && git commit -m "commit D (to sprout)"
echo "eee" > e.txt && git add . && git commit -m "commit E"

# Sprout B and D to feature-auth
COMMIT_B=$(git log --oneline | grep "commit B" | awk '{print $1}')
COMMIT_D=$(git log --oneline | grep "commit D" | awk '{print $1}')
"$SCRIPT_DIR/sprout" feature-auth "$COMMIT_B" "$COMMIT_D"

# Squash-merge to master (simulating GitHub squash merge)
git checkout master
git merge --squash feature-auth
git commit -m "squash: B + D"
git push 2>/dev/null

# Now resorb
git checkout feature
"$SCRIPT_DIR/resorb" feature-auth

# Verify: feature should have 3 commits on top of master (A, C, E)
COUNT=$(git rev-list master..feature | wc -l | tr -d ' ')
[[ "$COUNT" == "3" ]] || fail "Expected 3 commits on feature, got $COUNT"

# Verify: all files should exist
for f in a.txt b.txt c.txt d.txt e.txt base.txt; do
    [[ -f "$f" ]] || fail "Missing file: $f"
done

# Verify: feature-auth branch should be deleted
if git rev-parse --verify feature-auth 2>/dev/null; then
    fail "feature-auth branch should have been deleted"
fi

# Verify: feature is now based on master
git merge-base --is-ancestor master feature || fail "feature should be based on master"

# Verify: working tree is clean (no staged deletions)
DIRTY=$(git status --porcelain)
[[ -z "$DIRTY" ]] || fail "Working tree should be clean, got: $DIRTY"

pass "Basic resorb"

# ============================================================
echo ""
echo "=== Test 1b: Resorb preserves uncommitted changes ==="
# ============================================================

setup_remote_repo
cd "$REPO_DIR"

git checkout -b feature
echo "aaa" > a.txt && git add . && git commit -m "commit A"
echo "bbb" > b.txt && git add . && git commit -m "commit B (to sprout)"
echo "ccc" > c.txt && git add . && git commit -m "commit C"

COMMIT_B=$(git log --oneline | grep "commit B" | awk '{print $1}')
"$SCRIPT_DIR/sprout" feature-auth "$COMMIT_B"

git checkout master
git merge --squash feature-auth
git commit -m "squash: B"
git push 2>/dev/null

git checkout feature
# Add uncommitted changes
echo "wip" > wip.txt

"$SCRIPT_DIR/resorb" feature-auth

# Verify: uncommitted file is preserved
[[ -f wip.txt ]] || fail "Uncommitted file wip.txt should be preserved"
[[ "$(cat wip.txt)" == "wip" ]] || fail "Uncommitted file content should be preserved"

# Verify: no unexpected staged deletions
DELETIONS=$(git status --porcelain | grep "^D" || true)
[[ -z "$DELETIONS" ]] || fail "Should have no staged deletions, got: $DELETIONS"

pass "Resorb preserves uncommitted changes"

# ============================================================
echo ""
echo "=== Test 2: Auto-detect sprouted branch (upstream gone) ==="
# ============================================================

setup_remote_repo
cd "$REPO_DIR"

# Create feature branch
git checkout -b feature
echo "aaa" > a.txt && git add . && git commit -m "commit A"
echo "bbb" > b.txt && git add . && git commit -m "commit B (to sprout)"
echo "ccc" > c.txt && git add . && git commit -m "commit C"
git push -u origin feature 2>/dev/null

# Sprout B to feature-auth and push it
COMMIT_B=$(git log --oneline | grep "commit B" | awk '{print $1}')
"$SCRIPT_DIR/sprout" feature-auth "$COMMIT_B"
git push -u origin feature-auth 2>/dev/null

# Squash-merge on master and delete remote branch (simulating GitHub merge)
git checkout master
git merge --squash feature-auth
git commit -m "squash: B"
git push 2>/dev/null
git push origin --delete feature-auth 2>/dev/null
git fetch --prune 2>/dev/null

# Now auto-detect from feature branch
git checkout feature
"$SCRIPT_DIR/resorb"

# Verify: feature should have 2 commits on top of master (A, C)
COUNT=$(git rev-list master..feature | wc -l | tr -d ' ')
[[ "$COUNT" == "2" ]] || fail "Expected 2 commits on feature, got $COUNT"

# Verify: all files exist
for f in a.txt b.txt c.txt base.txt; do
    [[ -f "$f" ]] || fail "Missing file: $f"
done

pass "Auto-detect sprouted branch"

# ============================================================
echo ""
echo "=== Test 3: Resorb with no matching branch fails gracefully ==="
# ============================================================

setup_remote_repo
cd "$REPO_DIR"

git checkout -b feature
echo "aaa" > a.txt && git add . && git commit -m "commit A"

if "$SCRIPT_DIR/resorb" 2>&1; then
    fail "Should have exited with error when no branch found"
fi

pass "No matching branch fails gracefully"

# ============================================================
echo ""
echo "=== Test 4: Resorb nonexistent branch fails gracefully ==="
# ============================================================

cd "$REPO_DIR"
if "$SCRIPT_DIR/resorb" nonexistent-branch 2>&1; then
    fail "Should have exited with error for nonexistent branch"
fi

pass "Nonexistent branch fails gracefully"

# ============================================================
echo ""
echo "All tests passed!"
