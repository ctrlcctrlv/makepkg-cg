#!/usr/bin/gmake
SHELL:=/bin/bash
CC:=clang
CXX:=clang++
BPFTOOL:=bpftool
LD:=$(shell which ld.lld)
CFLAGS:=-g

.PHONY: all
all: makepkg-cg-prio.bpf.o makepkg-cg-prio.skel.h makepkg-cg-prio.o
ifneq ($(DEBUG),)
	$(MAKE) -s showfiletypes

.PHONY: showfiletypes
showfiletypes:
	file *
endif

%.bpf.o: %.c
	$(Q)$(CC) $(CFLAGS) -target bpf -O2 -c $< -o $@

# Generate BPF skeletons
%.skel.h: %.bpf.o
	$(Q)$(BPFTOOL) gen skeleton $< > $@

%.o: %.c $(wildcard %.h)
	$(Q)$(CC) $(CFLAGS) -c $^ -o $@
