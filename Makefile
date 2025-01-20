
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
	@g++ -shared -fpic -o $@ $^
b/%.o: src/%.cpp $(XHEADER)
	@g++ -c -Wall -Werror -fpic -o $@ $< $(CPPFLAGS) $(CXXFLAGS)

LuaAide/libLuaAide.a:
	@make -C LuaAide
