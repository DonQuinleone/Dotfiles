pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    readonly property var signalLevels: [
        { floor: 0.8, glyph: "󰤨" },
        { floor: 0.6, glyph: "󰤥" },
        { floor: 0.4, glyph: "󰤢" },
        { floor: 0.2, glyph: "󰤟" },
        { floor: 0.0, glyph: "󰤯" }
    ]

    readonly property string wiredGlyph: "󰈀"
    readonly property string radioOffGlyph: "󰤮"
    readonly property string noAdapterGlyph: "󰲛"
    readonly property string busyGlyph: "󰤩"

    readonly property bool available:
        Networking.backend !== NetworkBackendType.None

    readonly property var devices: Networking.devices?.values ?? []

    readonly property var wifiDevice: root.devices.find(
        device => device.type === DeviceType.Wifi) ?? null
    readonly property var wiredDevice: root.devices.find(
        device => device.type === DeviceType.Wired) ?? null

    readonly property bool wifiPresent: root.wifiDevice !== null
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wifiBlocked: !Networking.wifiHardwareEnabled
    readonly property bool wired: root.wiredDevice?.connected ?? false

    readonly property var network: root.wifiDevice?.networks?.values
        .find(candidate => candidate.connected) ?? null

    readonly property string ssid: root.network?.name ?? ""
    readonly property real strength: root.network?.signalStrength ?? 0
    readonly property int strengthPercent:
        Math.round(root.strength * 100)

    readonly property bool wifiConnected: root.network !== null
    readonly property bool connected: root.wired || root.wifiConnected
    readonly property bool busy:
        root.wifiDevice?.state === ConnectionState.Connecting

    readonly property bool limited:
        Networking.connectivity === NetworkConnectivity.Portal
        || Networking.connectivity === NetworkConnectivity.Limited

    readonly property string glyph: {
        if (root.wired) return root.wiredGlyph;
        if (!root.wifiPresent) return root.noAdapterGlyph;
        if (!root.wifiEnabled) return root.radioOffGlyph;
        if (root.busy) return root.busyGlyph;
        return root.signalLevels.find(
            level => root.strength >= level.floor).glyph;
    }

    readonly property string label: {
        if (root.wired) return "Wired";
        if (!root.wifiPresent) return "No adapter";
        if (root.wifiBlocked) return "Wi-Fi blocked";
        if (!root.wifiEnabled) return "Wi-Fi off";
        if (root.busy) return "Connecting";
        if (!root.wifiConnected) return "Not connected";
        return root.ssid;
    }

    readonly property string detail: {
        if (!root.wifiConnected) return "";
        if (root.limited) return "Limited";
        return `${root.strengthPercent}%`;
    }

    readonly property string summary: root.detail === ""
        ? root.label
        : `${root.label} · ${root.detail}`

    readonly property color tint: {
        if (root.limited) return Theme.palette.warn ?? "white";
        if (root.connected) return Theme.palette.fg ?? "white";
        if (!root.wifiEnabled) return Theme.palette.fgDim ?? "white";
        return Theme.palette.warn ?? "white";
    }

    function toggleWifi(): void {
        if (root.wifiBlocked) return;
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }
}
