import QtQuick
import qs.services

Grid {
    id: root

    readonly property int columnsShown: 2
    readonly property int gap: Theme.spacing.tight ?? 0
    readonly property int cellWidth:
        (root.width - root.gap * (root.columnsShown - 1))
        / root.columnsShown

    readonly property var entries: [
        {
            title: "Wi-Fi",
            glyph: () => Connectivity.glyph,
            detail: () => Connectivity.summary,
            active: () => Connectivity.wifiEnabled,
            shown: () => Connectivity.available
                && Connectivity.wifiPresent,
            act: () => Connectivity.toggleWifi()
        },
        {
            title: "Bluetooth",
            glyph: () => BluetoothRadio.glyph,
            detail: () => BluetoothRadio.label,
            active: () => BluetoothRadio.powered,
            shown: () => BluetoothRadio.available,
            act: () => BluetoothRadio.togglePower()
        },
        {
            title: "Do not disturb",
            glyph: () => NotificationStore.doNotDisturb
                ? "󰂛" : "󰂚",
            detail: () => NotificationStore.doNotDisturb
                ? "Silenced" : "Notifying",
            active: () => NotificationStore.doNotDisturb,
            shown: () => true,
            act: () => NotificationStore.toggleDoNotDisturb()
        },
        {
            title: "Sound",
            glyph: () => Osd.sinkMuted ? "󰝟" : "󰕾",
            detail: () => Osd.sinkMuted ? "Muted" : "On",
            active: () => !Osd.sinkMuted,
            shown: () => Osd.sink !== null,
            act: () => Osd.toggleMute()
        }
    ]

    columns: root.columnsShown
    spacing: root.gap

    Repeater {
        model: root.entries

        QuickToggle {
            required property var modelData

            width: root.cellWidth
            visible: this.modelData.shown()
            glyph: this.modelData.glyph()
            title: this.modelData.title
            detail: this.modelData.detail()
            active: this.modelData.active()

            onActivated: this.modelData.act()
        }
    }
}
