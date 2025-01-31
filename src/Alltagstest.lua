
local bpattern={
    ["/"]="LuaAide/ulutest/?.so;",
    ["\\"]="LuaAide/ulutest\\?.dll;",
}
package.cpath=(bpattern[package.config:sub(1,1)] or "") .. package.cpath

local ok,alltag=pcall(require, "alltag")

if not ok then
    error("\n\tThis is a test suite for 'alltag'."..
    "\n\tHowever, require 'alltag' failed."..
    "\n\tInstall and build it right here.")
end

local ok,ULU=pcall(require, "ulutest")

if not ok then
    error("\n\tThis is a Unit Test implemented with 'ulutest'."..
    "\n\tHowever, require 'ulutest' failed."..
    "\n\tBuild it as a submodule of submodule LuaAide right here.")
end

local TT=ULU.TT

local function TCASE(name)
    return function(tests)
        tests.name=name
        return tests
    end
end

local function setup1(c) return string.format("abc%cdef", c) end

ULU.RUN {

TCASE "Version" {
    TT("version present", function(T)
        T:ASSERT_EQ(type(alltag.version), "string")
    end),
    TT("version sufficient", function(T)
        local maj,min=alltag.version:match "^(%d+)%.(%d+)"
        local Maj,Min=math.tointeger(maj),math.tointeger(min)
        T:ASSERT(100*Maj+Min>=1) -- Version mindestens 0.1
    end)
},

TCASE "Functions present" {
    TT("formatany", function(T)
        T:ASSERT_EQ("function", type(alltag.formatany))
    end),
    TT("keyescape", function(T)
        T:ASSERT_EQ("function", type(alltag.keyescape))
    end),
    TT("map", function(T)
        T:ASSERT_EQ("function", type(alltag.map))
    end),
    TT("keymap", function(T)
        T:ASSERT_EQ("function", type(alltag.keymap))
    end),
    TT("apply", function(T)
        T:ASSERT_EQ("function", type(alltag.apply))
    end),
    TT("applypairs", function(T)
        T:ASSERT_EQ("function", type(alltag.applypairs))
    end),
    TT("findfirst", function(T)
        T:ASSERT_EQ("function", type(alltag.findfirst))
    end),
    TT("contains", function(T)
        T:ASSERT_EQ("function", type(alltag.contains))
    end),
    TT("filter", function(T)
        T:ASSERT_EQ("function", type(alltag.filter))
    end),
    TT("pipe_lines", function(T)
        T:ASSERT_EQ("function", type(alltag.pipe_lines))
    end),
},

TCASE "keyescape" {
    TT("escape bell",      function(T) T:ASSERT_EQ('["abc\\adef"]', alltag.keyescape(setup1(7))) end),
    TT("escape backspace", function(T) T:ASSERT_EQ('["abc\\bdef"]', alltag.keyescape(setup1(8))) end),
    TT("escape tab",       function(T) T:ASSERT_EQ('["abc\\tdef"]', alltag.keyescape(setup1(9))) end),
    TT("escape lf",        function(T) T:ASSERT_EQ('["abc\\ndef"]', alltag.keyescape(setup1(10))) end),
    TT("escape ff",        function(T) T:ASSERT_EQ('["abc\\fdef"]', alltag.keyescape(setup1(12))) end),
    TT("escape cr",        function(T) T:ASSERT_EQ('["abc\\rdef"]', alltag.keyescape(setup1(13))) end),
    TT("escape escape",    function(T) T:ASSERT_EQ('["abc\\x1Bdef"]', alltag.keyescape(setup1(27))) end),
    TT("escape 21",        function(T) T:ASSERT_EQ('["abc\\x15def"]', alltag.keyescape(setup1(21))) end),
    TT("escape space",     function(T) T:ASSERT_EQ('["abc def"]',   alltag.keyescape("abc def")) end),
    TT("escape dot",       function(T) T:ASSERT_EQ('["abc.def"]',   alltag.keyescape("abc.def")) end),
--  TT("escape ä",         function(T) T:ASSERT_EQ('["abcädef"]', alltag.keyescape("abcädef")) end),
--  TT("escape ö",         function(T) T:ASSERT_EQ('["abcödef"]', alltag.keyescape("abcödef")) end),
--  TT("escape ü",         function(T) T:ASSERT_EQ('["abcüdef"]', alltag.keyescape("abcüdef")) end),
--  TT("escape Ä",         function(T) T:ASSERT_EQ('["abcÄdef"]', alltag.keyescape("abcÄdef")) end),
--  TT("escape Ö",         function(T) T:ASSERT_EQ('["abcÖdef"]', alltag.keyescape("abcÖdef")) end),
--  TT("escape Ü",         function(T) T:ASSERT_EQ('["abcÜdef"]', alltag.keyescape("abcÜdef")) end),
--  TT("escape ß",         function(T) T:ASSERT_EQ('["abcßdef"]', alltag.keyescape("abcßdef")) end),
},

TCASE "formatany" {
    TT("1", function(T)
        local X=alltag.formatany {21,22,23}
        local ok,R=pcall(load, X)
        T:ASSERT(ok)
        R=R()
        T:ASSERT_EQ(R[1], 21)
        T:ASSERT_EQ(R[2], 22)
        T:ASSERT_EQ(R[3], 23)
    end),
    TT("2", function(T)
        local X=alltag.formatany {a={aa={aaa=111}, ab={aba=121}}, b={ba=21}}
        local ok,R=pcall(load, X)
        T:ASSERT(ok)
        R=R()
        T:ASSERT_EQ(R.a.aa.aaa, 111)
        T:ASSERT_EQ(R.a.ab.aba, 121)
        T:ASSERT_EQ(R.b.ba, 21)
    end),
    TT("without arguments, 'return nil' is expected", function(T)
        T:ASSERT_EQ("return nil", alltag.formatany())
    end),
},

TCASE "map" {
    TT("regular call", function(T)
        local X=alltag.map({21,22,23}, function(x) return 2*x end)
        T:ASSERT_EQ(X[1], 42)
        T:ASSERT_EQ(X[2], 44)
        T:ASSERT_EQ(X[3], 46)
    end),
    TT("empty", function(T)
        local X=alltag.map({}, function(x) return 2*x end)
        T:ASSERT_EQ("table", type(X))
        T:ASSERT_EQ(0, #X)
    end),
    TT("tolerate nil", function(T)
        local X=alltag.map(nil, function(x) return 2*x end)
        T:ASSERT_EQ("nil", type(X))
    end),
    TT("handle nil", function(T)
        local ok,X=pcall(alltag.map, {21,true,23}, function(x) if type(x)=="number" then return 2*x end end)
        T:ASSERT_NIL(ok)
        T:ASSERT_EQ("string", type(X))
        T:PRINTF("Error message: %s", X)
    end),
},

TCASE "keymap" {
    TT("regular call", function(T)
        local X=alltag.keymap({x=21,y=22,z=23}, function(x,k) return 2*x end)
        T:ASSERT_EQ(42, X.x)
        T:ASSERT_EQ(44, X.y)
        T:ASSERT_EQ(46, X.z)
    end),
    TT("empty", function(T)
        local X=alltag.keymap({}, function(x,k) return 2*x end)
        T:ASSERT_EQ("table", type(X))
        T:ASSERT_EQ(0, #X)
    end),
    TT("tolerate nil", function(T)
        local X=alltag.keymap(nil, function(x,k) return 2*x end)
        T:ASSERT_EQ("nil", type(X))
    end),
    TT("handle nil", function(T)
        local ok,X=pcall(alltag.keymap, {x=21,y=true,z=23}, function(x) if type(x)=="number" then return 2*x end end)
        T:ASSERT(ok)
        T:ASSERT_EQ("table", type(X))
        T:ASSERT_EQ(42, X.x)
        T:ASSERT_NIL(X.y)
        T:ASSERT_EQ(46, X.z)
    end),
},

TCASE "apply" {
    TT("regular call", function(T)
        local Collector={}
        local X=alltag.apply({21,22,23}, function(x) table.insert(Collector, tostring(x)) end)
        T:ASSERT_EQ(3, #Collector)
        T:ASSERT_EQ("21", Collector[1])
        T:ASSERT_EQ("22", Collector[2])
        T:ASSERT_EQ("23", Collector[3])
    end),
    TT("empty", function(T)
        local X=alltag.apply({}, function(x) end)
        T:ASSERT_EQ("nil", type(X))
    end),
    TT("tolerate nil", function(T)
        local X=alltag.apply(nil, function(x) end)
        T:ASSERT_EQ("nil", type(X))
    end),
},

TCASE "applypairs" {
    TT("regular call", function(T)
        local Keys={"x", "y", "z"}
        local Collector={}
        local X=alltag.applypairs({21,22,23}, function(k,v) Collector[Keys[k] or k]=v end)
        T:ASSERT_EQ("number", type(Collector.x))
        T:ASSERT_EQ("number", type(Collector.y))
        T:ASSERT_EQ("number", type(Collector.z))
        T:ASSERT_EQ(21, Collector.x)
        T:ASSERT_EQ(22, Collector.y)
        T:ASSERT_EQ(23, Collector.z)
    end),
    TT("empty", function(T)
        local X=alltag.applypairs({}, function(k,v) end)
        T:ASSERT_EQ("nil", type(X))
    end),
    TT("tolerate nil", function(T)
        local X=alltag.applypairs(nil, function(k,v) end)
        T:ASSERT_EQ("nil", type(X))
    end),
},

TCASE "findfirst" {
    TT("regular call", function(T)
        local v,k=alltag.findfirst({21,22,23}, function(v) return v==22 end)
        T:ASSERT_EQ("number", type(v))
        T:ASSERT_EQ("number", type(k))
        T:ASSERT_EQ(22, v)
        T:ASSERT_EQ(2, k)
    end),
    TT("empty", function(T)
        local v,k=alltag.findfirst({}, function(v) end)
        T:ASSERT_EQ("nil", type(v))
        T:ASSERT_EQ("nil", type(k))
    end),
    TT("tolerate nil", function(T)
        local v,k=alltag.findfirst(nil, function(v) end)
        T:ASSERT_EQ("nil", type(v))
        T:ASSERT_EQ("nil", type(k))
        local v,k=alltag.findfirst({21,22,23})
        T:ASSERT_EQ("number", type(v))
        T:ASSERT_EQ("number", type(k))
        T:ASSERT_EQ(21, v)
        T:ASSERT_EQ(1, k)
    end),
},

TCASE "contains" {
    TT("regular call", function(T)
        local k=alltag.contains({21,22,23}, 22)
        T:ASSERT_EQ("number", type(k))
        T:ASSERT_EQ(2, k)
        local k=alltag.contains({21,22,23}, 99)
        T:ASSERT_NIL(k)
    end),
    TT("empty", function(T)
        local k=alltag.contains({}, 22)
        T:ASSERT_NIL(k)
    end),
    TT("tolerate nil", function(T)
        local k=alltag.contains(nil, 22)
        T:ASSERT_NIL(k)
        local k=alltag.contains({21,22,23})
        T:ASSERT_NIL(k)
        local k=alltag.contains()
        T:ASSERT_NIL(k)
    end),
},

TCASE "filter" {
    TT("regular call", function(T)
        local X=alltag.filter({21,22,23}, function(v) return v>21 end)
        T:ASSERT_EQ("table", type(X))
        T:ASSERT_EQ(2, #X)
        T:ASSERT_EQ(22, X[1])
        T:ASSERT_EQ(23, X[2])
        local X=alltag.filter({21,22,23}, function(v) end)
        T:ASSERT_EQ("table", type(X))
        T:ASSERT_EQ(0, #X)
    end),
    TT("empty", function(T)
        local X=alltag.filter({}, function(v) return true end)
        T:ASSERT_EQ("table", type(X))
        T:ASSERT_EQ(0, #X)
    end),
    TT("tolerate nil", function(T)
        local X=alltag.filter(nil, function(v) return true end)
        T:ASSERT_NIL(X)
        local X=alltag.filter({21,22,23})
        T:ASSERT_EQ("table", type(X))
        T:ASSERT_EQ(0, #X)
    end),
},

TCASE "pipe_lines" {
    TT("regular call", function(T)
        local count=0
        alltag.pipe_lines("lua src/testhelper.lua countdown 10", function(line) count=count+1 end)
        T:ASSERT_EQ(11, count)
        count=0
        local ok=pcall(alltag.pipe_lines, "lua src/testhelper.lua exit 0", function(line) count=count+1 end)
        T:ASSERT(ok)
        T:ASSERT_EQ(0, count)
    end),
    TT("empty", function(T)
        local ok,rest=pcall(alltag.pipe_lines, "", function(line) end)
        T:ASSERT(ok)
    end),
    TT("tolerate nil", function(T)
        local ok=pcall(alltag.pipe_lines, nil, function(v) end)
        T:ASSERT_NIL(ok)
        local ok=pcall(alltag.pipe_lines, "lua src/testhelper.lua exit 0", nil)
        T:ASSERT(ok)
    end),
}

}
