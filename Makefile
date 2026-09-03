
CPPFLAGS := -ILuaAide/include -I/usr/include/lua5.4 -ILuaAide
CXXFLAGS := --std=c++20 -Wall -Werror

.PHONY: clean dir prerequisites test staticlib

all: dir staticlib alltag.so
dir:
	@mkdir -p b
clean:
	@rm -rf b alltag.so
	@make -C LuaAide clean

alltag.so: b/main.o LuaAide/libLuaAide.a
	@make -C LuaAide
	@echo "\nmake alltag.so: $@"
	@g++ -shared -fpic -o $@ $^

b/%.o: src/%.cpp $(XHEADER)
	@g++ -c -fpic -o $@ $< $(CPPFLAGS) $(CXXFLAGS)

staticlib:
	@make -C LuaAide

test:
	@echo "\nAlltagstest"
	@lua src/Alltagstest.lua
