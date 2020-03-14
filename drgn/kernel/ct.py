#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)

from lib import *

size = prog['nf_conntrack_htable_size']
hash = prog['nf_conntrack_hash']
print("nf_conntrack_htable_size: %d" % size)

IP_CT_DIR_ORIGINAL = prog['IP_CT_DIR_ORIGINAL'].value_()
IPPROTO_UDP = prog['IPPROTO_UDP'].value_()
IPPROTO_TCP = prog['IPPROTO_TCP'].value_()

for i in range(size):
    head = hash[i]
    if head.first.value_() & 0x1:
        continue;
    for tuple in hlist_nulls_for_each_entry("struct nf_conntrack_tuple_hash", head.address_of_(), "hnnode"):
        protonum = tuple.tuple.dst.protonum.value_()
        dir = tuple.tuple.dst.dir.value_()
        if protonum == IPPROTO_TCP:
            dport = socket.ntohs(tuple.tuple.dst.u.tcp.port.value_())
            sport = socket.ntohs(tuple.tuple.src.u.tcp.port.value_())
        if protonum == IPPROTO_UDP:
            dport = socket.ntohs(tuple.tuple.dst.u.udp.port.value_())
            sport = socket.ntohs(tuple.tuple.src.u.udp.port.value_())
#         if protonum == IPPROTO_TCP and dir == IP_CT_DIR_ORIGINAL:
        if dir == IP_CT_DIR_ORIGINAL:
            print("src ip: %20s:%6d" % (ipv4(socket.ntohl(tuple.tuple.src.u3.ip.value_())), sport), end=' ')
            print("dst ip: %20s:%6d" % (ipv4(socket.ntohl(tuple.tuple.dst.u3.ip.value_())), dport), end=' ')
            print("protonum: %3d" % protonum, end=' ')
            print("dir: %3d" % dir)
