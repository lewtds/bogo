.PHONY: all
all: dirs build

GTK_CLIENTS=build/gtk2/immodules/im-bogo.so build/gtk3/immodules/im-bogo.so

.PHONY: build
build: $(GTK_CLIENTS) build/server
	ln -sf $(PWD)/bogo-python build/bogo-python

$(GTK_CLIENTS): build/gtk%/immodules/im-bogo.so : main.vala module.vala
	valac -o $@ $^ --vapi=build/im-bogo.vapi --library=im-bogo --pkg=gtk+-$*.0 -X -fPIC -X -shared
	sed -e "s;%PWD%;$(PWD);g" -e "s;%GTK_VERSION%;$*;g" immodules.cache.in > build/gtk$*/immodules.cache

build/server: server.vala
	valac -o $@ $^ --pkg=gdk-3.0 --pkg=python3 --vapidir=.

.PHONY: test
test: main.vala tests/test.vala
	valac $^ --pkg=gtk+-3.0 -o build/test
	build/test
	python2 tests/gui.py

.PHONY: run
run: build
	GTK_IM_MODULE_FILE=build/gtk$(GTK)/immodules.cache GTK_IM_MODULE=bogo $(CMD)

.PHONY: clean
clean:
	rm -rf build dist

.PHONY: dirs
dirs:
	mkdir -p build/gtk2/immodules
	mkdir -p build/gtk3/immodules

.PHONY: install
install: build
	install -D build/gtk2/immodules/im-bogo.so $(DESTDIR)/usr/lib64/gtk-2.0/immodules/im-bogo.so
	install -D build/gtk3/immodules/im-bogo.so $(DESTDIR)/usr/lib64/gtk-3.0/immodules/im-bogo.so
	install -D build/server $(DESTDIR)/usr/lib64/bogo/bogo-daemon
	mkdir -p $(DESTDIR)/usr/lib64/bogo/bogo-python
	cp -R bogo-python $(DESTDIR)/usr/lib64/bogo/bogo-python
	install -D org.bogo.service $(DESTDIR)/usr/share/dbus-1/services/org.bogo.service

.PHONY: uninstall
uninstall:
	rm -rf $(DESTDIR)/usr/lib4/bogo
	rm -rf $(DESTDIR)/usr/share/dbus-1/services/org.bogo.service
	rm -rf $(DESTDIR)/usr/lib64/gtk-2.0/immodules/im-bogo.so
	rm -rf $(DESTDIR)/usr/lib64/gtk-3.0/immodules/im-bogo.so

.PHONY: rpm
rpm:
	make install DESTDIR=dist
	fpm -f -s dir \
		-t rpm \
		-n bogo \
		--version 0.1 \
		--after-install scripts/after-install.sh \
		--after-remove scripts/after-remove.sh \
		--depends python3 \
		--depends gtk2 \
		-C dist usr/lib64/ usr/share
