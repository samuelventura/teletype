# https://hexdocs.pm/nerves/environment-variables.html
# run with:
#  mix compile
#  mix clean

# https://www.erlang.org/doc/tutorial/nif.html
# compile flags at the end

SRCDIR = src
DSTDIR = priv
UNAME := $(shell uname -s)
MIX_TARGET ?= host

C_CFLAGS = -g -O3 -Werror -pedantic -Wall -Wextra -D_XOPEN_SOURCE=700
C_LDFLAGS = -fPIC

VT_TARGET = $(DSTDIR)/vt
VT_SOURCES = $(SRCDIR)/vt.c
VT_CFLAGS = $(C_CFLAGS)
VT_LDFLAGS= $(C_LDFLAGS)

PTS_TARGET = $(DSTDIR)/pts
PTS_SOURCES = $(SRCDIR)/pts.c
PTS_CFLAGS = $(C_CFLAGS)
PTS_LDFLAGS= $(C_LDFLAGS)

PTM_TARGET = $(DSTDIR)/ptm
PTM_SOURCES = $(SRCDIR)/ptm.c
PTM_CFLAGS = $(C_CFLAGS)
PTM_LDFLAGS= $(C_LDFLAGS)

NIF_TARGET = $(DSTDIR)/nif.so
NIF_SOURCES = $(SRCDIR)/nif.c
NIF_CFLAGS = $(C_CFLAGS) -I$(ERTS_INCLUDE_DIR) 
NIF_LDFLAGS = $(C_LDFLAGS) -shared

ifeq ($(MIX_TARGET),host)
ifeq ($(UNAME),Darwin)
PTM_CFLAGS += -D_DARWIN_C_SOURCE
NIF_CFLAGS += -D_DARWIN_C_SOURCE
NIF_LDFLAGS = -undefined dynamic_lookup -dynamiclib
endif
endif

# fixme: unable to compile NIF on macos with zig
# error(link): undefined reference to symbol '_enif_set_pid_undefined'
ifeq ($(UNAME),Linux)
CC =zig cc
endif

ifeq ($(MIX_TARGET),rpi4)
#CC =zig cc -target aarch64-linux
#https://github.com/nerves-project/toolchains/releases
CC = $(HOME)/.nerves/artifacts/nerves_toolchain_aarch64_nerves_linux_gnu-linux_x86_64-1.6.0/bin/aarch64-nerves-linux-gnu-cc
endif

.PHONY: all clean post

all: $(VT_TARGET) $(PTS_TARGET) $(PTM_TARGET) $(NIF_TARGET) post

$(VT_TARGET): $(VT_SOURCES) 
	[ -d $(DSTDIR) ] || mkdir -p $(DSTDIR)
	$(CC) $(VT_CFLAGS) $(VT_SOURCES) -o $@ $(VT_LDFLAGS)

$(PTS_TARGET): $(PTS_SOURCES) 
	[ -d $(DSTDIR) ] || mkdir -p $(DSTDIR)
	$(CC) $(PTS_CFLAGS) $(PTS_SOURCES) -o $@ $(PTS_LDFLAGS)

$(PTM_TARGET): $(PTM_SOURCES) 
	[ -d $(DSTDIR) ] || mkdir -p $(DSTDIR)
	$(CC) $(PTM_CFLAGS) $(PTM_SOURCES) -o $@ $(PTM_LDFLAGS)
	
$(NIF_TARGET): $(NIF_SOURCES)
	[ -d $(DSTDIR) ] || mkdir -p $(DSTDIR)
	$(CC) $(NIF_CFLAGS) $(NIF_SOURCES) -o $@ $(NIF_LDFLAGS)

# macos generates folders priv/TARGET.dSYM
post:
	rm -fR $(DSTDIR)/*.dSYM
	env | sort > Makefile.$(MIX_TARGET).env

clean:
	rm -fR $(DSTDIR)/*
