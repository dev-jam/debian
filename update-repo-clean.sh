#!/bin/bash
set -e

# Change directory to the repository root where this script is located
cd "$(dirname "$0")"

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
fi

KEY="debian@bobrosbag.nl"

# Ensure required directory structure and cache exist
mkdir -p dists/trixie/{main,tools,science,test}/binary-amd64
mkdir -p .cache

# Generate Packages indices for all components
apt-ftparchive generate generate.conf

# Generate and sign the Release files
apt-ftparchive -c release.conf release dists/trixie > dists/trixie/Release
gpg --yes --default-key "$KEY" -abs -o dists/trixie/Release.gpg dists/trixie/Release
gpg --yes --default-key "$KEY" --clearsign -o dists/trixie/InRelease dists/trixie/Release

# Create fresh orphan snapshot and force push
git checkout --orphan publish-tmp
git add -A
git commit -qm "Repository snapshot $(date -I)"
git branch -M main
git push --force origin main

# Local garbage collection to free disk space
git reflog expire --expire=now --all
git gc --prune=now --aggressive

echo "Repository successfully updated and pushed."
