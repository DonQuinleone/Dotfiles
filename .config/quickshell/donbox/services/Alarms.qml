pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int saveDelayMs: 1000
    readonly property int hoursPerDay: 24
    readonly property int minutesPerHour: 60
    readonly property int minuteStep: 5
    readonly property int clockDigits: 2

    readonly property string appName: "Alarm"
    readonly property string urgency: "critical"
    readonly property string glyph: "󰀠"

    readonly property string stateHome:
        Quickshell.env("XDG_STATE_HOME")
        ?? `${Quickshell.env("HOME")}/.local/state`

    readonly property string directory: `${root.stateHome}/donbox`
    readonly property string path: `${root.directory}/alarms.json`

    property var entries: []

    readonly property var ordered: root.entries.slice()
        .sort((one, other) => one.hour - other.hour
            || one.minute - other.minute)

    readonly property int armed:
        root.entries.filter(entry => entry.enabled).length

    function padded(value: int): string {
        return `${value}`.padStart(root.clockDigits, "0");
    }

    function clockOf(hour: int, minute: int): string {
        return `${root.padded(hour)}:${root.padded(minute)}`;
    }

    function dayKey(when: date): string {
        return `${when.getFullYear()}-${when.getMonth()}`
            + `-${when.getDate()}`;
    }

    function at(hour: int, minute: int): var {
        return root.entries.find(entry => entry.hour === hour
            && entry.minute === minute) ?? null;
    }

    function add(hour: int, minute: int): void {
        const found = root.at(hour, minute);
        if (found) {
            found.enabled = true;
            root.entries = root.entries.slice();
            return;
        }
        root.entries = root.entries.concat([{
            hour: hour,
            minute: minute,
            enabled: true,
            firedOn: ""
        }]);
    }

    function remove(entry: var): void {
        root.entries = root.entries.filter(item => item !== entry);
    }

    function toggle(entry: var): void {
        entry.enabled = !entry.enabled;
        entry.firedOn = "";
        root.entries = root.entries.slice();
    }

    function ring(entry: var): void {
        Quickshell.execDetached(["notify-send",
            "--app-name", root.appName,
            "--urgency", root.urgency,
            `Alarm ${root.clockOf(entry.hour, entry.minute)}`,
            "The alarm you set has gone off."]);
    }

    // The firing day is remembered so that a shell restarted
    // inside the same minute does not sound the alarm twice.
    function sweep(when: date): void {
        const key = root.dayKey(when);
        let rung = false;
        for (const entry of root.entries) {
            if (!entry.enabled) continue;
            if (entry.hour !== when.getHours()) continue;
            if (entry.minute !== when.getMinutes()) continue;
            if (entry.firedOn === key) continue;
            entry.firedOn = key;
            rung = true;
            root.ring(entry);
        }
        if (rung) root.entries = root.entries.slice();
    }

    function restored(saved: var): var {
        return {
            hour: saved.hour ?? 0,
            minute: saved.minute ?? 0,
            enabled: saved.enabled ?? true,
            firedOn: saved.firedOn ?? ""
        };
    }

    function reparse(): void {
        try {
            const saved = JSON.parse(file.text());
            root.entries =
                (saved.alarms ?? []).map(item => root.restored(item));
        } catch (error) {
            root.entries = [];
        }
    }

    function save(): void {
        file.setText(JSON.stringify({ alarms: root.entries }));
    }

    onEntriesChanged: writeBack.restart()

    Component.onCompleted: {
        Quickshell.execDetached(["mkdir", "-p", root.directory]);
        root.reparse();
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes

        onDateChanged: root.sweep(this.date)
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
