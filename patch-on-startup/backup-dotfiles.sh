#!/usr/bin/env bash
set -euo pipefail

DEST="$HOME/MyFiles/dotfiles"
mkdir -p "$DEST"

RSYNC_LOG="$(mktemp)"
PERSISTENT_LOG="/tmp/dotfile-backup-error.log"

# Cleanup handler
cleanup() {
  EXIT_CODE=$?
  if [[ $EXIT_CODE -ne 0 && -s "$RSYNC_LOG" ]]; then
    echo "[ERROR] rsync failed — log saved to $PERSISTENT_LOG"
    cp "$RSYNC_LOG" "$PERSISTENT_LOG"
  fi
  rm -f "$RSYNC_LOG"
  exit $EXIT_CODE
}
trap cleanup EXIT

# Dry run?
DRYRUN=false
if [[ "${1:-}" == "--dry-run" || "${1:-}" == "-n" ]]; then
  DRYRUN=true
  echo "[INFO] Dry run enabled — no files will be changed."
fi

# List of noisy dotfolders to exclude
EXCLUDES=(
  ".cache"
  ".local"
  ".Trash"
  ".vscode"
  ".zoom"
  ".config"
  ".thunderbird"
  ".minikube/cache"
  ".kube/cache"
  ".var"
)

# Check for non-dotfiles in $DEST and ask for confirmation before removal
NON_DOTFILES=()
while IFS= read -r entry; do
  NON_DOTFILES+=("$entry")
done < <(find "$DEST" -maxdepth 1 -mindepth 1 ! -name ".*" -printf "%f\n")

if [[ ${#NON_DOTFILES[@]} -gt 0 ]]; then
  echo "[WARN] The following non-dotfiles exist in the backup directory and will be removed:"
  for file in "${NON_DOTFILES[@]}"; do
    echo " - $file"
  done
  echo
  read -rp "Do you want to proceed with deleting these files? [y/N]: " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "[INFO] Removing non-dotfiles from $DEST..."
    for file in "${NON_DOTFILES[@]}"; do
      rm -rf "$DEST/$file"
    done
  else
    echo "[INFO] Skipping removal of non-dotfiles."
  fi
fi

# Collect dotfiles and dotfolders in $HOME (excluding . and ..)
shopt -s dotglob nullglob
DOTFILES=( "$HOME"/.[!.]* "$HOME"/.??* )

# Assemble rsync options
RSYNC_OPTS=(-a --delete --itemize-changes)
$DRYRUN && RSYNC_OPTS+=("--dry-run")

for exclude in "${EXCLUDES[@]}"; do
  RSYNC_OPTS+=(--exclude="$exclude")
done

echo "[INFO] Backing up dotfiles to $DEST..."
if rsync "${RSYNC_OPTS[@]}" "${DOTFILES[@]}" "$DEST/" >"$RSYNC_LOG" 2>&1; then
  if [[ -s "$RSYNC_LOG" ]]; then
    echo "[INFO] The following changes were made:"
    cat "$RSYNC_LOG"
  else
    echo "[INFO] No changes — backup is already up-to-date."
  fi
else
  echo "[ERROR] rsync failed — see log: $PERSISTENT_LOG"
  exit 1
fi
