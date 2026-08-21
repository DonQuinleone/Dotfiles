import QtQuick

QtObject {
    id: root

    function plain(value: var): string {
        if (value === undefined || value === null) return "";
        return `${value}`;
    }

    // A desktop entry names the application exactly; its own name
    // for itself is what is left to go on, and its case is its own.
    function ruleFor(applications: var, appName: var,
        desktopEntry: var): var {

        const exact = applications[desktopEntry]
            ?? applications[appName];
        if (exact) return exact;
        const wanted = root.plain(appName).toLowerCase();
        const key = Object.keys(applications)
            .find(name => name.toLowerCase() === wanted);
        return key ? applications[key] : ({});
    }

    function fallbackFor(defaults: var, urgency: string): var {
        return defaults[urgency] ?? ({});
    }

    function setting(rule: var, fallback: var, name: string): var {
        return rule[name] !== undefined
            ? rule[name]
            : fallback[name];
    }
}
