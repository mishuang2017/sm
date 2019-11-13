#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import container_of
from drgn import Object

import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
import lib

mlx5e_priv = lib.get_mlx5_pf0()

# struct mlx5_esw_offload
offloads = mlx5e_priv.mdev.priv.eswitch.offloads

# ofed 4.6
mod_hdr_tbl = offloads.mod_hdr_tbl

# ofed 4.7
# mod_hdr_tbl = offloads.mod_hdr.hlist

for i in range(256):
    node = mod_hdr_tbl[i].first
    while node.value_():
        obj = container_of(node, "struct mlx5e_mod_hdr_entry", "mod_hdr_hlist")
        print("mlx5e_mod_hdr_entry %lx" % obj.value_())
        mlx5e_mod_hdr_entry = Object(prog, 'struct mlx5e_mod_hdr_entry', address=obj.value_())
        print("mod_hdr_id %lx" % mlx5e_mod_hdr_entry.mod_hdr_id.value_())

        print(mlx5e_mod_hdr_entry.key)
        actions = mlx5e_mod_hdr_entry.key.actions
        num_actions = mlx5e_mod_hdr_entry.key.num_actions
#         print(actions)
        for j in range(num_actions):
            p = Object(prog, 'void *', address=actions.value_())
            print(p)
            actions = actions + 8

        node = node.next
        print("")
