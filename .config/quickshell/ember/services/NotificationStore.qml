pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int cap: 200
    readonly property int saveDelayMs: 1000

    readonly property string stateHome:
        Quickshell.env("XDG_STATE_HOME")
        ?? `${Quickshell.env("HOME")}/.local/state`

    readonly property string directory: `${root.stateHome}/ember`

    readonly property string path:
        `${root.directory}/notifications.json`

    property var entries: []
    property real lastSeenMs: 0
    property bool doNotDisturb: false

    readonly property int unread: root.entries
        .filter(entry => entry.time > root.lastSeenMs).length

    function record(entry: var): void {
        root.entries =
            [entry].concat(root.entries).slice(0, root.cap);
    }

    function forget(entry: var): void {
        root.entries = root.entries.filter(item => item !== entry);
    }

    function clearApp(app: string): void {
        root.entries = root.entries.filter(item => item.app !== app);
    }

    function clear(): void {
        root.entries = [];
    }

    function markSeen(): void {
        root.lastSeenMs = Date.now();
    }

    function toggleDoNotDisturb(): void {
        root.doNotDisturb = !root.doNotDisturb;
    }

    function reparse(): void {
        try {
            const saved = JSON.parse(file.text());
            root.entries = saved.entries ?? [];
            root.lastSeenMs = saved.lastSeen ?? 0;
            root.doNotDisturb = saved.doNotDisturb ?? false;
        } catch (error) {
            root.entries = [];
        }
    }

    function save(): void {
        file.setText(JSON.stringify({
            lastSeen: root.lastSeenMs,
            doNotDisturb: root.doNotDisturb,
            entries: root.entries
        }));
    }

    onEntriesChanged: writeBack.restart()
    onLastSeenMsChanged: writeBack.restart()
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
