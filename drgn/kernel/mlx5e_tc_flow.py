#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object

import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
import lib

mlx5e_rep_priv = lib.get_mlx5e_rep_priv()

# if lib.kernel("4.20.16+"):
#     tc_ht = mlx5e_rep_priv.uplink_priv.tc_ht
# else:
#     tc_ht = mlx5e_rep_priv.tc_ht

print("MLX5E_TC_FLOW_FLAG_SIMPLE %x" % (1 << prog['MLX5E_TC_FLOW_FLAG_SIMPLE'].value_()))
# print("MLX5E_TC_FLOW_FLAG_ESWITCH %x" % 1 << prog['MLX5E_TC_FLOW_FLAG_ESWITCH'].value_())

try:
    prog.type('struct mlx5_rep_uplink_priv')
    tc_ht = mlx5e_rep_priv.uplink_priv.tc_ht
except LookupError as x:
    tc_ht = mlx5e_rep_priv.tc_ht

for i, flow in enumerate(lib.hash(tc_ht, 'struct mlx5e_tc_flow', 'node')):
    name = flow.priv.netdev.name.string_().decode()
    print("%-10s mlx5e_tc_flow %lx, cookie: %lx, flags: %x" % \
        (name, flow.value_(), flow.cookie.value_(), flow.flags.value_()))

#     continue
#     print(flow.miniflow_list)
    j = 0
    for mlx5e_miniflow_node in list_for_each_entry('struct mlx5e_miniflow_node', flow.miniflow_list.address_of_(), 'node'):
#         print(mlx5e_miniflow_node)
        print("%d: mlx5e_miniflow %lx" % (j, mlx5e_miniflow_node.miniflow.value_()))
        j = j + 1
