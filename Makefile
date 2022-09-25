# https://hexdocs.pm/nerves/environment-variables.html
# run with:
#  mix compile
#  mix clean

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
NIF_LDFLAGS= $(C_LDFLAGS) -shared

ifeq ($(MIX_TARGET),host)
ifeq ($(UNAME),Darwin)
VT_CFLAGS += -D_DARWIN_C_SOURCE
PTS_CFLAGS += -D_DARWIN_C_SOURCE
PTM_CFLAGS += -D_DARWIN_C_SOURCE
NIF_CFLAGS += -D_DARWIN_C_SOURCE
NIF_LDFLAGS = -undefined dynamic_lookup -dynamiclib
endif
endif

.PHONY: all clean

all: $(VT_TARGET) $(PTS_TARGET) $(PTM_TARGET) $(NIF_TARGET)

$(VT_TARGET): $(VT_SOURCES) 
	[ -d $(DSTDIR) ] || mkdir -p $(DSTDIR)
	$(CC) $(VT_CFLAGS) $(VT_SOURCES) -o $@ $(VT_LDFLAGS)
	rm -fR $(DSTDIR)/*.dSYM

$(PTS_TARGET): $(PTS_SOURCES) 
	[ -d $(DSTDIR) ] || mkdir -p $(DSTDIR)
	$(CC) $(PTS_CFLAGS) $(PTS_SOURCES) -o $@ $(PTS_LDFLAGS)
	rm -fR $(DSTDIR)/*.dSYM

$(PTM_TARGET): $(PTM_SOURCES) 
	[ -d $(DSTDIR) ] || mkdir -p $(DSTDIR)
	$(CC) $(PTM_CFLAGS) $(PTM_SOURCES) -o $@ $(PTM_LDFLAGS)
	rm -fR $(DSTDIR)/*.dSYM
	
$(NIF_TARGET): $(NIF_SOURCES)
	[ -d $(DSTDIR) ] || mkdir -p $(DSTDIR)
	$(CC) $(NIF_CFLAGS) $(NIF_SOURCES) -o $@ $(NIF_LDFLAGS)
	rm -fR $(DSTDIR)/*.dSYM

# macos generates folders priv/TARGET.dSYM
clean:
	rm -fR $(DSTDIR)/*
