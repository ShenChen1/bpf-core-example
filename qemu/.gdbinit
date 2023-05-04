echo + target remote localhost:25000\n
target remote localhost:25000

# If this fails, it's probably because your GDB doesn't support ELF.
# Look at the tools page at
# for instructions on building GDB with ELF support.
echo + symbol-file ./linux/vmlinux\n
symbol-file ./linux/vmlinux

set pagination off
