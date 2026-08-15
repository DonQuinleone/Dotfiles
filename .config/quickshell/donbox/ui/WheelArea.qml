import QtQuick

MouseArea {
    id: root

    // A mouse reports one notch of its wheel as 120 units. A
    // touchpad reports the same gesture as a long stream of much
    // smaller ones, so acting on every event spends a whole step
    // per event and runs away. They are added up instead and
    // spent one notch at a time, which is what the rest of the
    // desktop does with the same gesture.
    readonly property int unitsPerNotch: 120

    property real carried: 0

    signal stepped(int direction)

    function absorb(units: real): void {
        if (units === 0) return;
        if (units > 0 !== root.carried > 0) root.carried = 0;
        root.carried += units;
        while (root.carried >= root.unitsPerNotch) {
            root.carried -= root.unitsPerNotch;
            root.stepped(1);
        }
        while (root.carried <= -root.unitsPerNotch) {
            root.carried += root.unitsPerNotch;
            root.stepped(-1);
        }
    }

    onWheel: wheel => root.absorb(wheel.angleDelta.y)
}
