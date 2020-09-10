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

def print_mlx5_sampler_handle(handle):
    print("sampler_id: %d, sample_ratio: %d, sample_table_id: %x, default_table_id: %x, vhca_id: %d, ref_count: %d" % \
            (handle.sampler_id, handle.sample_ratio, handle.sample_table_id, handle.default_table_id, handle.vhca_id, handle.ref_count))

print('\n=== sampler_termtbl ===')

# termtbl_list = prog['termtbl_list'].address_of_()
# print(termtbl_list)
# for handle in list_for_each_entry('struct mlx5_sampler_termtbl_handle', termtbl_list, 'list'):
#     print(handle)

print(offloads.sampler_termtbl_handle)
flow_table("sampler_termtbl", offloads.sampler_termtbl_handle.termtbl)

print('\n=== sampler_hashtbl ===\n')

sampler_hashtbl = prog['sampler_hashtbl']

for i in range(256):
    node = sampler_hashtbl[i].first
    while node.value_():
        obj = container_of(node, "struct mlx5_sampler_handle", "sampler_hlist")
#         print("mlx5_sampler_handle %lx" % obj.value_())
        mlx5_sampler_handle = Object(prog, 'struct mlx5_sampler_handle', address=obj.value_())
        print_mlx5_sampler_handle(mlx5_sampler_handle)
        node = node.next

print('\n=== offloads.num_flows.counter ===\n')
print("num_flows: %d" % offloads.num_flows.counter)

print('\n=== sample_restore_hashtbl ===\n')
sample_restore_hashtbl = prog['sample_restore_hashtbl']

for i in range(256):
    node = sample_restore_hashtbl[i].first
    while node.value_():
        obj = container_of(node, "struct mlx5_sample_restore_handle", "restore_hlist")
        print("mlx5_sample_restore_handle %lx" % obj.value_())
        mlx5_sample_restore_handle = Object(prog, 'struct mlx5_sample_restore_handle', address=obj.value_())
        print("mlx5_sample_restore_handle.obj_id: %d" % (mlx5_sample_restore_handle.obj_id))
        print(mlx5_sample_restore_handle)
        node = node.next


# mlx5e_priv = get_mlx5e_priv(pf0_name)
# offloads = mlx5e_priv.mdev.priv.eswitch.fdb_table.offloads
# esw_chains_priv = offloads.esw_chains_priv
# mapping_ctx = esw_chains_priv.chains_mapping

mlx5e_priv = get_mlx5e_priv(pf0_name)
offloads = mlx5e_priv.mdev.priv.eswitch.offloads
mapping_ctx = offloads.reg_c0_obj_pool

MLX5_MAPPING_OBJ_SAMPLE = prog['MLX5_MAPPING_OBJ_SAMPLE']
MLX5_MAPPING_OBJ_CHAIN = prog['MLX5_MAPPING_OBJ_CHAIN']

def print_mapping_mapping(mapping):
    if MLX5_MAPPING_OBJ_SAMPLE == mapping.type:
#         print(mapping.type)
        print("\tgroup_id: %d, %x, rate: %d, trunc_size: %d" % \
            (mapping.sample.group_id, mapping.sample.group_id, mapping.sample.rate, mapping.sample.trunc_size))

    if MLX5_MAPPING_OBJ_CHAIN == mapping.type:
        print("\tchain: %d, %x" % (mapping.chain, mapping.chain))

print('\n=== mapping mapping_ctx ===\n')
ht = mapping_ctx.ht
print("mapping_ctx %lx" % mapping_ctx)
for i in range(256):
    for item in hlist_for_each_entry('struct mapping_item', ht[i], 'node'):
        print("mapping id: %d\t" % item.id, end='')
        data = Object(prog, 'struct mlx5_mapping_obj',  address=item.data.address_of_())
        print_mapping_mapping(data)
