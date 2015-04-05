all: build 

NAME=im-bogo
OUTPUT=${NAME}.so
VALA_SRC=main.vala module.vala
VALA_FLAGS=--vapidir=. --pkg=gtk+-2.0 --pkg=python


build: ${VALA_SRC}
	valac ${VALA_FLAGS} -C --library=${NAME} --header=${NAME}.h ${VALA_SRC}
	gcc main.c module.c --std=c99 `pkg-config --libs --cflags gtk+-2.0 python2` -fPIC -shared -o ${OUTPUT}
	mkdir -p immodules
	mv ${OUTPUT} immodules

clean:
	rm -rf immodules/${OUTPUT}
	rm -rf ${NAME}.vapi
	rm -rf ${NAME}.h

.PHONY: all build clean
