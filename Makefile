# dmenu - dynamic menu
# See LICENSE file for copyright and license details.

CONFIGMK = nonexistant.mk

ifeq ($(OS),Windows_NT)
    #CCFLAGS += -D WIN32
    ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
        #CCFLAGS += -D AMD64
    endif
    ifeq ($(PROCESSOR_ARCHITECTURE),x86)
        #CCFLAGS += -D IA32
    endif
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        #CCFLAGS += -D LINUX
    endif
    ifeq ($(UNAME_S),FreeBSD)
        MAKE = gmake
        CONFIGMK = config.mk.freebsd
    endif
    ifeq ($(UNAME_S),Darwin)
        CONFIGMK = config.mk.darwin
    endif
    UNAME_P := $(shell uname -p)
    ifeq ($(UNAME_P),x86_64)
        #CCFLAGS += -D AMD64
    endif
    ifneq ($(filter %86,$(UNAME_P)),)
        #CCFLAGS += -D IA32
    endif
    ifneq ($(filter arm%,$(UNAME_P)),)
        #CCFLAGS += -D ARM
    endif
endif

include ${CONFIGMK}

SRC = dmenu.c draw.c stest.c
OBJ = ${SRC:.c=.o}

all: options dmenu stest

options:
	@echo dmenu build options:
	@echo "CFLAGS   = ${CFLAGS}"
	@echo "LDFLAGS  = ${LDFLAGS}"
	@echo "CC       = ${CC}"

.c.o:
	@echo CC -c $<
	@${CC} -c ${CFLAGS} $<

config.h:
	@echo creating $@ from config.def.h
	@cp config.def.h $@

${OBJ}: config.h ${CONFIGMK} draw.h

dmenu: dmenu.o draw.o
	@echo CC -o $@
	@${CC} -o $@ dmenu.o draw.o ${LDFLAGS}

stest: stest.o
	@echo CC -o $@
	@${CC} -o $@ stest.o ${LDFLAGS}

clean:
	@echo cleaning
	@rm -f dmenu stest ${OBJ} dmenu-${VERSION}.tar.gz

dist: clean
	@echo creating dist tarball
	@mkdir -p dmenu-${VERSION}
	@cp LICENSE Makefile README ${CONFIGMK} dmenu.1 draw.h dmenu_path dmenu_run stest.1 ${SRC} dmenu-${VERSION}
	@tar -cf dmenu-${VERSION}.tar dmenu-${VERSION}
	@gzip dmenu-${VERSION}.tar
	@rm -rf dmenu-${VERSION}

install: all
	@echo installing executables to ${DESTDIR}${PREFIX}/bin
	@install -d -m 0755 ${DESTDIR}${PREFIX}/bin
	@install -m 0755 dmenu      ${DESTDIR}${PREFIX}/bin/
	@install -m 0755 dmenu_path ${DESTDIR}${PREFIX}/bin/
	@install -m 0755 dmenu_run  ${DESTDIR}${PREFIX}/bin/
	@install -m 0755 stest      ${DESTDIR}${PREFIX}/bin/
	@echo installing manual pages to ${DESTDIR}${MANPREFIX}/man1
	@install -d -m 0755 ${DESTDIR}${MANPREFIX}
	@install -d -m 0755 ${DESTDIR}${MANPREFIX}/man1
	@sed "s/VERSION/${VERSION}/g" < dmenu.1 > dmenu.1.s
	@sed "s/VERSION/${VERSION}/g" < stest.1 > stest.1.s
	@install -m 0644 dmenu.1.s ${DESTDIR}${MANPREFIX}/man1/dmenu.1
	@install -m 0644 stest.1.s ${DESTDIR}${MANPREFIX}/man1/stest.1
	@rm -f dmenu.1.s
	@rm -f stest.1.s

uninstall:
	@echo removing executables from ${DESTDIR}${PREFIX}/bin
	@rm -f ${DESTDIR}${PREFIX}/bin/dmenu
	@rm -f ${DESTDIR}${PREFIX}/bin/dmenu_path
	@rm -f ${DESTDIR}${PREFIX}/bin/dmenu_run
	@rm -f ${DESTDIR}${PREFIX}/bin/stest
	@echo removing manual page from ${DESTDIR}${MANPREFIX}/man1
	@rm -f ${DESTDIR}${MANPREFIX}/man1/dmenu.1
	@rm -f ${DESTDIR}${MANPREFIX}/man1/stest.1

.PHONY: all options clean dist install uninstall
