pragma Singleton

import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property int genericPenalty: 4
    readonly property int keywordPenalty: 8

    property bool shown: false
    property string monitor: ""
    property string query: ""
    property int selected: 0

    readonly property var applications:
        DesktopEntries.applications.values.filter(
            entry => !entry.noDisplay)

    readonly property var matches: root.rank(root.query)

    onQueryChanged: root.selected = 0

    function searchable(entry): var {
        return [
            { text: entry.name ?? "", penalty: 0 },
            { text: entry.genericName ?? "",
              penalty: root.genericPenalty },
            { text: (entry.keywords ?? []).join(" "),
              penalty: root.keywordPenalty }
        ];
    }

    function bestScore(entry, needle: string): int {
        let best = FuzzyMatch.noMatch;
        for (const field of root.searchable(entry)) {
            const value = FuzzyMatch.score(field.text, needle);
            if (value === FuzzyMatch.noMatch) continue;
            best = Math.max(best, value - field.penalty);
        }
        return best;
    }

    function describe(entry): var {
        return {
            value: entry.id,
            label: entry.name,
            icon: entry.icon ?? "",
            subtitle: entry.genericName || entry.comment || "",
            entry: entry
        };
    }

    function rank(needle: string): var {
        const hits = [];
        for (const entry of root.applications) {
            const score = root.bestScore(entry, needle);
            if (score === FuzzyMatch.noMatch) continue;
            hits.push({ entry: entry, score: score });
        }
        hits.sort((first, second) => second.score - first.score
            || first.entry.name.localeCompare(second.entry.name));
        return hits.map(hit => root.describe(hit.entry));
    }

    function show(): void {
        root.query = "";
        root.selected = 0;
        root.monitor = Hyprland.focusedMonitor?.name ?? "";
        root.shown = true;
    }

    function hide(): void {
        root.shown = false;
    }

    function toggle(): void {
        if (root.shown) {
            root.hide();
            return;
        }
        root.show();
    }

    function move(delta: int): void {
        const count = root.matches.length;
        if (count === 0) return;
        root.selected = (root.selected + delta + count) % count;
    }

    function accept(): void {
        const chosen = root.matches[root.selected];
        root.hide();
        chosen?.entry?.execute();
    }
}
