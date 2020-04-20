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

def print_hmap(hmap_addr, struct_name, member):
    objs = []

    buckets = hmap_addr.buckets.value_()
    n = hmap_addr.n.value_()

#     print("\n=== %s: buckets: %x, n: %d ===" % (struct_name, buckets, n))

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

xcfgp = prog['xcfgp']
def get_xbridge(name):
    xbridges_hmap = xcfgp.p.xbridges

    xbridges = print_hmap(xbridges_hmap, "xbridge", "hmap_node")
    for i, xbridge in enumerate(xbridges):

        if xbridge.name.string_().decode() == name:
            return xbridge

# usually there is only one backer named "system"
def get_backer():
    dpif_backers = print_hmap(prog['all_dpif_backers'].map, "hmap", "node")
    for i, dpif_backer in enumerate(dpif_backers):
        shash = container_of(dpif_backer.address_of_(), "struct shash_node", "node")
        if shash.name.string_().decode() == "system":
            backer = Object(prog, 'struct dpif_backer', address=shash.data)
            return backer

def address_to_name(address):
#     print("address: %s" % address)
    (status, output) = subprocess.getstatusoutput("nm /usr/sbin/ovs-vswitchd | grep " + address.strip("0x") + " | awk '{print $3}'")
#     print("%d, %s" % (status, output))

    if status:
        return ""

    return output

def get_ofproto_dpif(name):
    ofprotos = print_hmap(prog['all_ofprotos'], "ofproto", "hmap_node")
    for i, ofproto in enumerate(ofprotos):
        if ofproto.name.string_().decode() == name:
            ofproto_dpif = container_of(ofproto.address_of_(), "struct ofproto_dpif", "up")
            return ofproto_dpif
