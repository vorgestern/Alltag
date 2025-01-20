
# alltag

Provides functions that prove helpful in daily use.

Thoroughly unit-tested.
Read unittest src/Alltagstest.lua for details.

## alltag.formatany(value)

Produces a string representation of the value, that can reproduce value
when loading it. Data types with a binary internal representation will
not be represented correctly. 

    print(alltag.formatany(21))                             return 21
    print(alltag.formatany {21,22,23, a=1, b=2})            return {[1]=21, [2]=22, [3]=23, a=1, b=2}
    local X={21, 22, a=1, b=2}
    local Y=load(alltag.formatany(X))()
    for k,v in pairs(Y) do print(k, v, X[k]) end            1 21 21    (order undefined)
                                                            2 22 22
                                                            a 1  1
                                                            b 2  2

## alltag.keyescape(value)

Format a value in a form suitable for a table key.

    print(alltag.keyescape "ö")                             ["\xC3\xB6"]
    print(alltag.keyescape "a")                             a
    print(alltag.keyescape "a c")                           ["a c"]
    print(alltag.keyescape "21")                            ["21"]
    print(alltag.keyescape "{a}")                           ["{a}"]

## alltag.map(List, func)

alltag.map(L, f) returns a list {f(value)} for all value in L

    local m=alltag.map({1, true, "22"}, tostring)
    print(table.concat(m, "-"))                             1-true-22

## alltag.keymap(Table, func)

alltag.keymap(K, f) returns a list {key=f(value,key)} for all k,value in L

    local L={a=21, b=22, "A", "B"}
    local f1=function(v,k)
        if type(k)=="string" then return v; end
    end
    local f2=function(v,k)
        if type(k)~="string" then return v; end
    end
    print(alltag.formatany(alltag.keymap(L, f1)))           return {
                                                                a=21,
                                                                b=22
                                                            }
    print(alltag.formatany(alltag.keymap(L, f2)))           return {"A", "B"}

## alltag.apply(List, func)

    alltag.apply({1, true, 22}, print)                      1
                                                            true
                                                            22

## alltag.applypairs(Table, func)

    alltag.applypairs({1, true, 22}, function(k,v)          1=1
        print(k.."="..tostring(v))                          2=true
    end)                                                    3=22

## alltag.findfirst(List, value)

alltag.findfist(L, f) returns the first v,k from ipairs(L) that satisfy predicate f:

    print(alltag.findfirst({21,22,23}, function(v)          22  2
        return v>21
    end))

## alltag.contains(List, value)

alltag.contains(L,value) returns the (first) index with List[index]==value,
or nil if value does not occur in List.

    print(alltag.contains({21,22,23}, 22))                  2
    if alltag.contains({21,22,23}, 28) then 
        error "unexpected"
    end

## alltag.filter(List, predicate)

alltag.filter returns only those elements of the list that satisfy predicate.

## alltag.pipe_lines(command, linefunc)

will execute command as a separate process and passes its output linewise
to function linefunc. Will error if command fails.

        local count=0
        alltag.pipe_lines("lua src/testhelper.lua countdown 10", function(line) count=count+1 end)

        print(count)                                        11

# How to build: first

    git submodule init
    git submodule update
    cd LuaAide
    git submodule init
    git submodule update

## .. then on Windows

Use Visual Studio 2022 (VS17)

- Edit buildsys/VS17/Lua.props to point to your Lua installation.
- Build with buildsys/VS17/alltag.sln

## .. else on Linux

- Make sure Lua is installed: ```sudo apt-get install lua5.4``` or equivalent.
- Use Makefile
