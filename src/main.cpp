
#include <LuaAide.h>
#include <iostream>
#include <filesystem>

using namespace std;
using fspath=filesystem::path;

int demofail(lua_State*L)
{
    LuaStack Q(L);
    // Dieses Skript lässt sich nicht kompilieren (fehlende Klammer).
    Q<<make_pair("Failing Demo", LuaCode(R"xxx(
        function translate(A,
            return 1
        end
    )xxx"))>>0;
    Q<<1;
    return 1;
}

#ifndef ALLTAG_EXPORTS
#define ALLTAG_EXPORTS
#endif

const auto map_impl=LuaCode(R"__(
return function(L, func)
    if not L then return end
    local A={}
    for j,v in ipairs(L) do
        local result=func(v)
        if not result then error(string.format("function returns nil for element %d, which is: %s", j, v)) end
        table.insert(A, result)
    end
    return A
end
)__");

const auto keymap_impl=LuaCode(R"__(
return function(L, func)
    if not L then return end
    local A={}
    for k,v in pairs(L) do A[k]=func(v, k) end
    return A
end
)__");

extern "C" ALLTAG_EXPORTS int luaopen_alltag(lua_State*L)
{
    LuaStack Q(L);
    Q<<newtable
        <<"0.1">>LuaField("version")
        <<formatany>>LuaField("formatany")
        <<keyescape>>LuaField("keyescape")
        <<demofail>>LuaField("demofail"); // Produziert eine Fehlermeldung aus einem Aufruf von LuaAide.

    Q<<make_pair("map-impl", map_impl)>>1; Q>>LuaField("map");
    Q<<make_pair("keymap-impl", keymap_impl)>>1; Q>>LuaField("keymap");
    return 1;
}
