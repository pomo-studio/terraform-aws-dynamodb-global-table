#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <plan-json-file>"
  exit 2
fi

PLAN_JSON="$1"

if [[ ! -f "$PLAN_JSON" ]]; then
  echo "Plan JSON file not found: $PLAN_JSON"
  exit 2
fi

if ! command -v python >/dev/null 2>&1; then
  echo "python is required"
  exit 2
fi

python - "$PLAN_JSON" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as f:
    plan = json.load(f)

changes = plan.get("resource_changes", [])
unexpected = []

allowed_destroy_prefixes = []

for rc in changes:
    addr = rc.get("address", "")
    actions = rc.get("change", {}).get("actions", [])

    if "delete" in actions:
        if any(addr.startswith(prefix) for prefix in allowed_destroy_prefixes):
            continue
        unexpected.append({"address": addr, "actions": actions})

if unexpected:
    print("FAIL: unexpected destroy actions detected")
    for item in unexpected:
        print(f"  - {item['address']}: {item['actions']}")
    sys.exit(1)

print("PASS: no destroy actions detected")
PY
