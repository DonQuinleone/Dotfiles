pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root

    readonly property int cap: 200
    readonly property int saveDelayMs: 1000

    readonly property var fields: ({
        app: "",
        icon: "",
        summary: "",
        body: "",
        image: "",
        urgency: NotificationUrgency.Normal,
        time: 0,
        seen: false
    })

    readonly property string stateHome:
        Quickshell.env("XDG_STATE_HOME")
        ?? `${Quickshell.env("HOME")}/.local/state`

    readonly property string directory: `${root.stateHome}/donbox`

    readonly property string path:
        `${root.directory}/notifications.json`

    property var entries: []
    property bool doNotDisturb: false

    // The model hands out copies, so a copy has to name the
    // one it came from.
    property int lastId: 0

    readonly property int pending: root.entries.length

    readonly property int unseen:
        root.entries.filter(entry => !entry.seen).length

    function nextId(): int {
        root.lastId += 1;
        return root.lastId;
    }

    function held(entry: var): var {
        return root.entries.find(item => item.id === entry.id)
            ?? entry;
    }

    function detach(entry: var): var {
        const stored = root.held(entry);
        const live = stored.live ?? entry.live;
        stored.live = null;
        return live;
    }

    function drop(entry: var): void {
        root.entries =
            root.entries.filter(item => item.id !== entry.id);
    }

    function restored(saved: var): var {
        const entry = { id: root.nextId(), actions: [], live: null };
        for (const name in root.fields) {
            entry[name] = saved[name] ?? root.fields[name];
        }
        return entry;
    }

    function persisted(entry: var): var {
        const saved = ({});
        for (const name in root.fields) {
            saved[name] = entry[name];
        }
        return saved;
    }

    function close(entry: var): void {
        const live = root.detach(entry);
        if (live) live.dismiss();
    }

    function record(entry: var): void {
        entry.id = root.nextId();
        const kept = [entry].concat(root.entries);
        kept.slice(root.cap).forEach(item => root.close(item));
        root.entries = kept.slice(0, root.cap);
    }

    function release(entry: var): void {
        if (root.held(entry).actions.length > 0) return;
        const live = root.detach(entry);
        if (live) live.expire();
    }

    function discard(entry: var): void {
        root.held(entry).live = null;
        root.drop(entry);
    }

    function forget(entry: var): void {
        root.close(entry);
        root.drop(entry);
    }

    function clearApp(app: string): void {
        root.entries
            .filter(item => item.app === app)
            .forEach(item => root.close(item));
        root.entries = root.entries.filter(item => item.app !== app);
    }

    function clear(): void {
        root.entries.forEach(item => root.close(item));
        root.entries = [];
    }

    function markSeen(): void {
        if (root.unseen === 0) return;
        root.entries = root.entries.map(entry => {
            entry.seen = true;
            return entry;
        });
    }

    function toggleDoNotDisturb(): void {
        root.doNotDisturb = !root.doNotDisturb;
    }

    function reparse(): void {
        try {
            const saved = JSON.parse(file.text());
            root.entries =
                (saved.entries ?? []).map(item => root.restored(item));
            root.doNotDisturb = saved.doNotDisturb ?? false;
        } catch (error) {
            root.entries = [];
        }
    }

    function save(): void {
        file.setText(JSON.stringify({
            doNotDisturb: root.doNotDisturb,
            entries: root.entries.map(item => root.persisted(item))
        }));
    }

    onEntriesChanged: writeBack.restart()
    onDoNotDisturbChanged: writeBack.restart()

    Component.onCompleted: {
        Quickshell.execDetached(["mkdir", "-p", root.directory]);
        root.reparse();
    }

    Timer {
        id: writeBack

        interval: root.saveDelayMs

        onTriggered: root.save()
    }

    FileView {
        id: file

        path: root.path
        blockLoading: true
        atomicWrites: true
        printErrors: false
    }
}
