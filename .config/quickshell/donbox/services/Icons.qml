pragma Singleton

import Quickshell

Singleton {
    id: root

    function sourceFor(name: string): string {
        if (name === "") return "";
        if (name.includes("://")) return name;
        if (name.startsWith("/")) return `file://${name}`;
        return Quickshell.iconPath(name, true);
    }
}
