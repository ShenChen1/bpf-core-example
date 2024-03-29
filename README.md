# bpf-core-example

Here is the BPF example for embedded system.

```
# uname -a
Linux buildroot 5.10.0-rc7-dirty #5 SMP PREEMPT Tue Sep 20 09:17:44 UTC 2022 aarch64 GNU/Linux
#
# /tmp/tracepoint
BPF object opened
BPF object loaded
BPF programs attached
            sshd-225     [000] d..3 62295.608423: bpf_trace_printk: execve /usr/sbin/sshd
            sshd-228     [000] d..3 62297.422019: bpf_trace_printk: execve /bin/bash
            bash-229     [000] d..3 62297.491273: bpf_trace_printk: execve /bin/id
            sshd-231     [000] d..3 62510.890832: bpf_trace_printk: execve /usr/sbin/sshd
            sshd-234     [000] d..3 62512.915081: bpf_trace_printk: execve /bin/bash
            bash-235     [000] d..3 62512.982878: bpf_trace_printk: execve /bin/id
            bash-236     [000] d..3 62515.462086: bpf_trace_printk: execve /bin/ls
```

## HOWTO

### compile step by step

```
../../linux/tools/bpf/bpftool/bpftool btf dump file ../../linux/vmlinux format c > vmlinux.h
clang -g -O2 -Wall --target=bpf -I build -c tracepoint.bpf.c -o build/tracepoint.bpf.o --sysroot=/var/fpwork/shenchen/peteshen/buildroot/output/host/aarch64-buildroot-linux-gnu/sysroot
../../linux/tools/bpf/bpftool/bpftool gen skeleton build/tracepoint.bpf.o > build/tracepoint.skel.h
clang -g -O2 -Wall -I build -c tracepoint.c -o build/tracepoint.o --target=aarch64-buildroot-linux-gnu --sysroot=/var/fpwork/shenchen/peteshen/buildroot/output/host/aarch64-buildroot-linux-gnu/sysroot --gcc-toolchain=/var/fpwork/shenchen/peteshen/buildroot/output/host/bin/..
clang -fuse-ld=lld -g -O2 -Wall build/tracepoint.o -Lbuild -lbpf -lelf -lz -o build/tracepoint --target=aarch64-buildroot-linux-gnu --sysroot=/var/fpwork/shenchen/peteshen/buildroot/output/host/aarch64-buildroot-linux-gnu/sysroot --gcc-toolchain=/var/fpwork/shenchen/peteshen/buildroot/output/host/bin/..
```

### build all examples

```
peteshen@3724e7784743:/var/fpwork/shenchen/peteshen/ebpf/bpf-core-example$ make
  MKDIR    .output
  BPFTOOL  .output/vmlinux.h
  BPF      .output/minimal.bpf.o
  GEN-SKEL .output/minimal.skel.h
  CC       .output/minimal.o
  BINARY   minimal
  BPF      .output/minimal_legacy.bpf.o
  GEN-SKEL .output/minimal_legacy.skel.h
  CC       .output/minimal_legacy.o
  BINARY   minimal_legacy
  BPF      .output/bootstrap.bpf.o
  GEN-SKEL .output/bootstrap.skel.h
  CC       .output/bootstrap.o
  BINARY   bootstrap
  BPF      .output/uprobe.bpf.o
  GEN-SKEL .output/uprobe.skel.h
  CC       .output/uprobe.o
  BINARY   uprobe
  BPF      .output/kprobe.bpf.o
  GEN-SKEL .output/kprobe.skel.h
  CC       .output/kprobe.o
  BINARY   kprobe
  BPF      .output/fentry.bpf.o
  GEN-SKEL .output/fentry.skel.h
  CC       .output/fentry.o
  BINARY   fentry
  BPF      .output/usdt.bpf.o
  GEN-SKEL .output/usdt.skel.h
  CC       .output/usdt.o
  BINARY   usdt
  BPF      .output/sockfilter.bpf.o
  GEN-SKEL .output/sockfilter.skel.h
  CC       .output/sockfilter.o
  BINARY   sockfilter
  BPF      .output/tc.bpf.o
  GEN-SKEL .output/tc.skel.h
  CC       .output/tc.o
  BINARY   tc
  BPF      .output/tracepoint.bpf.o
  GEN-SKEL .output/tracepoint.skel.h
  CC       .output/tracepoint.o
  BINARY   tracepoint
```

### clang-15

You may face this issue which means clang is too old.

```
libbpf: failed to find BTF for extern '__builtin_preserve_enum_value': -2
Error: failed to open BPF object file: No such file or directory
make: *** [Makefile:61: .output/usdt.skel.h] Error 254
make: *** Deleting file '.output/usdt.skel.h'
```

See [compile error while running make in example/c](https://github.com/libbpf/libbpf-bootstrap/issues/95)

Update to clang-15:
```
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh 15
```

### buildroot

`buildroot` provides the toolchain `aarch64-buildroot-linux-gnu`, and there are some useful `aarch64` library like: `libz`, `libelf`, `libbpf` ...

You can use to build the environment by yourself.
* [buildroot config](./buildroot/.config)

### linux

`linux` provides the custom `aarch64` kernel and host-version `bpftool`.

```
make CROSS_COMPILE=aarch64-buildroot-linux-gnu- ARCH=arm64 defconfig
make CROSS_COMPILE=aarch64-buildroot-linux-gnu- ARCH=arm64 menuconfig
make CROSS_COMPILE=aarch64-buildroot-linux-gnu- ARCH=arm64
```

Some kernel options are necessary like `CONFIG_BPF`, `CONFIG_BPF_EVENTS`, `CONFIG_BPF_SYSCALL` ...
* [kernel config](./linux/.config)

### qemu

* [establish aarch64 machine](https://github.com/google/syzkaller/blob/master/docs/linux/setup_linux-host_qemu-vm_arm64-kernel.md)

```
qemu-system-aarch64 -machine virt -cpu cortex-a57 -nographic -smp 1 -m 2048 -kernel ./linux/arch/arm64/boot/Image -hda ./buildroot/output/images/rootfs.ext4 -append "root=/dev/vda" -net user,hostfwd=tcp::10023-:22 -net nic
```

You can use `SSH` to login
```
ssh -p 10023 root@localhost
```

### debug with vmlinux

```
qemu-system-aarch64 -machine virt -cpu cortex-a57 -nographic -smp 1 -m 2048 -kernel ./linux/arch/arm64/boot/Image -hda ./buildroot/output/images/rootfs.ext4 -append "root=/dev/vda" -net user,hostfwd=tcp::10023-:22 -net nic -gdb tcp::25000 -S

aarch64-buildroot-linux-gnu-gdb -x .gdbinit
```

## References

* <https://www.sartura.hr/blog/simple-ebpf-core-application/>
  * repo: <https://github.com/sartura/ebpf-hello-world>
* [BPF Documentation - kernel.org](https://www.kernel.org/doc/html/latest/bpf/)
* [BPF CO-RE Reference Guide - nakryiko.com](https://nakryiko.com/posts/bpf-core-reference-guide/)
* [How to cross compile with LLVM based tools](https://archive.fosdem.org/2018/schedule/event/crosscompile/attachments/slides/2107/export/events/attachments/crosscompile/slides/2107/How_to_cross_compile_with_LLVM_based_tools.pdf)
