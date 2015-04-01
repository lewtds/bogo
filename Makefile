all: build 

NAME=im-bogo
OUTPUT=${NAME}.so
VALA_SRC=main.vala module.vala
VALA_FLAGS=--pkg=gtk+-3.0


build: ${VALA_SRC}
	valac ${VALA_FLAGS} -C --library=${NAME} --header=${NAME}.h ${VALA_SRC}
	gcc main.c module.c `pkg-config --libs --cflags gtk+-2.0` -fPIC -shared -o ${OUTPUT}
	mkdir -p immodules
	mv ${OUTPUT} immodules

clean:
	rm -rf immodules/${OUTPUT}
	rm -rf ${NAME}.vapi
	rm -rf ${NAME}.h

.PHONY: all build clean
