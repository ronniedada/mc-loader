MCD_LIBRARY_PATH := /root/mc-loader/lib
MCD_HEADERS_PATH := $(shell realpath $(MCD_LIBRARY_PATH)/../include)

EXTRA_CFLAGS := -Wall -pedantic -std=gnu99

ifdef MCD_VERBOSE
EXTRA_CPPFLAGS += -D VERBOSE
endif

ifdef MCD_DEBUG
EXTRA_CFLAGS += -O0 -fno-inline -gfull
endif

CPPFLAGS += $(EXTRA_CPPFLAGS)
CFLAGS += -I$(MCD_HEADERS_PATH) $(EXTRA_CFLAGS)
LDFLAGS += -Wl,-rpath,$(MCD_LIBRARY_PATH) -L$(MCD_LIBRARY_PATH) -lmemcached -lsasl2

mc-loader: main.o
	gcc -o $@ $^ $(LDFLAGS)

verbose:
	$(MAKE) MCD_VERBOSE=1 mc-loader

debug:
	$(MAKE) MCD_DEBUG=1 mc-loader

clean:
	rm -f mc-loader
	rm -rf main.o
	rm -rf mc-loader.dSYM

.PHONY: verbose debug clean
