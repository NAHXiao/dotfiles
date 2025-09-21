#!/bin/bash
set -euo pipefail
SOURCE_BRANCH="chezmoi"
TARGET_BRANCH="main"
required_commands=("git" "rsync" "mktemp")
for cmd in "${required_commands[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error:'$cmd' not found"
        exit 1
    fi
done
# Only for Source Branch
[[ "$(git rev-parse --abbrev-ref HEAD)" == "$SOURCE_BRANCH" ]] || exit 0

stash_created=false
temp_dir=$(mktemp -d)
[[ -n $temp_dir ]] || exit 1
temp_toml=$(mktemp -t chezmoi.XXXXXX.toml)
[[ -n $temp_toml ]] || exit 1
cleanup(){
    rm -rf "$temp_dir" 
    rm "$temp_toml"
    git checkout $SOURCE_BRANCH
    if [[ "$stash_created" == true ]]; then
        git stash pop
    fi
}
trap cleanup EXIT
commit_hash=$(git rev-parse --short=7 HEAD)
commit_message=$(git log -1 --pretty=%s)
if ! git diff --quiet || ! git diff --staged --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
    git stash push -m "Auto-sync: saving work" --all
    stash_created=true
fi
chezmoi init --apply --mode=file --exclude encrypted --config "$temp_toml" --destination "$temp_dir" || exit 1
(git show-ref --verify --quiet refs/heads/$TARGET_BRANCH&& git checkout $TARGET_BRANCH) || git checkout --orphan $TARGET_BRANCH
git rm -rf . --quiet >/dev/null 2>&1
rsync -a --delete --exclude .git "$temp_dir/" "./" || exit 1
git add -A
if ! git diff --staged --quiet; then
    git commit -m "[${commit_hash}]:$commit_message"
fi
echo "Sync ok: [${commit_hash}]:$commit_message"
