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

cmap = prog['dpif_gid_map']
# print(cmap)
ids = print_cmap(cmap, "dpif_gid_node", "id_node")

# for i, id in enumerate(ids):
#     print(id)

for i, id in enumerate(ids):
    print("%x" % id)
    print("id: %d, ofp_in_port: %d, output: %10d, %10x, pid: %x, %d, rate: %x, refcount: %d, address: %x" % \
         (id.id, id.action.cookie.ofp_in_port, id.action.cookie.sflow.output, id.action.cookie.sflow.output, \
          id.action.dpif_gid_pid, id.action.dpif_gid_pid, id.action.dpif_gid_rate, id.refcount.count, id))

# It doesn't include the nodes whose refcount is 0
def print_metadata_map():
    cmap = prog['dpif_gid_metadata_map']
    ids = print_cmap(cmap, "group_id_node", "metadata_node")

    for i, id in enumerate(ids):
        print("%x" % id)
        print("id: %d, inport: %d, output: %10x, refcount: %d" % \
            (id.id, id.cookie.ofp_in_port, id.cookie.sflow.output, id.refcount.count))

print("\n=== group_expiring ===\n")

expiring = prog['dpif_gid_expiring']
# print(expiring)

next = expiring.next
while 1:
    if next.value_() == expiring.address_of_().value_():
        break
    id = container_of(next, "struct dpif_gid_node", "exp_node")
    next = id.exp_node.next
    print("id: %2x" % id.id, end='\t')
    print("next %lx" % next.value_())
#     time.sleep(1)

# counter = prog['counter']
# print("counter[0] %x" % counter[0])
# print("counter[1] %x" % counter[1])
