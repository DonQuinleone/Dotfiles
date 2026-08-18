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
    readonly property int clockDigits: 2

    readonly property string appName: "Alarm"
    readonly property string urgency: "critical"
    readonly property string glyph: "󰀠"

    readonly property string chime: "alarm"

    // The alarm sound runs for six seconds and an eighth, so a
    // shorter gap than this would start a second ring over the
    // first and the two would sound as one muddle.
    readonly property int chimeEveryMs: 7000

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

    // A row hands an alarm back through the model, which copies
    // it, so the entry that comes back is never the one that was
    // handed out and only what it says identifies it. The time
    // it reads serves: setting a time already set re-arms the
    // alarm standing there rather than adding a second one.
    function keyOf(entry: var): string {
        return root.clockOf(entry.hour, entry.minute);
    }

    function at(hour: int, minute: int): var {
        return root.entries.find(entry => entry.hour === hour
            && entry.minute === minute) ?? null;
    }

    function setEnabled(entry: var, enabled: bool): void {
        const key = root.keyOf(entry);
        root.entries = root.entries.map(item => {
            if (root.keyOf(item) !== key) return item;
            return {
                hour: item.hour,
                minute: item.minute,
                enabled: enabled
            };
        });
    }

    function add(hour: int, minute: int): void {
        const found = root.at(hour, minute);
        if (found) {
            root.setEnabled(found, true);
            return;
        }
        root.entries = root.entries.concat([{
            hour: hour,
            minute: minute,
            enabled: true
        }]);
    }

    function inMinutes(minutes: int): var {
        const when =
            new Date(Date.now() + minutes * root.msPerMinute);
        return {
            hour: when.getHours(),
            minute: when.getMinutes()
        };
    }

    function addRelative(minutes: int): void {
        const when = root.inMinutes(minutes);
        root.add(when.hour, when.minute);
    }

    // "07:30" names a time of day; "+15" names a distance from
    // now. Anything else names nothing.
    function parse(text: string): var {
        const trimmed = text.trim();
        const relative = trimmed.match(/^\+(\d{1,3})$/);
        if (relative) return root.inMinutes(Number(relative[1]));
        const absolute = trimmed.match(/^(\d{1,2}):(\d{2})$/);
        if (absolute === null) return null;
        const hour = Number(absolute[1]);
        const minute = Number(absolute[2]);
        if (hour >= root.hoursPerDay) return null;
        if (minute >= root.minutesPerHour) return null;
        return { hour: hour, minute: minute };
    }

    function remove(entry: var): void {
        const key = root.keyOf(entry);
        root.entries = root.entries.filter(
            item => root.keyOf(item) !== key);
    }

    function toggle(entry: var): void {
        root.setEnabled(entry, !entry.enabled);
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
        const due = root.entries.filter(entry => entry.enabled
            && entry.hour === when.getHours()
            && entry.minute === when.getMinutes());
        for (const entry of due) {
            root.setEnabled(entry, false);
            root.ring(entry);
        }
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

        onTriggered: NotificationRules.playSound(root.chime)
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
