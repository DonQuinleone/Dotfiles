import QtQuick
import qs.services

Row {
    id: root

    spacing: Theme.spacing.normal ?? 0

    NotificationPill {}

    UpdatesIndicator {}

    VpnIndicator {}

    NetworkIndicator {}

    BluetoothIndicator {}

    TalkIndicator {}

    MicrophoneIndicator {}

    SoundIndicator {}

    BatteryIndicator {}
}
