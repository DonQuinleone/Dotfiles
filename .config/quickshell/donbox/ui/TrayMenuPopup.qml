import QtQuick
import Quickshell
import qs.services

PanelSurface {
    id: root

    required property QsMenuHandle handle

    widthFactor: 1
    contentSpacing: 0

    QsMenuOpener {
        id: opener

        menu: root.handle
    }

    Repeater {
        model: opener.children

        TrayMenuEntry {
            required property QsMenuEntry modelData

            entry: this.modelData

            onDismissed: Panels.close()
        }
    }
}
