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
from lib import *

zones_ht = prog['zones_ht']

def print_flow_offload_tuple(t):
#     print(t)
    print("src_v4: %10s" % ipv4(socket.ntohl(t.src_v4.s_addr.value_())), end='\t')
    print("dst_v4: %10s" % ipv4(socket.ntohl(t.dst_v4.s_addr.value_())), end='\t')
    print("src_port: %6d" % socket.ntohs(t.src_port.value_()), end='\t')
    print("dst_port: %6d" % socket.ntohs(t.dst_port.value_()), end='\t')
    print("l3proto: %2d" % t.l3proto.value_(), end='\t')
    print("l4proto: %2d" % t.l4proto.value_(), end='\t')
    print("dir: %d" % t.dir.value_(), end='\t')
    print('')

def print_flow_offload(flow):
    print("%lx" % flow.address_of_())

for i, flow_table in enumerate(hash(zones_ht, 'struct tcf_ct_flow_table', 'node')):
    nf_ft = flow_table.nf_ft
    zone = flow_table.zone
    print("zone: %d" % zone)
#     print(nf_ft)
    ft_ht = nf_ft.rhashtable
#     print(ft_ht)
    for j, tuple_rhash in enumerate(hash(ft_ht, 'struct flow_offload_tuple_rhash', 'node')):
        tuple = tuple_rhash.tuple
        print_flow_offload_tuple(tuple)
        flow_offload = cast("struct flow_offload *", tuple_rhash)
        print(flow_offload)
