pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Singleton {
    id: root

    readonly property int answerTimeoutSeconds: 10
    readonly property string gridMode: "grid"
    readonly property string chosenStatus: "ok"
    readonly property string cancelledStatus: "cancel"
    readonly property string acceptedReply: "ok"
    readonly property string unreadableReply: "unreadable"

    property bool shown: false
    property string monitor: ""
    property string query: ""
    property int selected: 0
    property var request: ({})

    readonly property string prompt: root.request.prompt ?? ""
    readonly property string current: root.request.current ?? ""
    readonly property string answerPath: root.request.answerPath ?? ""
    readonly property bool grid: root.request.mode === root.gridMode
    readonly property var items: root.request.items ?? []

    readonly property var matches: root.rank(root.query)

    onQueryChanged: root.selected = 0

    function caption(item): string {
        if (item.label !== "") return item.label;
        if (!root.grid) return item.value;
        return item.value.split("/").pop();
    }

    function describe(item): var {
        return {
            value: item.value,
            label: root.caption(item),
            icon: item.icon ?? "",
            subtitle: item.subtitle ?? "",
            current: item.value === root.current
        };
    }

    function rank(needle: string): var {
        const hits = [];
        for (const item of root.items) {
            const described = root.describe(item);
            const score = FuzzyMatch.score(described.label, needle);
            if (score === FuzzyMatch.noMatch) continue;
            hits.push({
                item: described,
                score: score,
                given: hits.length
            });
        }
        hits.sort((first, second) => second.score - first.score
            || first.given - second.given);
        return hits.map(hit => hit.item);
    }

    function indexOfCurrent(): int {
        const at = root.matches.findIndex(item => item.current);
        return at < 0 ? 0 : at;
    }

    function present(path: string): string {
        if (root.shown) root.cancel();
        requestFile.path = path;
        requestFile.reload();
        try {
            root.request = JSON.parse(requestFile.text());
        } catch (error) {
            console.error(`ember: ${path} is not valid JSON:`, error);
            return root.unreadableReply;
        }
        root.query = "";
        root.selected = root.indexOfCurrent();
        root.monitor = Hyprland.focusedMonitor?.name ?? "";
        root.shown = true;
        return root.acceptedReply;
    }

    function deliver(status: string, value: string): void {
        root.shown = false;
        if (root.answerPath === "") return;
        Quickshell.execDetached([
            "timeout", String(root.answerTimeoutSeconds),
            "sh", "-c", 'printf "%s\\n%s\\n" "$2" "$3" >"$1"',
            "sh", root.answerPath, status, value
        ]);
    }

    function move(delta: int): void {
        const count = root.matches.length;
        if (count === 0) return;
        root.selected = (root.selected + delta + count) % count;
    }

    function accept(): void {
        const chosen = root.matches[root.selected];
        if (!chosen) {
            root.cancel();
            return;
        }
        root.deliver(root.chosenStatus, chosen.value);
    }

    function cancel(): void {
        root.deliver(root.cancelledStatus, "");
    }

    FileView {
        id: requestFile

        blockLoading: true
        blockAllReads: true
        printErrors: false
    }
}
