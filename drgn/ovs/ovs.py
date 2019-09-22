#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
from drgn import container_of
import socket

import subprocess
import drgn
import sys
import time

def ovs_pid():
    (status, output) = subprocess.getstatusoutput("pgrep ovs-vswitchd")

    if status:
        print("ovs is not started")
        sys.exit(1)

    return int(output)

prog = drgn.program_from_pid(ovs_pid())

def print_ufid_tc_data(data):
    if data.ifindex:
        print("chain: %3x, prio: %d, handle: %d, ifindex: %d" %
              (data.chain, data.prio, data.handle, data.ifindex));

def print_hmap(hmap, struct_name):

    ufid_tc = prog[hmap]
    print(ufid_tc)

    buckets = ufid_tc.buckets.value_()

    print("buckets: %x" % buckets)

    n = ufid_tc.n.value_()
    print("n: %d" % n)

    i = 0
    while 1:
        p = Object(prog, 'void *', address=buckets)
        if p.value_() == 0:
            buckets = buckets + 8
            continue

        data = Object(prog, "struct " + struct_name, address=p.value_())
        if hmap == "ufid_tc":
            print_ufid_tc_data(data)
        else:
            print(data)

        i += 1
        if i == n:
            return

        if hmap == "ufid_tc":
            next = data.ufid_node.next
        if hmap == "port_to_netdev":
            next = data.portno_node.next

        while next.value_() != 0:

            data = Object(prog, "struct " + struct_name, address=next.value_())
            if hmap == "ufid_tc":
                print_ufid_tc_data(data)
            else:
                print(data)

            i += 1
            if i == n:
                return

            if hmap == "ufid_tc":
                next = data.ufid_node.next
            if hmap == "port_to_netdev":
                next = data.portno_node.next

        buckets = buckets + 8

# print_hmap("ufid_tc", "ufid_tc_data")
print_hmap("port_to_netdev", "port_to_netdev_data")

# all_commands = prog["all_commands"]
# print(all_commands)
