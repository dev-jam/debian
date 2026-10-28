#!/bin/bash
set -e

usage() {
  echo "Usage: $0 [--clean]"
  echo "  (no flag)  commit changes on main and push"
  echo "  --clean    replace history with one orphan snapshot, force push and run gc"
}

CLEAN=0
for arg in "$@"; do
  case "$arg" in
    --clean)   CLEAN=1 ;;
    -h|--help) usage; exit 0 ;;
    *)         echo "Unknown option: $arg" >&2; usage >&2; exit 1 ;;
  esac
done

# Change directory to the repository root (this script lives in scripts/;
# readlink -f resolves symlinks, so calling it via a symlink works too)
cd "$(dirname "$(readlink -f "$0")")/.."

# -------------------------------------------------------------------
# File size check (GitHub hard limit = 100 MB)
# -------------------------------------------------------------------
MAX_SIZE_MB=100
OVERSIZED_FILES=$(find pool/ -type f -name "*.deb" -size +${MAX_SIZE_MB}M 2>/dev/null)

if [ -n "$OVERSIZED_FILES" ]; then
  echo "ERROR: The following packages exceed ${MAX_SIZE_MB} MB and will be rejected by GitHub:"
  echo "$OVERSIZED_FILES" | while read -r file; do
    SIZE=$(du -h "$file" | cut -f1)
    echo "  - $file ($SIZE)"
  done
  echo
  echo "Please remove or move these files out of pool/ before running this script again."
  exit 1
fi

# Warning for files > 50 MB (GitHub soft limit warning)
LARGE_FILES=$(find pool/ -type f -name "*.deb" -size +50M -size -100M 2>/dev/null)
if [ -n "$LARGE_FILES" ]; then
  echo "WARNING: The following files are larger than 50 MB (GitHub will issue a warning):"
  echo "$LARGE_FILES" | while read -r file; do
    SIZE=$(du -h "$file" | cut -f1)
    echo "  - $file ($SIZE)"
  done
  echo
fi

KEY="debian@bobrosbag.nl"

source scripts/components.env
source scripts/prepare-conf.sh

# Generate Packages indices for all components
echo "Generating Packages indices..."
apt-ftparchive generate .cache/generate.conf
echo

# Generate and sign the Release files
echo "Generating and signing Release files..."
apt-ftparchive -c .cache/release.conf release "dists/$SUITE" > "dists/$SUITE/Release"
gpg --yes --default-key "$KEY" -abs -o "dists/$SUITE/Release.gpg" "dists/$SUITE/Release"
gpg --yes --default-key "$KEY" --clearsign -o "dists/$SUITE/InRelease" "dists/$SUITE/Release"
echo

# Show size of objects
echo "Repository size before:"
git count-objects -vH
echo

if [ "$CLEAN" -eq 1 ]; then
  echo "Creating orphan snapshot and force pushing..."

  # Create fresh orphan snapshot and force push
  git checkout --orphan publish-tmp
  git add -A
  git commit -qm "Repository snapshot $(date -I)"
  git branch -M main
  git push --force origin main
  echo

  # Local garbage collection to free disk space
  echo "Running garbage collection..."
  git reflog expire --expire=now --all
  git gc --prune=now --aggressive
  echo
else
  echo "Committing and pushing..."

  # Commit and push changes to GitHub
  git add -A
  git commit -m "Repository update $(date -Iseconds)"
  git push origin main
  echo
fi

# Show size of objects
echo "Repository size after:"
git count-objects -vH
echo

echo "Repository successfully updated and pushed."
