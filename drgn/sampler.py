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

sampler_tbl = offloads.sampler_tbl

for i in range(256):
    node = sampler_tbl[i].first
    while node.value_():
        obj = container_of(node, "struct mlx5_sampler_handle", "sampler_hlist")
        print("mlx5_sampler_handle %lx" % obj.value_())
        mlx5_sampler_handle = Object(prog, 'struct mlx5_sampler_handle', address=obj.value_())
        print(mlx5_sampler_handle)
        node = node.next

sampler_termtbl_handle = offloads.sampler_termtbl_handle
print(sampler_termtbl_handle)
# sampler_default_tbl = offloads.sampler_default_tbl
# print(sampler_default_tbl)
