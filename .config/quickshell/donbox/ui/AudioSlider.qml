import QtQuick
import qs.services

Item {
    id: root

    required property real value

    property real minimum: 0.0
    property real maximum: 1.0
    property real mark: 0.0
    property color tint: Theme.palette.accent ?? "white"

    readonly property real span: root.maximum - root.minimum
    readonly property bool marked: root.mark > root.minimum
        && root.mark < root.maximum

    readonly property int knobInset: Theme.sizes.borderWidth ?? 0
    readonly property int knobSize: root.height - root.knobInset * 2
    readonly property real travel:
        root.width - root.knobSize - root.knobInset * 2
    readonly property int markWidth: Theme.sizes.borderWidth ?? 0
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

    signal moved(real wanted)

    implicitHeight: Theme.sizes.hitTarget ?? 0

    function fractionOf(level: real): real {
        if (root.span <= 0) return 0;
        return (level - root.minimum) / root.span;
    }

    function centreOf(level: real): real {
        return root.knobInset + root.travel * root.fractionOf(level)
            + root.knobSize / 2;
    }

    function settle(wanted: real): void {
        root.moved(Math.max(root.minimum,
            Math.min(root.maximum, wanted)));
    }

    function seek(offset: real): void {
        if (root.travel <= 0) return;
        const reached =
            (offset - root.centreOf(root.minimum)) / root.travel;
        root.settle(root.minimum + root.span * reached);
    }

    function stepBy(direction: int): void {
        root.settle(root.value + direction * Levels.step);
    }

    Rectangle {
        id: track

        anchors.fill: parent
        activeFocusOnTab: true
        clip: true
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
            root.stepBy(direction);
            event.accepted = true;
        }

        Rectangle {
            width: root.centreOf(root.value)
            height: parent.height
            radius: parent.radius
            color: root.tint
            opacity: Theme.opacities.muted ?? 1
        }

        Rectangle {
            visible: root.marked
            x: root.centreOf(root.mark)
            width: parent.width - this.x
            height: parent.height
            color: Theme.palette.warn ?? "transparent"
            opacity: Theme.opacities.edge ?? 1
        }

        Rectangle {
            x: root.centreOf(root.value) - root.knobSize / 2
            y: root.knobInset
            width: root.knobSize
            height: root.knobSize
            radius: Theme.radii.round ?? 0
            color: Theme.palette.fg ?? "white"
        }

        Rectangle {
            visible: root.marked
            x: root.centreOf(root.mark) - root.markWidth / 2
            width: root.markWidth
            height: parent.height
            color: Theme.palette.bg ?? "transparent"
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

            onWheel: wheel => {
                if (wheel.angleDelta.y === 0) return;
                root.stepBy(wheel.angleDelta.y > 0 ? 1 : -1);
            }
        }
    }
}
