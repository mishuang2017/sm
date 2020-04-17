#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import container_of
from drgn import Object
import time
import socket
import sys
import os

sys.path.append("..")
from lib import *

zones_ht = prog['zones_ht']

def print_flow_offload_tuple(t):
#     print(t)
    print("\t\tflow_offload_tuple %lx" % t.address_of_())
    print("\t\tsrc_v4: %10s" % ipv4(socket.ntohl(t.src_v4.s_addr.value_())), end='\t')
    print("dst_v4: %10s" % ipv4(socket.ntohl(t.dst_v4.s_addr.value_())), end='\t')
    print("src_port: %6d" % socket.ntohs(t.src_port.value_()), end='\t')
    print("dst_port: %6d" % socket.ntohs(t.dst_port.value_()), end='\t')
    print("l3proto: %2d" % t.l3proto.value_(), end='\t')
    print("l4proto: %2d" % t.l4proto.value_(), end='\t')
    print("dir: %d" % t.dir.value_(), end='\t')
    print('')

def print_flow_offload(flow, dir):
    print("\tflow_offload %lx" % flow)
    if dir == 0:
        print("\tdir = 0")
    else:
        print("\tdir = 1")
    print("\t\tnf_conn %lx" % flow.ct)
    print("\t\tflags: %x, timeout: %x, type: %d" % (flow.flags, flow.timeout, flow.type), end='\t')
    print("(NF_FLOW_SNAT: %x)" % (1 << prog['NF_FLOW_SNAT'].value_()), end=' ')
    print("(NF_FLOW_HW: %x)" % (1 << prog['NF_FLOW_HW'].value_()))
#     print(flow)

for i, flow_table in enumerate(hash(zones_ht, 'struct tcf_ct_flow_table', 'node')):
    print("tcf_ct_flow_table %lx" % flow_table)
    print("nf_flowtable %lx" % flow_table.nf_ft.address_of_())
    nf_ft = flow_table.nf_ft
    zone = flow_table.zone
    print("zone: %d" % zone)
#     print(nf_ft)
    ft_ht = nf_ft.rhashtable
#     print(ft_ht)
    for j, tuple_rhash in enumerate(hash(ft_ht, 'struct flow_offload_tuple_rhash', 'node')):
        tuple = tuple_rhash.tuple
        dir = tuple.dir.value_()
        if dir == 0:
            flow_offload = cast("struct flow_offload *", tuple_rhash)
            print_flow_offload(flow_offload, dir)
        else:
            flow_offload = Object(prog, 'struct flow_offload', address=tuple_rhash.value_() - \
                prog.type('struct flow_offload_tuple_rhash').size)
            print_flow_offload(flow_offload.address_of_(), dir)
        print_flow_offload_tuple(tuple)
    print('')
