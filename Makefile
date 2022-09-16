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

CH_TARGET = $(DSTDIR)/chvt
CH_SOURCES = $(SRCDIR)/chvt.c
CH_CFLAGS = $(C_CFLAGS)
CH_LDFLAGS= $(C_LDFLAGS)

PTS_TARGET = $(DSTDIR)/pts
PTS_SOURCES = $(SRCDIR)/pts.c
PTS_CFLAGS = $(C_CFLAGS)
PTS_LDFLAGS= $(C_LDFLAGS)

PTM_TARGET = $(DSTDIR)/ptm
PTM_SOURCES = $(SRCDIR)/ptm.c
PTM_CFLAGS = $(C_CFLAGS)
PTM_LDFLAGS= $(C_LDFLAGS)

N_TARGET = $(DSTDIR)/nif.so
N_SOURCES = $(SRCDIR)/nif.c
N_CFLAGS = $(C_CFLAGS) -I$(ERTS_INCLUDE_DIR) 
N_LDFLAGS= $(C_LDFLAGS) -shared

ifeq ($(MIX_TARGET),host)
ifeq ($(UNAME),Darwin)
PTS_CFLAGS += -D_DARWIN_C_SOURCE
PTM_CFLAGS += -D_DARWIN_C_SOURCE
CH_CFLAGS += -D_DARWIN_C_SOURCE
N_CFLAGS += -D_DARWIN_C_SOURCE
N_LDFLAGS = -undefined dynamic_lookup -dynamiclib
endif
endif

.PHONY: all clean

all: $(CH_TARGET) $(PTS_TARGET) $(PTM_TARGET) $(N_TARGET)

$(PTS_TARGET): $(PTS_SOURCES) 
	[ -d $(DSTDIR) ] || mkdir -p $(DSTDIR)
	$(CC) $(PTS_CFLAGS) $(PTS_SOURCES) -o $@ $(PTS_LDFLAGS)
	rm -fR $(DSTDIR)/*.dSYM

$(PTM_TARGET): $(PTM_SOURCES) 
	[ -d $(DSTDIR) ] || mkdir -p $(DSTDIR)
	$(CC) $(PTM_CFLAGS) $(PTM_SOURCES) -o $@ $(PTM_LDFLAGS)
	rm -fR $(DSTDIR)/*.dSYM

$(CH_TARGET): $(CH_SOURCES) 
	[ -d $(DSTDIR) ] || mkdir -p $(DSTDIR)
	$(CC) $(CH_CFLAGS) $(CH_SOURCES) -o $@ $(CH_LDFLAGS)
	rm -fR $(DSTDIR)/*.dSYM
	
$(N_TARGET): $(N_SOURCES)
	[ -d $(DSTDIR) ] || mkdir -p $(DSTDIR)
	$(CC) $(N_CFLAGS) $(N_SOURCES) -o $@ $(N_LDFLAGS)
	rm -fR $(DSTDIR)/*.dSYM

# macos generates folders priv/TARGET.dSYM
clean:
	rm -fR $(DSTDIR)/*
