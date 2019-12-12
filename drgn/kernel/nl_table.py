#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import container_of
from drgn import Object
import time
import socket
import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
import lib

nl_table = prog['nl_table']
MAX_LINKS = 32

NETLINK_GENERIC = 16

# for i in range(MAX_LINKS):
# print(nl_table[NETLINK_GENERIC])

hash = nl_table[NETLINK_GENERIC].hash

# listeners = nl_table[NETLINK_GENERIC].listeners
# print(listeners)

def print_sock(nsock):
    print("\tportid    : %x" % nsock.portid)
#     print("\tdst_portid: %x" % nsock.dst_portid)  # all 0
    sock = nsock.sk
    print("\tsock %lx" % sock.address_of_().value_())
    head = sock.sk_wq.wait.head
#     print(head)
    for entry in list_for_each_entry('struct wait_queue_entry', head.address_of_(), 'entry'):
        print("\twait_queue_entry %lx" % entry.value_())
        eppoll_entry = container_of(entry, "struct eppoll_entry", 'wait')
        print(eppoll_entry)
        func = entry.func
        print("\t%s" % lib.address_to_name(hex(func)))
    print("\tsk_data_ready: %s" % lib.address_to_name(hex(sock.sk_data_ready)))
    print("")

for i, nsock in enumerate(lib.hash(hash, 'struct netlink_sock', 'node')):
    print("netlink_sock %lx" % nsock.value_())
    print_sock(nsock)
