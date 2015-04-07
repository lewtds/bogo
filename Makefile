all: dirs build

GTK_CLIENTS=build/gtk2/immodules/im-bogo.so build/gtk3/immodules/im-bogo.so

build: $(GTK_CLIENTS) build/server

$(GTK_CLIENTS): build/gtk%/immodules/im-bogo.so : main.vala module.vala
	valac -o $@ $^ --library=im-bogo --pkg=gtk+-$*.0 -X -fPIC -X -shared
	sed -e "s;%PWD%;$(PWD);g" -e "s;%GTK_VERSION%;$*;g" immodules.cache.in > build/gtk$*/immodules.cache

build/server: server.vala
	valac -o $@ $^ --pkg=gdk-3.0 --pkg=python3 --vapidir=.

run: build
	GTK_IM_MODULE_FILE=build/gtk$(GTK)/immodules.cache GTK_IM_MODULE=bogo $(CMD)

clean:
	rm -rf build

dirs:
	mkdir -p build/gtk2/immodules
	mkdir -p build/gtk3/immodules

.PHONY: all dirs clean run
