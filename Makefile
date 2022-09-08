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

ifeq ($(MIX_TARGET),host)
ifeq ($(UNAME),Darwin)
SLV_CFLAGS += -D_DARWIN_C_SOURCE
MTR_CFLAGS += -D_DARWIN_C_SOURCE
CH_CFLAGS += -D_DARWIN_C_SOURCE
endif
endif

.PHONY: all clean

all: $(CH_TARGET) $(SLV_TARGET) $(MTR_TARGET)

$(SLV_TARGET): $(SLV_SOURCES) 
	[ -d $(DSTDIR) ] || mkdir -p $(DSTDIR)
	$(CC) $(SLV_CFLAGS) $(SLV_SOURCES) -o $@ $(SLV_LDFLAGS)

$(MTR_TARGET): $(MTR_SOURCES) 
	[ -d $(DSTDIR) ] || mkdir -p $(DSTDIR)
	$(CC) $(MTR_CFLAGS) $(MTR_SOURCES) -o $@ $(MTR_LDFLAGS)

$(CH_TARGET): $(CH_SOURCES) 
	[ -d $(DSTDIR) ] || mkdir -p $(DSTDIR)
	$(CC) $(CH_CFLAGS) $(CH_SOURCES) -o $@ $(CH_LDFLAGS)
	
clean:
	rm -fR $(DSTDIR)/*
