pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int saveDelayMs: 1000
    readonly property int hoursPerDay: 24
    readonly property int minutesPerHour: 60
    readonly property int msPerMinute: 60000
    readonly property int minuteStep: 5
    readonly property int clockDigits: 2

    readonly property string appName: "Alarm"
    readonly property string urgency: "critical"
    readonly property string glyph: "󰀠"

    readonly property string chime: "/usr/share/sounds/"
        + "freedesktop/stereo/alarm-clock-elapsed.oga"
    readonly property int chimeEveryMs: 3000

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
            enabled: true
        }]);
    }

    function addRelative(minutes: int): void {
        const when =
            new Date(Date.now() + minutes * root.msPerMinute);
        root.add(when.getHours(), when.getMinutes());
    }

    function remove(entry: var): void {
        root.entries = root.entries.filter(item => item !== entry);
    }

    function toggle(entry: var): void {
        entry.enabled = !entry.enabled;
        root.entries = root.entries.slice();
    }

    function ring(entry: var): void {
        Quickshell.execDetached(["notify-send",
            "--app-name", root.appName,
            "--urgency", root.urgency,
            `Alarm ${root.clockOf(entry.hour, entry.minute)}`,
            "Dismiss this notification to silence it."]);
    }

    // An alarm sounds once and disarms itself; ringing again
    // tomorrow takes turning it back on.
    function sweep(when: date): void {
        let rung = false;
        for (const entry of root.entries) {
            if (!entry.enabled) continue;
            if (entry.hour !== when.getHours()) continue;
            if (entry.minute !== when.getMinutes()) continue;
            entry.enabled = false;
            rung = true;
            root.ring(entry);
        }
        if (rung) root.entries = root.entries.slice();
    }

    function restored(saved: var): var {
        return {
            hour: saved.hour ?? 0,
            minute: saved.minute ?? 0,
            enabled: saved.enabled ?? true
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

    // The chime keeps time with the notification rather than
    // with the alarm: it sounds for as long as an alarm toast
    // is on screen, and dismissing the toast is what ends it.
    Timer {
        interval: root.chimeEveryMs
        repeat: true
        triggeredOnStart: true
        running: Notifications.alarmsShowing > 0

        onTriggered: Quickshell.execDetached(
            ["pw-play", root.chime])
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
