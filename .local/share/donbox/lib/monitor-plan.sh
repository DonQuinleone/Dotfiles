# shellcheck shell=bash

# Pairs each saved output (matched by description, never by
# connector name) with a currently connected connector, and
# prints one tab-separated plan row per output. Fails, with a
# reason on stderr, unless every saved output and every
# connected output are accounted for exactly once: a partial
# match is exactly the "guess where the extra monitor goes"
# situation this script exists to avoid.
resolve_plan() {
    local profile_json="$1" monitors_json="$2"
    python3 - "${profile_json}" "${monitors_json}" <<'PY'
import json
import sys

DEFAULT_BITDEPTH = 8

profile = json.load(open(sys.argv[1]))
monitors = json.load(open(sys.argv[2]))

available = {}
for monitor in monitors:
    available.setdefault(
        monitor["description"], []
    ).append(monitor["name"])

plan = []
for output in profile["outputs"]:
    description = output["description"]
    queue = available.get(description)
    if not queue:
        print(
            f'no connected output matches "{description}"',
            file=sys.stderr,
        )
        sys.exit(1)
    connector = queue.pop(0)
    mode = (
        f'{output["resolution"]}@{output["refresh_rate"]:.2f}'
    )
    workspaces = ",".join(
        str(w) for w in output["workspaces"]
    )
    plan.append((
        connector,
        mode,
        output["position"],
        str(output["scale"]),
        str(output["transform"]),
        str(output.get("bitdepth", DEFAULT_BITDEPTH)),
        workspaces,
    ))

leftover = [c for cs in available.values() for c in cs]
if leftover:
    print(
        "connected outputs not covered by this profile: "
        + ", ".join(leftover),
        file=sys.stderr,
    )
    sys.exit(1)

for row in plan:
    print("\t".join(row))
PY
}

# Re-applying a mode an output already holds still takes it
# down and brings it back, which blanks every screen for a
# second on any reload that ends up here.
already_configured() {
    local connector="$1" mode="$2" position="$3" scale="$4"
    local transform="$5"
    current_monitors_json 2>/dev/null | python3 -c 'import json, sys
connector, mode, position, scale, transform = sys.argv[1:6]
wanted_size, _, wanted_refresh = mode.partition("@")
REFRESH_TOLERANCE = 0.5
SCALE_TOLERANCE = 0.001
for live in json.load(sys.stdin):
    if live["name"] != connector:
        continue
    size = str(live["width"]) + "x" + str(live["height"])
    at = str(live["x"]) + "x" + str(live["y"])
    same = (
        size == wanted_size
        and at == position
        and abs(float(live["scale"]) - float(scale))
            < SCALE_TOLERANCE
        and int(live["transform"]) == int(transform)
    )
    if same and wanted_refresh:
        same = (abs(live["refreshRate"] - float(wanted_refresh))
            < REFRESH_TOLERANCE)
    sys.exit(0 if same else 1)
sys.exit(1)' \
        "${connector}" "${mode}" "${position}" "${scale}" \
        "${transform}" 2>/dev/null
}
