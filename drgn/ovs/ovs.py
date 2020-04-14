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

def print_hmap(hmap_addr, struct_name, member):
    objs = []

    buckets = hmap_addr.buckets.value_()
    n = hmap_addr.n.value_()

    print("\n=== %20s: buckets: %x, n: %d ===" % (struct_name, buckets, n))

    i = 0
    while 1:
        p = Object(prog, 'void *', address=buckets)
        if p.value_() == 0:
            buckets = buckets + 8
            continue

        data = Object(prog, "struct " + struct_name, address=p.value_())
        objs.append(data)

        i += 1
        if i == n:
            return objs

        next = data.member_(member).next

        while next.value_() != 0:

            data = Object(prog, "struct " + struct_name, address=next.value_())
            objs.append(data)

            i += 1
            if i == n:
                return objs

            next = data.member_(member).next

        buckets = buckets + 8

    return objs

# print_hmap("ufid_to_tc", "ufid_tc_data")

print_hmap(prog["port_to_netdev"], "port_to_netdev_data", "portno_node")

# all_commands = prog["all_commands"]
# print(all_commands)

# all_dpif_backers = prog['all_dpif_backers']
# print("all_dpif_backers")
# print(all_dpif_backers)
# one = all_dpif_backers.map.one
# shash = Object(prog, 'struct shash_node', address=one.value_())
# print("all_dpif_backers.map.one/shash")
# print(shash)
# backer = Object(prog, 'struct dpif_backer', address=shash.data)
# print("%x" % backer.address_of_())

dpif_backers = print_hmap(prog['all_dpif_backers'].map, "hmap", "node")
for i, dpif_backer in enumerate(dpif_backers):
    shash = container_of(dpif_backer.address_of_(), "struct shash_node", "node")
    print(shash.name.string_().decode())
    if shash.name.string_().decode() == "system":
        backer = Object(prog, 'struct dpif_backer', address=shash.data)
        break
        print("yes")

# print("backer")
# print(backer)
# print("backer.udpif")
# print(backer.udpif)

# print("udpif")
udpif = backer.udpif

# sys.exit(0)

n = udpif.n_revalidators
rev = udpif.revalidators

print("udpif.n_revalidators: %d" % n)
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

dpif_netlink = container_of(dpif, "struct dpif_netlink" , "dpif")
# print(dpif_netlink)

n_handlers = dpif_netlink.n_handlers
handlers =dpif_netlink.handlers
for i in range(n_handlers):
    print("handlers[%d]: epoll_fd: %d" % (i, handlers[i].epoll_fd))

uc_array_size = dpif_netlink.uc_array_size
channels =dpif_netlink.channels
for i in range(uc_array_size):
    sock = channels[i].sock
    print("channels[%d]: fd: %d, pid: %x, %d" % (i, sock.fd, sock.pid, sock.pid))


n_revalidators = prog['n_revalidators']
print("n_revalidators: %d" %n_revalidators)
n_handlers = prog['n_handlers']
print("n_handlers: %d" % n_handlers)

# struct ofproto_dpif {
#     struct ofproto up;
# }

ofproto_dpifs = print_hmap(prog['all_ofproto_dpifs_by_name'], "ofproto_dpif", "all_ofproto_dpifs_by_name_node")
for i, ofproto_dpif in enumerate(ofproto_dpifs):
    sflow = ofproto_dpif.sflow
    print(sflow)
    collectors = sflow.collectors
    for j in range(collectors.n_fds):
        print("fds[%d] = %d" % (j, collectors.fds[j]))
#     print(sflow.sflow_agent)
#     print(sflow.sflow_agent.samplers)
#     print(sflow.sflow_agent.samplers.agent)
#     print(sflow.options)
    targets = sflow.options.targets
    ssets = print_hmap(targets.map, "sset_node", "hmap_node")
    for k, sset in enumerate(ssets):
        print("%s" % sset.name[0].address_of_())

ofprotos = print_hmap(prog['all_ofprotos'], "ofproto", "hmap_node")
for i, ofproto in enumerate(ofprotos):
    set_sflow = ofproto.ofproto_class.set_sflow
    print(address_to_name(hex(set_sflow.value_())))
