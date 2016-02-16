all: dirs build

GTK_CLIENTS=build/gtk2/immodules/im-bogo.so build/gtk3/immodules/im-bogo.so

build: $(GTK_CLIENTS) build/server
	ln -s $(PWD)/bogo-python build/bogo-python

$(GTK_CLIENTS): build/gtk%/immodules/im-bogo.so : main.vala module.vala
	valac -o $@ $^ --vapi=build/im-bogo.vapi --library=im-bogo --pkg=gtk+-$*.0 -X -fPIC -X -shared
	sed -e "s;%PWD%;$(PWD);g" -e "s;%GTK_VERSION%;$*;g" immodules.cache.in > build/gtk$*/immodules.cache

build/server: server.vala
	valac -o $@ $^ --pkg=gdk-3.0 --pkg=python3 --vapidir=.

test: main.vala tests/test.vala
	valac $^ --pkg=gtk+-3.0 -o build/test
	build/test
	python2 tests/gui.py

run: build
	GTK_IM_MODULE_FILE=build/gtk$(GTK)/immodules.cache GTK_IM_MODULE=bogo $(CMD)

clean:
	rm -rf build

dirs:
	mkdir -p build/gtk2/immodules
	mkdir -p build/gtk3/immodules

install: build/gtk2/immodules/im-bogo.so
	install -D build/gtk2/immodules/im-bogo.so /usr/lib64/gtk-2.0/2.10.0/immodules
	install -D build/server /usr/lib64/bogo/bogo-daemon
	mkdir -p /usr/lib64/bogo/bogo-python
	cp -R bogo-python /usr/lib64/bogo/bogo-python
	install -D org.bogo.service /usr/share/dbus-1/services/org.bogo.service
	gtk-query-immodules-2.0-64 --update-cache

.PHONY: all dirs clean run test
