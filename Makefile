all: test/graph.svg

test/graph.svg: test/graph.dot
	dot -Tsvg $< -o $@

test/graph.dot: test/test.lua
	lua $<
