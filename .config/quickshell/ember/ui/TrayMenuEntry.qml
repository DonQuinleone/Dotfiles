import QtQuick
import Quickshell

Column {
    id: root

    required property QsMenuEntry entry

    signal dismissed

    property bool expanded: false

    width: parent?.width ?? 0

    QsMenuOpener {
        id: submenu

        menu: root.entry
    }

    TrayMenuRow {
        entry: root.entry
        depth: 0

        onTriggered: {
            if (root.entry.hasChildren) {
                root.expanded = !root.expanded;
                return;
            }
            root.entry.triggered();
            root.dismissed();
        }
    }

    Repeater {
        model: root.expanded ? submenu.children : null

        TrayMenuRow {
            required property QsMenuEntry modelData

            entry: this.modelData
            depth: 1

            onTriggered: {
                this.modelData.triggered();
                root.dismissed();
            }
        }
    }
}
