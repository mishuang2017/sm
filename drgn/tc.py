#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import socket
import sys
import os

libpath = os.path.dirname(os.path.realpath(__file__))
sys.path.append(libpath)
import lib

def print_nf_conntrack_tuple(tuple):
    print("src: ", end='')
    print(tuple.src.u3.in6.in6_u.u6_addr8)
    print("dst: ", end='')
    print(tuple.dst.u3.in6.in6_u.u6_addr8)

dev_base_head = prog['init_net'].dev_base_head.address_of_()

for dev in list_for_each_entry('struct net_device', dev_base_head,
                               'dev_list'):
    name = dev.name.string_().decode()
    addr = dev.value_()
    if "enp4s0f0" not in name and "vxlan_sys_4789" != name:
        continue
    print("%20s" % name, end='')
    print("%20x" % addr)
    print('')

    ingress_queue = dev.ingress_queue
    if ingress_queue.value_() == 0:
        continue
    qdisc = ingress_queue.qdisc
    qdisc_size = prog.type('struct Qdisc').size

#     print("%lx" % qdisc.value_())
    addr = qdisc.value_() + qdisc_size
    ingress_sched_data = Object(prog, 'struct ingress_sched_data', address=addr)
#     print(ingress_sched_data)
    block = ingress_sched_data.block
    if block.value_() == 0:
        continue
#     print(block)
    chain_list_addr = block.chain_list.address_of_()
    for chain in list_for_each_entry('struct tcf_chain', chain_list_addr, 'list'):
        print("chain index: %d, 0x%x" % (chain.index, chain.index))
        tcf_proto = chain.filter_chain
        while True:
#             print(tcf_proto)
            head = Object(prog, 'struct cls_fl_head', address=tcf_proto.root.value_())
#             print(head)
            for node in radix_tree_for_each(head.handle_idr.idr_rt):
#                 print("%lx" % node[1].value_())
                f = Object(prog, 'struct cls_fl_filter', address=node[1].value_())
                lib.print_cls_fl_filter(prog, f)
                print("==========================================\n")
            tcf_proto = tcf_proto.next
            if tcf_proto.value_() == 0:
                break
