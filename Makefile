CLANG ?= clang
LINUX ?= ../../linux
CROSS_COMPILE ?= aarch64-buildroot-linux-gnu-
SYSROOT=$(shell $(CROSS_COMPILE)gcc -print-sysroot)
TOOLCHAIN=$(shell dirname $(shell which $(CROSS_COMPILE)gcc))/..

all: build
.PHONY: all

build:
	mkdir -p $@
	$(LINUX)/tools/bpf/bpftool/bpftool btf dump file $(LINUX)/vmlinux format c > vmlinux.h
	$(CLANG) -g -O2 -Wall --target=bpf -I $@ -c tracepoint.bpf.c -o $@/tracepoint.bpf.o --sysroot=$(SYSROOT)
	$(LINUX)/tools/bpf/bpftool/bpftool gen skeleton $@/tracepoint.bpf.o > $@/tracepoint.skel.h
	$(CLANG) -g -O2 -Wall -I $@ -c tracepoint.c -o build/tracepoint.o --target=aarch64-buildroot-linux-gnu --sysroot=$(SYSROOT) --gcc-toolchain=$(TOOLCHAIN)
	$(CLANG) -fuse-ld=lld -g -O2 -Wall $@/tracepoint.o -L$@ -lbpf -lelf -lz -o $@/tracepoint --target=aarch64-buildroot-linux-gnu --sysroot=$(SYSROOT) --gcc-toolchain=$(TOOLCHAIN)

.PHONY: build

clean:
	rm -rf build

.PHONY: clean
