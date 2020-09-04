#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import container_of
from drgn import Object

import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
from lib import *

mlx5e_priv = get_mlx5_pf0()

# struct mlx5_esw_offload
offloads = mlx5e_priv.mdev.priv.eswitch.offloads

encap_tbl = offloads.encap_tbl

for i in range(256):
    node = encap_tbl[i].first
    while node.value_():
        obj = container_of(node, "struct mlx5e_encap_entry", "encap_hlist")
#         print(obj)
        print("mlx5e_encap_entry %lx" % obj.value_())
        mlx5e_encap_entry = Object(prog, 'struct mlx5e_encap_entry', address=obj.value_())
#         print(mlx5e_encap_entry.m_neigh)
        print_tun(mlx5e_encap_entry.tun_info)
#         print("encap_id %lx" % mlx5e_encap_entry.encap_id.value_())
        print(mlx5e_encap_entry.pkt_reformat)
        print("encap id: %x" % mlx5e_encap_entry.pkt_reformat.id.value_())
        node = node.next

mlx5e_rep_priv = get_mlx5e_rep_priv()
addr = mlx5e_rep_priv.neigh_update.neigh_list.address_of_()
for e in list_for_each_entry('struct mlx5e_neigh_hash_entry', addr, 'neigh_list'):
    print(e)
    print("mlx5e_neigh_hash_entry %lx" % e.value_())
