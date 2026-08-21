import QtQuick

QtObject {
    function layoutOf(workspace): string {
        return workspace?.lastIpcObject?.tiledLayout ?? "";
    }

    // A workspace reports the layout its tiles are arranged by
    // even when the window in front of them is floating, so the
    // focused window is asked instead.
    function floatingOn(focused: var, workspaceName: string): bool {
        if (!focused) return false;
        if (focused.workspace?.name !== workspaceName) return false;
        return focused.floating === true;
    }
}
