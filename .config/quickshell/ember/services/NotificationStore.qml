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
        time: 0
    })

    readonly property string stateHome:
        Quickshell.env("XDG_STATE_HOME")
        ?? `${Quickshell.env("HOME")}/.local/state`

    readonly property string directory: `${root.stateHome}/ember`

    readonly property string path:
        `${root.directory}/notifications.json`

    property var entries: []
    property bool doNotDisturb: false

    readonly property int pending: root.entries.length

    function restored(saved: var): var {
        const entry = { actions: [], live: null };
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
        const live = entry.live;
        entry.live = null;
        if (live) live.dismiss();
    }

    function record(entry: var): void {
        const kept = [entry].concat(root.entries);
        kept.slice(root.cap).forEach(item => root.close(item));
        root.entries = kept.slice(0, root.cap);
    }

    function release(entry: var): void {
        if (entry.actions.length > 0) return;
        const live = entry.live;
        entry.live = null;
        if (live) live.expire();
    }

    function discard(entry: var): void {
        entry.live = null;
        root.entries = root.entries.filter(item => item !== entry);
    }

    function forget(entry: var): void {
        root.close(entry);
        root.entries = root.entries.filter(item => item !== entry);
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
