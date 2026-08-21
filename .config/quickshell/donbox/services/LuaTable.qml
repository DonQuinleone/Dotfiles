pragma Singleton

import Quickshell
import "logic"

Singleton {
    function quoted(text: string): string {
        return lua.quoted(text);
    }

    function table(fields: var): string {
        return lua.table(fields);
    }

    LuaLiteral {
        id: lua
    }
}
