pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string trueWord: "true"
    readonly property string groupOpener: "["

    function pairs(text: string): var {
        const found = ({});
        for (const line of text.split("\n")) {
            const at = line.indexOf("=");
            if (at < 0) continue;
            found[line.slice(0, at).trim()] =
                line.slice(at + 1).trim();
        }
        return found;
    }

    function assigns(line: string, key: string): bool {
        const at = line.indexOf("=");
        if (at < 0) return false;
        return line.slice(0, at).trim() === key;
    }

    function bounds(lines: var, header: string): var {
        const start = lines
            .findIndex(line => line.trim() === header);
        if (start < 0) return ({ start: -1, end: -1 });
        const next = lines.slice(start + 1).findIndex(
            line => line.trim().startsWith(root.groupOpener));
        return ({
            start: start,
            end: next < 0 ? lines.length : start + 1 + next
        });
    }

    function group(text: string, header: string): var {
        const lines = text.split("\n");
        const span = root.bounds(lines, header);
        if (span.start < 0) return ({});
        return root.pairs(
            lines.slice(span.start + 1, span.end).join("\n"));
    }

    function truthy(value: string): bool {
        return value === root.trueWord;
    }

    function replaced(text: string, header: string, key: string,
        value: string): string {
        const lines = text.split("\n");
        const span = root.bounds(lines, header);
        if (span.start < 0) return text;
        const kept = lines.slice(span.start + 1, span.end)
            .filter(line => !root.assigns(line, key));
        return lines.slice(0, span.start + 1)
            .concat(kept, [`${key}=${value}`],
                lines.slice(span.end))
            .join("\n");
    }
}
