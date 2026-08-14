import QtQuick
import qs.services

Column {
    id: root

    required property string title
    required property string glyph
    required property real value
    required property var words

    property color tint: Theme.palette.accent ?? "white"

    readonly property real minimum: 0.0
    readonly property real maximum: 1.0
    readonly property int trackHeight: Theme.sizes.hitTarget ?? 0
    readonly property int knobInset: Theme.sizes.borderWidth ?? 0
    readonly property int knobSize:
        root.trackHeight - root.knobInset * 2
    readonly property int focusBorderFactor: 2

    readonly property var keySteps: ({
        [Qt.Key_Left]: -1,
        [Qt.Key_Down]: -1,
        [Qt.Key_Minus]: -1,
        [Qt.Key_Right]: 1,
        [Qt.Key_Up]: 1,
        [Qt.Key_Plus]: 1,
        [Qt.Key_Equal]: 1
    })

    signal moved(real fraction)

    spacing: Theme.spacing.tight ?? 0

    function settle(fraction: real): void {
        root.moved(Math.max(root.minimum,
            Math.min(root.maximum, fraction)));
    }

    function seek(position: real): void {
        const span = track.width - root.knobSize;
        if (span <= 0) return;
        root.settle((position - root.knobSize / 2) / span);
    }

    function stepBy(delta: real): void {
        root.settle(root.value + delta);
    }

    function focusTrack(): void {
        track.forceActiveFocus();
    }

    Item {
        width: parent.width
        height: heading.implicitHeight

        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacing.tight ?? 0

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.glyph
                color: root.tint
                font.family: Theme.fonts.mono ?? ""
                font.pixelSize: Theme.sizes.iconNormal ?? 0
            }

            Text {
                id: heading

                anchors.verticalCenter: parent.verticalCenter
                text: root.title
                color: Theme.palette.fg ?? "white"
                font.family: Theme.fonts.ui ?? ""
                font.pixelSize: Theme.fontSizes.large ?? 0
                font.weight: Theme.fontWeights.medium ?? 0
            }
        }

        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: Levels.readout(root.words, root.value)
            color: Theme.palette.fg ?? "white"
            font.family: Theme.fonts.mono ?? ""
            font.pixelSize: Theme.fontSizes.large ?? 0
            font.features: ({ "tnum": 1 })
        }
    }

    Rectangle {
        id: track

        width: parent.width
        height: root.trackHeight
        activeFocusOnTab: true
        radius: Theme.radii.normal ?? 0
        color: Theme.palette.surface ?? "transparent"
        border.width: (Theme.sizes.borderWidth ?? 0)
            * (this.activeFocus ? root.focusBorderFactor : 1)
        border.color: area.pressed || this.activeFocus
            ? root.tint
            : (Theme.palette.border ?? "transparent")

        Keys.onPressed: event => {
            const direction = root.keySteps[event.key];
            if (direction === undefined) return;
            root.stepBy(direction * Levels.step);
            event.accepted = true;
        }

        Rectangle {
            width: knob.x + root.knobSize / 2
            height: parent.height
            radius: parent.radius
            color: root.tint
            opacity: Theme.opacities.muted ?? 1
        }

        Rectangle {
            id: knob

            x: root.knobInset
                + (track.width - root.trackHeight) * root.value
            y: root.knobInset
            width: root.knobSize
            height: root.knobSize
            radius: Theme.radii.round ?? 0
            color: Theme.palette.fg ?? "white"
        }

        MouseArea {
            id: area

            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onPressed: mouse => {
                track.forceActiveFocus();
                root.seek(mouse.x);
            }
            onPositionChanged: mouse => root.seek(mouse.x)
        }
    }
}
