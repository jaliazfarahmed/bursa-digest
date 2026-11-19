#!/usr/bin/env bash
# Publish a new digest.json already written in this repository.
# Usage: ./publish.sh
# Run from anywhere; the script uses its own directory as the repo root.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

if [[ ! -f digest.json ]]; then
  echo "error: digest.json not found in ${REPO_DIR}" >&2
  exit 1
fi

if ! python3 -m json.tool digest.json > /dev/null; then
  echo "error: digest.json is not valid JSON" >&2
  exit 1
fi

DATE="$(python3 -c "import json; print(json.load(open('digest.json'))['digest_date'])")"
if [[ ! "${DATE}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "error: invalid digest_date: ${DATE}" >&2
  exit 1
fi

mkdir -p archive
cp digest.json "archive/${DATE}.json"

git add digest.json "archive/${DATE}.json"

if git diff --cached --quiet; then
  echo "No changes to publish for ${DATE}."
  exit 0
fi

git commit -m "Publish Bursa digest for ${DATE}"
git push origin HEAD
echo "Published digest for ${DATE}."
