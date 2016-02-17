.PHONY: all
all: dirs build

GTK_CLIENTS=build/gtk2/immodules/im-bogo.so build/gtk3/immodules/im-bogo.so

.PHONY: build
build: $(GTK_CLIENTS) build/server
	ln -sf $(PWD)/bogo-python build/bogo-python

$(GTK_CLIENTS): build/gtk%/immodules/im-bogo.so : src/main.vala src/module.vala
	valac -o $@ $^ --vapi=build/im-bogo.vapi --library=im-bogo --pkg=gtk+-$*.0 -X -fPIC -X -shared
	sed -e "s;%PWD%;$(PWD);g" -e "s;%GTK_VERSION%;$*;g" src/immodules.cache.in > build/gtk$*/immodules.cache

build/server: src/server.vala
	valac -o $@ $^ --pkg=gdk-3.0 --pkg=python3 --vapidir=src

.PHONY: test
test: src/main.vala tests/test.vala
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

# https://www.gnu.org/prep/standards/html_node/Directory-Variables.html
prefix ?= /usr
exec_prefix ?= $(prefix)
libdir ?= $(prefix)/lib64
libexecdir ?= $(exec_prefix)/libexec
datarootdir ?= $(prefix)/share
datadir ?= $(datarootdir)

.PHONY: install
install: build
	install -D build/gtk2/immodules/im-bogo.so $(DESTDIR)$(libdir)/gtk-2.0/immodules/im-bogo.so
	install -D build/gtk3/immodules/im-bogo.so $(DESTDIR)$(libdir)/gtk-3.0/immodules/im-bogo.so
	install -D build/server $(DESTDIR)$(libdir)/bogo/bogo-daemon
	mkdir -p $(DESTDIR)$(libdir)/bogo/bogo-python
	cp -R bogo-python $(DESTDIR)$(libdir)/bogo
	install -D src/org.bogo.service $(DESTDIR)$(datadir)/dbus-1/services/org.bogo.service

.PHONY: uninstall
uninstall:
	rm -rf $(DESTDIR)$(libdir)/bogo
	rm -rf $(DESTDIR)$(datadir)/dbus-1/services/org.bogo.service
	rm -rf $(DESTDIR)$(libdir)/gtk-2.0/immodules/im-bogo.so
	rm -rf $(DESTDIR)$(libdir)/gtk-3.0/immodules/im-bogo.so

VERSION=0.1
NAME=bogo

.PHONY: rpm
rpm:
	make install DESTDIR=dist
	fpm -f -s dir \
		-t rpm \
		-n $(NAME) \
		--version $(VERSION) \
		--iteration 1 \
		--after-install scripts/after-install.fedora.sh \
		--after-remove scripts/after-remove.fedora.sh \
		--depends python3 \
		--depends gtk2 \
		-C dist usr

.PHONY: deb
deb:
	make install DESTDIR=dist libdir=/usr/lib/x86_64-linux-gnu
	fpm -f -s dir \
		-t deb \
		-n $(NAME) \
		--version $(VERSION) \
		--iteration 1 \
		--after-install scripts/after-install.ubuntu.sh \
		--after-remove scripts/after-remove.ubuntu.sh \
		--depends python3 \
		--depends libgtk2.0-0 \
		--depends libgtk-3-0 \
		-C dist usr
