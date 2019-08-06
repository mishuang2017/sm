#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import socket
import sys
import os

libpath = os.path.dirname(os.path.realpath(__file__))
sys.path.append(libpath)
import lib

miniflow_list = []

# for old 4.20 kernel
# for flow in list_for_each_entry('struct mlx5e_tc_flow', prog['ct_list'].address_of_(), 'nft_node'):
#     print("%s: mlx5e_tc_flow: %lx" % (flow.priv.netdev.name.string_().decode(), flow.value_()))
#     fc = flow.dummy_counter
#     p = fc.lastpackets
#     b = fc.lastbytes
#     print("packets: %d, bytes: %d" % (p, b))
#     for mini in list_for_each_entry('struct mlx5e_miniflow', flow.miniflow_list.address_of_(), 'node'):
#         mlx5e_miniflow_node = Object(prog, 'struct mlx5e_miniflow_node', address=mini.value_())
#         miniflow = mlx5e_miniflow_node.miniflow
#         print("mlx5e_miniflow: %lx" % miniflow)
#         if miniflow not in miniflow_list:
#             miniflow_list.append(miniflow)

mlx5e_rep_priv = lib.get_mlx5e_rep_priv()

for i, flow in enumerate(lib.hash(mlx5e_rep_priv.mf_ht, 'struct mlx5e_miniflow', 'node')):
    print("mlx5e_miniflow %lx" % flow.value_())
    miniflow_list.append(flow)

print('')
for i in miniflow_list:
    name = i.priv.netdev.name.string_().decode()
    print("nr_flows: %d" % i.nr_flows)
#     print("cookie: %lx" % i.cookie)     # pointer of skb
#     print('{0}'.format(i.tuple))

#     if name == "enp4s0f0_1" or name == "enp4s0f0" or name == "enp4s0f0_2":
    if name == "enp4s0f0":
        flow = i.flow
        print("miniflow->flow: mlx5e_tc_flow %lx" % (flow))
        fc = flow.esw_attr[0].counter
        lib.print_mlx5_fc(fc)
#         lib.print_mlx5_flow_handle(flow.rule[0])
#     if name == "enp4s0f0_1":
#         for j in range(8):
#             flow = i.path.flows[j]
#             if flow:
#                 print("%s: path.flows[%d]: %lx" % (name, j, flow.value_()))
#                 attr = flow.esw_attr[0]
#                 fc = flow.dummy_counter
#                 lib.print_mlx5_fc(fc)
#                 p = fc.lastpackets
#                 b = fc.lastbytes
#                 print("mlx5_fc: %lx, packets: %lx, bytes: %lx" % (fc, p, b))
#                 print("action: %4x, chain: %d" % (attr.action, attr.chain))
#                 print('')

        for j in range(8):
            flow = i.path.flows[j]
            print("mlx5e_tc_flow %lx" % (flow.value_()))
            continue
            cookie = i.path.cookies[j]
            if cookie:
                addr = cookie.value_()
                print("cookie %lx" % addr)
                if (addr & 1):
                    print("=========== %d %s %s ==========" % (j, name, "nf_conntrack_tuple"))
                    addr = addr & ~0x1
                    nf_conntrack_tuple = Object(prog, 'struct nf_conntrack_tuple', address=addr)
                    lib.print_nf_conntrack_tuple(nf_conntrack_tuple)
                else:
                    print("=========== %d %s %s ==========" % (j, name, "cls_fl_filter"))
                    cls_fl_filter = Object(prog, 'struct cls_fl_filter', address=addr)
                    lib.print_cls_fl_filter(cls_fl_filter)

#         n = i.nr_ct_tuples
#         print("\nnr_ct_tuples: %x" % n)
#         for k in range(n):
#             lib.print_mlx5e_ct_tuple(k, i.ct_tuples[k])
#         print("+++++++++++++++++++++ end ++++++++++++++++++++\n")