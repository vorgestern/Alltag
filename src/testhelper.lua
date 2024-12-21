
local funcs={
    countdown=function(arg)
        local N=math.tointeger(arg)
        print(N)
        while N>0 do
            N=N-1
            print(N)
        end
    end,
    exit=function(arg)
        os.exit(math.tointeger(arg))
    end
}

local func,arg1=...

if funcs[func] then return funcs[func](arg1)
else error(string.format("Function '%s' unknown.", func))
end
