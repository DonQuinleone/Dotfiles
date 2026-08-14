import Quickshell.Wayland
import qs.services

WlSessionLock {
    id: root

    locked: Lock.locked

    // The surface reparents its children after they are built,
    // so anchors against it never resolve.
    WlSessionLockSurface {
        id: surface

        color: Theme.palette.bg ?? "black"

        LockSurface {
            width: surface.width
            height: surface.height
        }
    }
}
