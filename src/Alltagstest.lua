
local bpattern={
    ["/"]="LuaAide/ulutest/?.so;",
    ["\\"]="LuaAide/ulutest\\?.dll;",
}
package.cpath=(bpattern[package.config:sub(1,1)] or "") .. package.cpath

local ok,alltag=pcall(require, "alltag")

if not ok then
    error("\n\tThis is a test suite for 'alltag'."..
    "\n\tHowever, require 'alltag' failed."..
    "\n\tInstall and build it from luaaide.git.")
end

local ok,ULU=pcall(require, "ulutest")

if not ok then
    error("\n\tThis is a Unit Test implemented with 'ulutest'."..
    "\n\tHowever, require 'ulutest' failed."..
    "\n\tInstall it from luaaide.git.")
end

local TT=ULU.TT

local function TCASE(name)
    return function(tests)
        tests.name=name
        return tests
    end
end

local function setup1(c) return string.format("abc%cdef", c) end

ULU.RUN(

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
    TT("formatany present", function(T)
        T:ASSERT_EQ(type(alltag.formatany), "function")
    end),
    TT("keyescape present", function(T)
        T:ASSERT_EQ(type(alltag.keyescape), "function")
    end),
    TT("map present", function(T)
        T:ASSERT_EQ(type(alltag.map), "function")
    end),
    TT("keymap present", function(T)
        T:ASSERT_EQ(type(alltag.keymap), "function")
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
    TT("handle nil", function(T)
        local ok,X=pcall(alltag.keymap, {x=21,y=true,z=23}, function(x) if type(x)=="number" then return 2*x end end)
        T:ASSERT(ok)
        T:ASSERT_EQ("table", type(X))
        T:ASSERT_EQ(42, X.x)
        T:ASSERT_NIL(X.y)
        T:ASSERT_EQ(46, X.z)
    end),
}

)
