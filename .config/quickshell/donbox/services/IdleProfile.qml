pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int secondsPerMinute: 60
    readonly property string laptopPanelName: "eDP-1"
    readonly property string unknownGlyph: "󰔛"

    readonly property string script:
        `${Preferences.configHome}/hypr/scripts/idle-profile`

    readonly property var steps: [
        { token: "brightnessctl",
          label: qsTr("Dim the screen"), glyph: "󰃝" },
        { token: "idle-screensaver",
          label: qsTr("Start the screensaver"), glyph: "󰙴" },
        { token: "lock-session",
          label: qsTr("Lock the session"), glyph: "󰌾" },
        { token: "dpms",
          label: qsTr("Turn the screens off"), glyph: "󰍸" },
        { token: "systemctl suspend",
          label: qsTr("Suspend the machine"), glyph: "󰒲" }
    ]

    readonly property var profiles: [
        { docked: true, file: "hypridle.conf",
          title: qsTr("Docked") },
        { docked: false, file: "hypridle-undocked.conf",
          title: qsTr("Undocked") }
    ]

    property string configPath: ""
    property bool running: false
    property var rows: []

    readonly property int externalScreens: Quickshell.screens
        .filter(screen => screen.name !== root.laptopPanelName)
        .length

    readonly property bool docked: root.externalScreens > 0

    readonly property string configName:
        root.configPath.split("/").pop()

    readonly property var wanted: root.profiles
        .find(profile => profile.docked === root.docked)

    readonly property var active: root.profiles
        .find(profile => root.configPath.endsWith(profile.file))

    readonly property string title:
        root.active ? root.active.title : root.configName

    readonly property bool matched:
        root.active !== undefined && root.active === root.wanted

    function counted(count: int, one: string, many: string): string {
        return `${count} ${count === 1 ? one : many}`;
    }

    function spell(seconds: int): string {
        const minutes = Math.floor(seconds / root.secondsPerMinute);
        const rest = seconds % root.secondsPerMinute;
        const spelt = [];
        if (minutes > 0)
            spelt.push(root.counted(
                minutes, qsTr("minute"), qsTr("minutes")));
        if (rest > 0 || minutes === 0)
            spelt.push(root.counted(
                rest, qsTr("second"), qsTr("seconds")));
        return spelt.join(qsTr(" and "));
    }

    function describe(command: string): var {
        const known = root.steps.find(
            step => command.indexOf(step.token) >= 0);
        if (known) return known;
        return { token: "", label: command, glyph: root.unknownGlyph };
    }

    function absorb(text: string): void {
        const variables = ({});
        const found = [];
        let pending = null;
        for (const raw of text.split("\n")) {
            const line = raw.trim();
            if (line.startsWith("#")) continue;
            if (line.startsWith("listener")) {
                pending = ({});
                continue;
            }
            if (line.startsWith("}")) {
                if (pending && pending.command && pending.seconds > 0)
                    found.push(Object.assign(
                        { seconds: pending.seconds },
                        root.describe(pending.command)));
                pending = null;
                continue;
            }
            const at = line.indexOf("=");
            if (at < 0) continue;
            const key = line.slice(0, at).trim();
            const value = line.slice(at + 1).trim();
            if (key.startsWith("$")) {
                variables[key] = value;
                continue;
            }
            if (!pending) continue;
            if (key === "timeout")
                pending.seconds = Number(variables[value] ?? value);
            if (key === "on-timeout") pending.command = value;
        }
        root.rows = found.sort(
            (first, second) => first.seconds - second.seconds);
    }

    function locate(payload: string): void {
        const found = payload.match(/-c\s+(\S+)/);
        root.running = payload.trim() !== "";
        root.configPath = found ? found[1] : "";
        if (root.configPath === "") root.rows = [];
    }

    function refresh(): void {
        if (probe.running) return;
        probe.running = true;
    }

    function apply(): void {
        if (switcher.running) return;
        switcher.running = true;
    }

    Component.onCompleted: root.refresh()

    Process {
        id: probe

        command: ["ps", "-C", "hypridle", "-o", "args="]

        stdout: StdioCollector {
            onStreamFinished: root.locate(this.text)
        }
    }

    Process {
        id: switcher

        command: [root.script]

        onExited: root.refresh()
    }

    FileView {
        path: root.configPath
        watchChanges: true
        printErrors: false

        onFileChanged: this.reload()
        onLoaded: root.absorb(this.text())
        onLoadFailed: root.rows = []
    }
}
