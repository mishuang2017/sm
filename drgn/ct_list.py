#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object

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
    print(i.nr_flows)
#     print("cookie: %lx" % i.cookie)     # pointer of skb
