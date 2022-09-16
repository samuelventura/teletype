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

SLV_TARGET = $(DSTDIR)/slave
SLV_SOURCES = $(SRCDIR)/slave.c
SLV_CFLAGS = $(C_CFLAGS)
SLV_LDFLAGS= $(C_LDFLAGS)

MTR_TARGET = $(DSTDIR)/master
MTR_SOURCES = $(SRCDIR)/master.c
MTR_CFLAGS = $(C_CFLAGS)
MTR_LDFLAGS= $(C_LDFLAGS)

N_TARGET = $(DSTDIR)/nif.so
N_SOURCES = $(SRCDIR)/nif.c
N_CFLAGS = $(C_CFLAGS) -I$(ERTS_INCLUDE_DIR) 
N_LDFLAGS= $(C_LDFLAGS) -shared

ifeq ($(MIX_TARGET),host)
ifeq ($(UNAME),Darwin)
SLV_CFLAGS += -D_DARWIN_C_SOURCE
MTR_CFLAGS += -D_DARWIN_C_SOURCE
CH_CFLAGS += -D_DARWIN_C_SOURCE
N_CFLAGS += -D_DARWIN_C_SOURCE
N_LDFLAGS = -undefined dynamic_lookup -dynamiclib
endif
endif

.PHONY: all clean

all: $(CH_TARGET) $(SLV_TARGET) $(MTR_TARGET) $(N_TARGET)

$(SLV_TARGET): $(SLV_SOURCES) 
	[ -d $(DSTDIR) ] || mkdir -p $(DSTDIR)
	$(CC) $(SLV_CFLAGS) $(SLV_SOURCES) -o $@ $(SLV_LDFLAGS)
	rm -fR $(DSTDIR)/*.dSYM

$(MTR_TARGET): $(MTR_SOURCES) 
	[ -d $(DSTDIR) ] || mkdir -p $(DSTDIR)
	$(CC) $(MTR_CFLAGS) $(MTR_SOURCES) -o $@ $(MTR_LDFLAGS)
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
