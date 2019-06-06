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

for flow in list_for_each_entry('struct mlx5e_tc_flow', prog['ct_list'].address_of_(), 'nft_node'):
    print("mlx5e_tc_flow: %lx" % flow.value_())
    for mini in list_for_each_entry('struct mlx5e_miniflow', flow.miniflow_list.address_of_(), 'node'):
        mlx5e_miniflow_node = Object(prog, 'struct mlx5e_miniflow_node', address=mini.value_())
        miniflow = mlx5e_miniflow_node.miniflow
        print("mlx5e_miniflow: %lx" % miniflow)
        if miniflow not in miniflow_list:
            miniflow_list.append(miniflow)

for i in miniflow_list:
    name = i.priv.netdev.name.string_().decode()
#     print(i.nr_flows)
#     print("cookie: %lx" % i.cookie)     # pointer of skb
#     print('{0}'.format(i.tuple))

    if name == "enp4s0f0_1" or name == "enp4s0f0":
#     if name == "enp4s0f0_1":
        for j in range(8):
            flow = i.path.flows[j]
            if flow:
                print(name, j)
                attr = flow.esw_attr[0]
                print("action: %4x, chain: %d" % (attr.action, attr.chain))
                print('')

        for j in range(8):
            flow = i.path.cookies[j]
            if flow:
                addr = flow.value_()
                if (addr & 1):
                    print("=========== %d %s %s ==========" % (j, name, "nf_conntrack_tuple"))
                    addr = flow.value_() & ~0x1
                    nf_conntrack_tuple = Object(prog, 'struct nf_conntrack_tuple', address=addr)
                    lib.print_nf_conntrack_tuple(nf_conntrack_tuple)
                else:
                    print("=========== %d %s %s ==========" % (j, name, "cls_fl_filter"))
                    cls_fl_filter = Object(prog, 'struct cls_fl_filter', address=addr)
                    lib.print_cls_fl_filter(prog, cls_fl_filter)

        n = i.nr_ct_tuples
        print("\nnr_ct_tuples: %x" % n)
        for k in range(n):
            lib.print_mlx5e_ct_tuple(i.ct_tuples[k], k)
        print("+++++++++++++++++++++ end ++++++++++++++++++++\n")
