pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int settleMs: 250
    readonly property string fallbackCursorTheme: "Adwaita"

    readonly property string caretFlag:
        `${Preferences.stateDirectory}/caret-follow.on`

    readonly property string cursorTheme:
        Quickshell.env("XCURSOR_THEME") ?? root.fallbackCursorTheme

    property bool caretFollow: false

    function refresh(): void {
        if (probe.running) return;
        probe.running = true;
    }

    function enableCaretFollow(): void {
        flag.setText("");
        Preferences.set("detachedCamera", false);
    }

    // The caret daemon steers the magnifier by warping the
    // pointer, so a detached camera would ignore it.
    function setCaretFollow(wanted: bool): void {
        root.caretFollow = wanted;
        if (!wanted) {
            Quickshell.execDetached(["rm", "-f", root.caretFlag]);
            return;
        }
        root.enableCaretFollow();
    }

    function setCursorSize(size: int): void {
        Preferences.set("cursorSize", size);
        resize.restart();
    }

    Timer {
        id: resize

        interval: root.settleMs

        onTriggered: {
            if (cursor.running) {
                this.restart();
                return;
            }
            cursor.command = ["hyprctl", "setcursor",
                root.cursorTheme, `${Preferences.value("cursorSize")}`];
            cursor.running = true;
        }
    }

    Process {
        id: cursor
    }

    Process {
        id: probe

        command: ["test", "-e", root.caretFlag]

        onExited: code => root.caretFollow = code === 0
    }

    FileView {
        id: flag

        path: root.caretFlag
        printErrors: false
    }
}
