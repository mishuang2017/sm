#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import time
import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
import lib

mlx5e_priv = lib.get_mlx5_pf0()
mlx5e_rep_priv = mlx5e_priv.ppriv

def print_neigh_hash_entry(n):
    print(n)
#     print("mlx5e_neigh.dst_ip: %s" % n.m_neigh.dst_ip.v6.in6_u.u6_addr8)

def print_encap(e):
    print(e)
#     print("encap_id: %d" % e.encap_id)

flow_block_indr_dev_list = prog['flow_block_indr_dev_list']

for flow_indr_dev in list_for_each_entry('struct flow_indr_dev', flow_block_indr_dev_list.address_of_(), 'list'):
    print(flow_indr_dev)
    cb_priv = flow_indr_dev.cb_priv
    mlx5e_rep_priv = Object(prog, 'struct mlx5e_rep_priv', address=cb_priv.value_())
#     print(mlx5e_rep_priv)


flow_block_indr_list = prog['flow_block_indr_list']

for flow_block_cb in list_for_each_entry('struct flow_block_cb', flow_block_indr_list.address_of_(), 'indr.list'):
    print(flow_block_cb)

tc_indr_block_priv_list = mlx5e_rep_priv.uplink_priv.tc_indr_block_priv_list
for mlx5e_rep_indr_block_priv in list_for_each_entry('struct mlx5e_rep_indr_block_priv', tc_indr_block_priv_list.address_of_(), 'list'):
    print(mlx5e_rep_indr_block_priv)

# mlx5e_block_cb_list = prog['mlx5e_block_cb_list']
# print(mlx5e_block_cb_list)
# for flow_block_cb in list_for_each_entry('struct flow_block_cb', mlx5e_block_cb_list.address_of_(), 'driver_list'):
#     print(flow_block_cb)
