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
sample_priv = offloads.sample_priv

sampler_hashtbl = sample_priv.sampler_hashtbl

print('\n=== sampler_hashtbl ===\n')
for i in range(256):
    node = sampler_hashtbl[i].first
    while node.value_():
        obj = container_of(node, "struct mlx5_sampler_handle", "sampler_hlist")
        print("mlx5_sampler_handle %lx" % obj.value_())
        mlx5_sampler_handle = Object(prog, 'struct mlx5_sampler_handle', address=obj.value_())
        print(mlx5_sampler_handle)
        node = node.next

print('\n=== sampler_termtbl ===\n')
sampler_termtbl = sample_priv.termtbl
flow_table("", sampler_termtbl)

print('\n=== sampler_default_tbl ===\n')
sampler_default_tbl = sample_priv.default_tbl
flow_table("sampler_default_tbl", sampler_default_tbl)
print("sampler_default_tbl: %x" % sampler_default_tbl.id)

print("num_flows: %d" % offloads.num_flows.counter)

print('\n=== sample_mapping_hashtbl ===\n')
sample_mapping_tbl = sample_priv.sample_mapping_hashtbl

for i in range(256):
    node = sample_mapping_tbl[i].first
    while node.value_():
        obj = container_of(node, "struct mlx5_sample_mapping", "mapping_hlist")
        print("mlx5_sample_mapping %lx" % obj.value_())
        mlx5_sample_mapping = Object(prog, 'struct mlx5_sample_mapping', address=obj.value_())
        print(mlx5_sample_mapping)
        node = node.next


# mlx5e_priv = get_mlx5e_priv(pf0_name)
# offloads = mlx5e_priv.mdev.priv.eswitch.fdb_table.offloads
# esw_chains_priv = offloads.esw_chains_priv
# mapping_ctx = esw_chains_priv.chains_mapping

mlx5e_priv = get_mlx5e_priv(pf0_name)
offloads = mlx5e_priv.mdev.priv.eswitch.offloads
mapping_ctx = offloads.reg_c0_mapping

print('\n=== reg_c0 mapping_ctx ===\n')
ht = mapping_ctx.ht
print("mapping_ctx %lx" % mapping_ctx)
for i in range(256):
    for item in hlist_for_each_entry('struct mapping_item', ht[i], 'node'):
        print(item.id)
        data = Object(prog, 'struct mlx5_reg_c0_mapping',  address=item.data.address_of_())
        print(data)
