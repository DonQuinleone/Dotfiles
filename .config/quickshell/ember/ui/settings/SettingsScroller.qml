import QtQuick
import QtQuick.Window
import qs.services

Flickable {
    id: root

    default property alias content: holder.data

    readonly property Item focused: root.Window.activeFocusItem
    readonly property int margin: Theme.spacing.loose ?? 0

    contentWidth: root.width
    contentHeight: holder.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    onFocusedChanged: root.reveal()

    function limit(wanted: real): real {
        const furthest = Math.max(0, root.contentHeight - root.height);
        return Math.max(0, Math.min(furthest, wanted));
    }

    // Tabbing must bring the control into view by itself: a
    // magnified viewport shows only a slice of the window.
    function reveal(): void {
        const item = root.focused;
        if (!item) return;
        const top = item.mapToItem(holder, 0, 0).y;
        if (top < root.contentY) {
            root.contentY = root.limit(top - root.margin);
            return;
        }
        const bottom = top + item.height;
        if (bottom <= root.contentY + root.height) return;
        root.contentY =
            root.limit(bottom - root.height + root.margin);
    }

    Column {
        id: holder

        width: root.width
        spacing: Theme.spacing.loose ?? 0
    }
}
