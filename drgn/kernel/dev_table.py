#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import subprocess
import time
import sys
import os

(status, output) = subprocess.getstatusoutput("grep -w dev_table /proc/kallsyms | grep openvswitch | awk '{print $1}'")
print("%d, %s" % (status, output))

if status:
    sys.exit(1)

t = int(output, 16)
p = Object(prog, 'struct hlist_head *', address=t)

for i in range(1024):
    for vport in hlist_for_each_entry('struct vport', p, 'hash_node'):
        name = vport.dev.name.string_().decode()
        upcall_portids = vport.upcall_portids
        ids = upcall_portids.ids
        id = ids[0]
        print("name: %10s,  n_ids: %d, id: %x" % (name, upcall_portids.n_ids, id))
        print("vport %lx" % vport)
        print("vport_portids %lx" % upcall_portids)
        print("")
    p = p + 1
