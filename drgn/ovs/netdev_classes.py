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

netdev_classes = prog['netdev_classes']
print(netdev_classes.impl.p)

cmap_impl = netdev_classes.impl.p
mask = cmap_impl.mask.value_()
print("mask: %d" % mask)

buckets = cmap_impl.buckets

CMAP_K = 5

n = 0
for i in range(mask + 1):
    for j in range(CMAP_K):
        cmap_node = buckets[i].nodes[j].next.p[0]
        if cmap_node.address_of_().value_() == 0:
            continue
#         print(cmap_node)
        data = container_of(cmap_node.address_of_(), "struct netdev_registered_class", "cmap_node")
#         print(data.member_("class").type)
        new_class = data.member_("class")
        print(new_class.type)
        print(new_class.run)
        print('')
        n += 1

print("n = %d" % n)

# for i in ('netdev_linux_class', 'netdev_internal_class'):
#     new_class = prog[i]
#     print("%10s, netdev_class: %lx" % (new_class.type, new_class.address_of_().value_()))
