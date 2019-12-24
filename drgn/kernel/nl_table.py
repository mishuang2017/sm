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
    if 1:
        return
    for entry in list_for_each_entry('struct wait_queue_entry', head.address_of_(), 'entry'):
        print("\twait_queue_entry %lx" % entry.value_())
        print("\twait_queue_entry.flags %d" % entry.flags.value_())
        eppoll_entry = container_of(entry, "struct eppoll_entry", 'wait')
        print("\teppoll_entry %lx" % eppoll_entry)
        epitem = eppoll_entry.base
        print("\tepitem %lx" % epitem)
        event = epitem.event
        ffd = epitem.ffd
        print("\tepoll_filefd %lx" % ffd.address_of_().value_())
        if entry.flags.value_():
            print("\tfd: %d" %ffd.fd.value_())
            print("\tfile: %lx" %ffd.file)

            # 10000019
            # EPOLLIN | EPOLLERR | EPOLLHUP | EPOLLWAKEUP
            print("\tevents: %x" % event.events)
            print("\tdata: %x" % event.data)
        func = entry.func
        print("\t%s" % lib.address_to_name(hex(func)))
        print("")
    print("\tsk_data_ready: %s" % lib.address_to_name(hex(sock.sk_data_ready)))
    print("")

for i, nsock in enumerate(lib.hash(hash, 'struct netlink_sock', 'node')):
    print("netlink_sock %lx" % nsock.value_())
    print_sock(nsock)
