
CPPFLAGS := -ILuaAide/include -I/usr/include/lua5.4 -ILuaAide
CXXFLAGS := --std=c++20 -Wall -Werror

.PHONY: clean dir prerequisites test

all: dir LuaAide/libLuaAide.a alltag.so
dir:
	@mkdir -p b
clean:
	@rm -rf b alltag.so
	@make -C LuaAide clean

alltag.so: b/main.o LuaAide/libLuaAide.a
	@echo "\nmake alltag.so: $@"
	@g++ -shared -fpic -o $@ $^

b/%.o: src/%.cpp $(XHEADER)
	@g++ -c -Wall -Werror -fpic -o $@ $< $(CPPFLAGS) $(CXXFLAGS)

LuaAide/libLuaAide.a:
	@echo "\nmake LuaAide"
	@make -C LuaAide

test:
	@echo "\nAlltagstest"
	@lua src/Alltagstest.lua
