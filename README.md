# bpf-core-example

Here is the BPF example for embedded system.

```shell
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

### buildroot

### linux

``
## References

* <https://www.sartura.hr/blog/simple-ebpf-core-application/>
  * repo: <https://github.com/sartura/ebpf-hello-world>
* [BPF Documentation - kernel.org](https://www.kernel.org/doc/html/latest/bpf/)
* [BPF CO-RE Reference Guide - nakryiko.com](https://nakryiko.com/posts/bpf-core-reference-guide/)
* [How to cross compile with LLVM based tools](https://archive.fosdem.org/2018/schedule/event/crosscompile/attachments/slides/2107/export/events/attachments/crosscompile/slides/2107/How_to_cross_compile_with_LLVM_based_tools.pdf)
