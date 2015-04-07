all: dirs build/gtk2/immodules/im-bogo.so build/gtk3/immodules/im-bogo.so server

dirs:
	mkdir -p build/gtk2/immodules
	mkdir -p build/gtk3/immodules

build/gtk3/immodules/im-bogo.so: main.vala module.vala
	valac -o $@ $^ --library=$* --pkg=gtk+-3.0 -X -fPIC -X -shared

build/gtk2/immodules/im-bogo.so: main.vala module.vala
	valac -o $@ $^ --library=$* --pkg=gtk+-2.0 -X -fPIC -X -shared

build/gtk2/immodules.cache: build/gtk2/immodules/im-bogo.so
	GTK_PATH=${PWD}/build/gtk2 gtk-query-immodules-2.0 > $@

build/gtk3/immodules.cache: build/gtk3/immodules/im-bogo.so
	GTK_PATH=${PWD}/build/gtk3 gtk-query-immodules-3.0 > $@

build/server: server.vala
	valac -o $@ $^ --pkg=gdk-3.0 --pkg=python3 --vapidir=. 

run: build/gtk3/immodules.cache build/gtk2/immodules.cache build/server
	build/server & GTK_IM_MODULE_FILE=build/gtk$(GTK)/immodules.cache GTK_IM_MODULE=bogo $(CMD) ; kill $$! 

clean:
	rm -rf build

.PHONY: all dirs clean run
