all: dirs immodules/im-bogo.so server

dirs:
	mkdir -p immodules

immodules/im-bogo.so: main.vala module.vala
	valac -o $@ $^ --library=$* --header=$*.h --pkg=gtk+-2.0 -X -fPIC -X -shared

server: server.vala
	valac -o $@ $^ --pkg=gdk-2.0 --pkg=python3 --vapidir=. --save-temps

clean:
	rm -rf server
	rm -rf immodules/im-bogo.so
	rm -rf im-bogo.h
	rm -rf im-bogo.vapi

.PHONY: all dirs clean
