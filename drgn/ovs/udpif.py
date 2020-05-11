#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
from drgn import container_of
import socket

import subprocess
import drgn
import sys
import time

sys.path.append(".")
from lib_ovs import *

backer = get_backer()
udpif = backer.udpif

def print_handlers():
    n1 = udpif.n_handlers
    n2 = udpif.n_revalidators

    rev = udpif.revalidators

    for i in range(n1):
    #     print("udpif.handler_id: %d" % udpif.handlers[i].handler_id)
        print(udpif.handlers[i])

    for i in range(n2):
        print(rev[i])

# dump = udpif.dump
# print(dump)
# dpif_netlink_flow_dump = Object(prog, 'struct dpif_netlink_flow_dump', address=dump.value_())
# print(dpif_netlink_flow_dump)


# ukeys = udpif.ukeys
# for i in range(512):
#     print("%d: %d" % (i, ukeys[i].cmap.impl.p.n.value_()))

n_revalidators = prog['n_revalidators']
print("n_revalidators: %d" %n_revalidators)
n_handlers = prog['n_handlers']
print("n_handlers: %d" % n_handlers)

# print_handlers()

ukeys = udpif.ukeys
print(ukeys)

N_UMAPS = 512

for i in range(N_UMAPS):
    cmap = ukeys[i].cmap
    if cmap.impl.p.value_() != prog['empty_cmap'].address_of_().value_():
        print(i)
        print(cmap)
        keys = print_cmap(cmap, "udpif_key", "cmap_node")
        for j, key in enumerate(keys):
            print(key)

# print(prog['empty_cmap'].address_of_())
