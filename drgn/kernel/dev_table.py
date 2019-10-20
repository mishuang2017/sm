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
p = Object(prog, 'void *', address=t)

t = p.value_()

for i in range(1024):
    p = Object(prog, 'struct hlist_head', address=t)
    for vport in hlist_for_each_entry('struct vport', p, 'hash_node'):
        print("address: %lx" % t)
        name = vport.dev.name.string_().decode()
        print(name)
        print(vport)
        print("")
    t = t + prog.type('struct hlist_head').size
