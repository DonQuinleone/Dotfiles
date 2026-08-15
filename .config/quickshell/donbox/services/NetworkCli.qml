pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string blockSeparator: "\n\n"
    readonly property string fieldSeparator: ":"
    readonly property string escapeMark: "\\"

    function unescaped(value: string): string {
        return value.replace(/\\(.)/g, "$1");
    }

    function pair(line: string): var {
        const mark = line.indexOf(root.fieldSeparator);
        if (mark < 0) return null;
        return {
            key: line.slice(0, mark),
            value: root.unescaped(line.slice(mark + 1))
        };
    }

    function pairsIn(chunk: string): var {
        return chunk.split("\n")
            .map(line => root.pair(line))
            .filter(found => found !== null);
    }

    function blocksIn(payload: string): var {
        return payload.split(root.blockSeparator)
            .map(chunk => root.pairsIn(chunk))
            .filter(found => found.length > 0);
    }

    function valueOf(fields: var, key: string): string {
        return fields.find(found => found.key === key)?.value ?? "";
    }

    function valuesUnder(fields: var, prefix: string): var {
        return fields
            .filter(found => found.key.startsWith(prefix))
            .map(found => found.value)
            .filter(found => found !== "");
    }

    function columnsIn(line: string): var {
        const parts = [];
        let current = "";
        let index = 0;
        while (index < line.length) {
            const letter = line.charAt(index);
            index += 1;
            if (letter === root.escapeMark) {
                current += line.charAt(index);
                index += 1;
                continue;
            }
            if (letter === root.fieldSeparator) {
                parts.push(current);
                current = "";
                continue;
            }
            current += letter;
        }
        parts.push(current);
        return parts;
    }

    function rowsIn(payload: string): var {
        return payload.split("\n")
            .filter(line => line !== "")
            .map(line => root.columnsIn(line));
    }
}
