
#include <LuaAide.h>

using namespace LuaAide;

int demofail(lua_State*L)
{
    LuaStack Q(L);
    // This Script cannot be compiled (missing parenthesis).
    Q<<LuaCode("Failing Demo", R"xxx(
        function translate(A,
            return 1
        end
    )xxx")>>0;
    Q<<1;
    return 1;
}

#ifndef ALLTAG_EXPORTS
#define ALLTAG_EXPORTS
#endif

const auto keymap_impl=R"__(
return function(L, func)
    if not L then return end
    local A={}
    for k,v in pairs(L) do A[k]=func(v, k) end
    return A
end
)__";

const auto applypairs_impl=R"__(
return function(L, proc)
    if not L then return end
    for k,v in pairs(L) do proc(k,v) end
end
)__";

const auto findfirst_impl=R"__(
return function(L, pred)
    if not L then return end
    pred=pred or function(x) return x end
    for k,v in ipairs(L) do
        if pred(v) then return v,k end
    end
end
)__";

const auto contains_impl=R"__(
return function(L, item)
    if not L or not item then return end
    for k,v in pairs(L) do if v==item then return k end end
end
)__";

const auto filter_impl=R"__(
return function(L, pred)
    if not L then return end
    if not pred then return {} end
    local result={}
    for k,v in ipairs(L) do if pred(v) then table.insert(result,v) end end
    return result
end
)__";

const auto pipe_lines_impl=R"__(
return function(command, linehandler)
    if type(command)~="string" then
        error("Error: pipe_lines: First argument must be a string (command) but is of type "..type(command)..".")
    end
    local pipe=io.popen(command)
    if pipe then
        for line in pipe:lines() do linehandler(line) end
        local flag,status,rc=pipe:close()
        if not flag then return math.tointeger(rc), status
        else return 0
        end
    else
        error(string.format("Error running '%s'", command))
    end
end
)__";

const auto sortedpairs_impl=R"__(
return function(X, sorter)
    local Copy={}
    if X then
        for k,v in pairs(X) do table.insert(Copy, {k,v}) end
    end
    if sorter then
        table.sort(Copy, function(a,b) return sorter(a[1], b[1]) end)
    else
        table.sort(Copy, function(a,b) return a[1]<b[1] end)
    end
    return function(state, control_ignored)
        state.control=next(state.K, state.control)
        if not state.control then return end
        return state.K[state.control][1], state.K[state.control][2]
    end, {K=Copy}
end
)__";

extern "C" ALLTAG_EXPORTS int luaopen_alltag(lua_State*L)
{
    LuaStack Q(L);
    Q<<newtable
        <<"0.1.6">>LuaField("version")
        <<keys>>LuaField("keys")
        <<sortedkeys>>LuaField("sortedkeys")
        <<formatany>>LuaField("formatany")
        <<keyescape>>LuaField("keyescape")
        <<idfunc>>LuaField("idfunc")
        <<demofail>>LuaField("demofail") // Produce an error message at runtime (i.e. Lua-compiletime).
        <<map>>LuaField("map")
        <<apply>>LuaField("apply");

    Q<<LuaCode("keymap-impl", keymap_impl)>>1; Q>>LuaField("keymap");
    Q<<LuaCode("applypairs-impl", applypairs_impl)>>1; Q>>LuaField("applypairs");
    Q<<LuaCode("findfirst-impl", findfirst_impl)>>1; Q>>LuaField("findfirst");
    Q<<LuaCode("contains-impl", contains_impl)>>1; Q>>LuaField("contains");
    Q<<LuaCode("filter-impl", filter_impl)>>1; Q>>LuaField("filter");
    Q<<LuaCode("pipe_lines-impl", pipe_lines_impl)>>1; Q>>LuaField("pipe_lines");
    Q<<LuaCode("sortedpairs-impl", sortedpairs_impl)>>1; Q>>LuaField("sortedpairs");
    return 1;
}
