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

all_dpif_backers = prog['all_dpif_backers']
print("all_dpif_backers")
print(all_dpif_backers)
one = all_dpif_backers.map.one
shash = Object(prog, 'struct shash_node', address=one.value_())
print("all_dpif_backers.map.one/shash")
print(shash)
backer = Object(prog, 'struct dpif_backer', address=shash.data)
print("%x" % backer.address_of_())

# print("backer")
# print(backer)
print("backer.udpif")
print(backer.udpif)

print("udpif")
udpif = backer.udpif

# sys.exit(0)

n = udpif.n_revalidators
rev = udpif.revalidators

print("n: %d" % n)
print("revalidators: %x" % rev)


# dump = udpif.dump
# print(dump)
# dpif_netlink_flow_dump = Object(prog, 'struct dpif_netlink_flow_dump', address=dump.value_())
# print(dpif_netlink_flow_dump)

# for i in range(n):
#     print(rev[i])


# ukeys = udpif.ukeys
# for i in range(512):
#     print("%d: %d" % (i, ukeys[i].cmap.impl.p.n.value_()))

def address_to_name(address):
#     print("address: %s" % address)
    (status, output) = subprocess.getstatusoutput("nm /usr/sbin/ovs-vswitchd | grep " + address.strip("0x") + " | awk '{print $3}'")
#     print("%d, %s" % (status, output))

    if status:
        return ""

    return output

dpif = udpif.dpif
print("dpif")
print(dpif)
print(address_to_name(hex(dpif.dpif_class.get_stats.value_())))
print(address_to_name(hex(dpif.dpif_class.flow_dump_thread_create.value_())))
print(address_to_name(hex(dpif.dpif_class.port_add.value_())))
print(address_to_name(hex(dpif.dpif_class.recv.value_())))
print(address_to_name(hex(dpif.dpif_class.recv_wait.value_())))
