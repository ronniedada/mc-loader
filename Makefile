MCD_LIBRARY_PATH := /usr/local/lib
MCD_HEADERS_PATH := $(MCD_LIBRARY_PATH)/../include

EXTRA_CFLAGS := -Wall -pedantic -std=gnu99

ifdef MCD_VERBOSE
EXTRA_CPPFLAGS += -DVERBOSE
endif

ifdef MCD_DEBUG
EXTRA_CFLAGS += -O0 -fno-inline -gdwarf-2 -ggdb3
endif

CPPFLAGS += $(EXTRA_CPPFLAGS)
CFLAGS += -I$(MCD_HEADERS_PATH) $(EXTRA_CFLAGS)
LDFLAGS += -Wl,-rpath,$(MCD_LIBRARY_PATH) -L$(MCD_LIBRARY_PATH) -lmemcached -lsasl2

mc-loader: main.o
	gcc -o $@ $^ $(LDFLAGS)

main.o: main.c
	gcc -c $@ $^ $(CFLAGS)

verbose:
	$(MAKE) MCD_VERBOSE=1 mc-loader

debug:
	$(MAKE) MCD_DEBUG=1 mc-loader

clean:
	rm -f mc-loader
	rm -rf main.o
	rm -rf mc-loader.dSYM

.PHONY: verbose debug clean
