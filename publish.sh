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

# Every item must have a stock code and a date no older than the previous weekday.
python3 - <<'PY'
import json, sys, datetime
d = json.load(open("digest.json"))
dd = datetime.date.fromisoformat(d["digest_date"])
cut = dd - datetime.timedelta(days=1)
while cut.weekday() >= 5:
    cut -= datetime.timedelta(days=1)
bad = []
for sec, items in d["sections"].items():
    for i in items:
        if not i.get("stock_code"):
            bad.append(f"{sec}: {i.get('company')} has no stock_code")
        if i.get("date", "") < cut.isoformat() or i.get("date", "") > dd.isoformat():
            bad.append(f"{sec}: {i.get('company')} dated {i.get('date')} is outside {cut}..{dd}")
if bad:
    print("error: digest failed checks:\n  " + "\n  ".join(bad), file=sys.stderr)
    sys.exit(1)
PY

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
