pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int writeDelayMs: 300
    readonly property int dispatchIntervalMs: 120
    readonly property int minutesPerHour: 60
    readonly property int minutesPerDay: 1440
    readonly property int clockStepMinutes: 15
    readonly property int clockDigits: 2

    readonly property string seedNightStart: "22:00"
    readonly property string seedNightEnd: "07:00"

    readonly property var configKeys: ["ENABLED",
        "DAY_TEMPERATURE", "NIGHT_TEMPERATURE",
        "TRANSITION_MINUTES", "LATITUDE", "LONGITUDE",
        "NIGHT_START", "NIGHT_END"]

    readonly property var phaseWords: ({
        "day": qsTr("day colours"),
        "night": qsTr("night colours"),
        "morning-ramp": qsTr("cooling towards the day colours"),
        "evening-ramp": qsTr("warming towards the night colours"),
        "disabled": qsTr("switched off"),
        "override-on": qsTr("held at the night colours"),
        "override-off": qsTr("held at the day colours")
    })

    readonly property string path:
        `${Preferences.configHome}/night-shift.conf`

    readonly property string scriptPath:
        `${Preferences.configHome}/hypr/scripts/night-shift`

    property var settings: ({})
    property var defaults: ({})
    property var status: ({})
    property var queue: []

    readonly property bool sampled: root.status.phase !== undefined
    readonly property string phase: root.status.phase ?? ""
    readonly property bool active: root.status.active ?? false

    readonly property string overrideMode:
        root.status.override ?? "auto"

    readonly property string temperatureText: root.sampled
        ? qsTr("%1 K").arg(root.status.temperature)
        : qsTr("Not read yet")

    readonly property string phaseText:
        root.phaseWords[root.phase] ?? ""

    readonly property bool enabled: root.text("ENABLED") === "1"

    readonly property int dayTemperature:
        Number(root.text("DAY_TEMPERATURE"))

    readonly property int nightTemperature:
        Number(root.text("NIGHT_TEMPERATURE"))

    readonly property int transitionMinutes:
        Number(root.text("TRANSITION_MINUTES"))

    readonly property string nightStart: root.text("NIGHT_START")
    readonly property string nightEnd: root.text("NIGHT_END")

    readonly property bool fixedTimes: root.nightStart !== ""

    readonly property int nightStartMinutes: root.clockMinutes(
        root.nightStart || root.seedNightStart)

    readonly property int nightEndMinutes: root.clockMinutes(
        root.nightEnd || root.seedNightEnd)

    readonly property int earliestNightStartMinutes:
        root.nightEndMinutes + root.clockStepMinutes

    readonly property int latestNightStartMinutes:
        root.minutesPerDay - root.clockStepMinutes

    readonly property int earliestNightEndMinutes: 0

    readonly property int latestNightEndMinutes:
        root.nightStartMinutes - root.clockStepMinutes

    readonly property int contrastFloorKelvin:
        Number(root.defaults.DEFAULT_NIGHT_TEMPERATURE)

    readonly property int neutralWhiteKelvin:
        Number(root.defaults.DEFAULT_DAY_TEMPERATURE)

    function unquoted(raw: string): string {
        const value = raw.trim();
        const quote = value.charAt(0);
        if (quote === "\"" || quote === "'") {
            return value.slice(1, value.indexOf(quote, 1));
        }
        return value.split("#")[0].trim();
    }

    function assignments(source: string): var {
        const pattern = /^\s*(?:readonly )?(\w+)=(.*)$/;
        const table = ({});
        for (const line of source.split("\n")) {
            const found = line.match(pattern);
            if (!found) continue;
            table[found[1]] = root.unquoted(found[2]);
        }
        return table;
    }

    function text(name: string): string {
        const saved = root.settings[name];
        if (saved !== undefined) return saved;
        return root.defaults[`DEFAULT_${name}`] ?? "";
    }

    function clockMinutes(clock: string): int {
        const parts = clock.split(":");
        return Number(parts[0]) * root.minutesPerHour
            + Number(parts[1]);
    }

    function padded(figure: int): string {
        const shown = `${figure}`;
        return shown.length < root.clockDigits ? `0${shown}` : shown;
    }

    function clockText(minutes: int): string {
        const hours = Math.floor(minutes / root.minutesPerHour);
        const rest = minutes % root.minutesPerHour;
        return `${root.padded(hours)}:${root.padded(rest)}`;
    }

    function serialised(): string {
        const lines = root.configKeys.map(
            name => `${name}="${root.text(name)}"`);
        return `${lines.join("\n")}\n`;
    }

    function write(changes: var): void {
        const next = ({});
        for (const name of root.configKeys) {
            next[name] = root.text(name);
        }
        Object.assign(next, changes);
        root.settings = next;
        pending.restart();
    }

    function runScript(action: string): void {
        root.queue = root.queue.concat([action]);
    }

    function refresh(): void {
        if (probe.running) return;
        probe.running = true;
    }

    function absorb(payload: string): void {
        try {
            root.status = JSON.parse(payload);
        } catch (error) {
            console.error("donbox: night-shift gave no status:",
                error);
        }
    }

    function setEnabled(wanted: bool): void {
        root.write({ ENABLED: wanted ? "1" : "0" });
    }

    function setOverride(wanted: string): void {
        root.runScript(wanted);
    }

    function setNightTemperature(kelvin: int): void {
        root.write({ NIGHT_TEMPERATURE: `${kelvin}` });
    }

    function setDayTemperature(kelvin: int): void {
        root.write({ DAY_TEMPERATURE: `${kelvin}` });
    }

    function setTransition(minutes: int): void {
        root.write({ TRANSITION_MINUTES: `${minutes}` });
    }

    function setNightStart(minutes: int): void {
        root.write({ NIGHT_START: root.clockText(minutes) });
    }

    function setNightEnd(minutes: int): void {
        root.write({ NIGHT_END: root.clockText(minutes) });
    }

    function followTheSun(): void {
        root.write({ NIGHT_START: "", NIGHT_END: "" });
    }

    function followFixedTimes(): void {
        root.write({
            NIGHT_START: root.clockText(root.nightStartMinutes),
            NIGHT_END: root.clockText(root.nightEndMinutes)
        });
    }

    function setFixedTimes(wanted: bool): void {
        if (!wanted) {
            root.followTheSun();
            return;
        }
        root.followFixedTimes();
    }

    function reparse(): void {
        root.settings = root.assignments(confFile.text());
    }

    function readDefaults(): void {
        root.defaults = root.assignments(scriptFile.text());
    }

    Component.onCompleted: {
        root.readDefaults();
        root.reparse();
        root.refresh();
    }

    Timer {
        id: pending

        interval: root.writeDelayMs

        onTriggered: confFile.setText(root.serialised())
    }

    Timer {
        id: dispatch

        running: root.queue.length > 0
        repeat: true
        interval: root.dispatchIntervalMs

        onTriggered: {
            if (control.running) return;
            control.command = [root.scriptPath, root.queue[0]];
            root.queue = root.queue.slice(1);
            control.running = true;
        }
    }

    Process {
        id: control

        onExited: root.refresh()
    }

    Process {
        id: probe

        command: [root.scriptPath, "status"]

        stdout: StdioCollector {
            onStreamFinished: root.absorb(this.text)
        }
    }

    FileView {
        id: confFile

        path: root.path
        watchChanges: true
        blockLoading: true
        atomicWrites: true
        printErrors: false

        onFileChanged: this.reload()
        onLoaded: root.reparse()
        onSaved: root.runScript("apply")
    }

    FileView {
        id: scriptFile

        path: root.scriptPath
        blockLoading: true
        printErrors: false
    }
}
