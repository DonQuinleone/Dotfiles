import QtQuick

QtObject {
    id: root

    function quoted(text: string): string {
        return `"${text.replace(/\\/g, "\\\\")
            .replace(/"/g, "\\\"")}"`;
    }

    function literal(value: var): string {
        if (value === null || value === undefined) return "nil";
        if (typeof value === "string") return root.quoted(value);
        if (Array.isArray(value)) return root.list(value);
        if (value !== null && typeof value === "object")
            return root.table(value);
        return `${value}`;
    }

    function list(values: var): string {
        const items = values.map(value => root.literal(value));
        return `{ ${items.join(", ")} }`;
    }

    function table(fields: var): string {
        const written = Object.keys(fields)
            .filter(key => fields[key] !== undefined)
            .map(key => `${key} = ${root.literal(fields[key])}`);
        return `{ ${written.join(", ")} }`;
    }
}
