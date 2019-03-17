#!/usr/bin/python

from __future__ import print_function
from bcc import BPF
from bcc.utils import printb
import commands
import sys

# load BPF program
b = BPF(text="""
TRACEPOINT_PROBE(net, net_dev_xmit) {
    // args is from /sys/kernel/debug/tracing/events/net/net_dev_xmit/format
    bpf_trace_printk("%d\\n", args->len);
    return 0;
}
""")

if len(sys.argv) == 2:
    cmd="pgrep " + sys.argv[1]
    (status, output) = commands.getstatusoutput(cmd)
    if status != 0:
        exit(sys.argv[1] + " not found")

# header
print("%-18s %-16s %-6s %s" % ("TIME(s)", "COMM", "PID", "LEN"))

# format output
while 1:
    try:
        (task, pid, cpu, flags, ts, msg) = b.trace_fields()
    except ValueError:
        continue
    except KeyboardInterrupt:
        exit()
    if len(sys.argv) == 2:
        if pid == int(output):
            printb(b"%-18.9f %-16s %-6d %s" % (ts, task, pid, msg))
    else:
        printb(b"%-18.9f %-16s %-6d %s" % (ts, task, pid, msg))
