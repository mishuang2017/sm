#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object

import sys
import os

sys.path.append("..")
from lib import *

mlx5e_rep_priv = get_mlx5e_rep_priv()
ct_priv = mlx5e_rep_priv.uplink_priv.ct_priv

print("=== mlx5e_rep_priv.uplink_priv.ct_priv.ct ===")
# print("mlx5_flow_table %lx" % ct_priv.ct)
flow_table("ct_priv.ct", ct_priv.ct)

print("=== mlx5e_rep_priv.uplink_priv.ct_priv.ct_nat ===")
flow_table("ct_priv.ct_nat", ct_priv.ct_nat)

print("=== mlx5e_rep_priv.uplink_priv.ct_priv.post_ct ===")
# print("mlx5_flow_table %lx" % ct_priv.post_ct)
flow_table("ct_priv.post_ct", ct_priv.post_ct)

###############################

fte_ids = ct_priv.fte_ids

print("=== mlx5e_rep_priv.uplink_priv.ct_priv.fte_ids ===")
for node in radix_tree_for_each(fte_ids.idr_rt):
    mlx5_ct_flow = Object(prog, 'struct mlx5_ct_flow', address=node[1].value_())
#     print(mlx5_ct_flow)
    print("mlx5_ct_flow %lx" % mlx5_ct_flow.address_of_())
    print("\tfte_id: %d" % mlx5_ct_flow.fte_id, end='\t')
    print("chain_mapping: %d" % mlx5_ct_flow.chain_mapping, end='\t')
    print('')

    print("\tmlx5_ct_flow.pre_ct_attr")
#     print(mlx5_ct_flow.pre_ct_attr)
    print_mlx5_esw_flow_attr(mlx5_ct_flow.pre_ct_attr)

    print("\tmlx5_ct_flow.post_ct_attr")
#     print(mlx5_ct_flow.post_ct_attr)
    print_mlx5_esw_flow_attr(mlx5_ct_flow.post_ct_attr)

    print("\tmlx5_ct_flow.pre_ct_rule")
    print_mlx5_flow_handle(mlx5_ct_flow.pre_ct_rule)

    print("\tmlx5_ct_flow.post_ct_rule")
    print_mlx5_flow_handle(mlx5_ct_flow.post_ct_rule)

###############################

# tuple_ids = ct_priv.tuple_ids
# print(tuple_ids)

# print("=== mlx5e_rep_priv.uplink_priv.ct_priv.tuple_ids ===")
# for node in radix_tree_for_each(tuple_ids):
#     print(node)
#     mlx5_ct_zone_rule = Object(prog, 'struct mlx5_ct_zone_rule', address=node[1].value_())
#     print("tupleid: %x" % mlx5_ct_zone_rule.tupleid)

################################

# print(ct_priv)
print("\n=== mlx5e_rep_priv.uplink_priv.ct_priv.zone_ht ===")
zone_ht = ct_priv.zone_ht
# print(zone_ht)

for i, mlx5_ct_ft in enumerate(hash(zone_ht, 'struct mlx5_ct_ft', 'node')):
    print("mlx5_ct_ft %lx" % mlx5_ct_ft)
    print("zone: %d" % mlx5_ct_ft.zone)

    print("nf_flowtable %lx" % mlx5_ct_ft.nf_ft)
    print("mlx5_ct_ft.ct_entries_ht:")
    ct_entries_ht = mlx5_ct_ft.ct_entries_ht
    for j, mlx5_ct_entry in enumerate(hash(ct_entries_ht, 'struct mlx5_ct_entry', 'node')):
        print("mlx5_ct_entry %lx" % mlx5_ct_entry)
        print("\tzone: %d" % mlx5_ct_entry.zone)
        print("\tcookie is flow_offload_tuple %lx" % mlx5_ct_entry.cookie)
        print("\trestor_cookie is 'ct | ctinfo' %lx" % mlx5_ct_entry.restore_cookie)
        print('')

        for k in range(2):
            mlx5_ct_zone_rule = mlx5_ct_entry.zone_rules[k]
            print("\tmlx5_ct_entry.zone_rules[%d]" % k)
            print("\tmlx5_ct_zone_rule %lx" % mlx5_ct_zone_rule.address_of_())
            print("\tmlx5_esw_flow_attr %lx" % mlx5_ct_zone_rule.attr.address_of_())
            print_mlx5_esw_flow_attr(mlx5_ct_zone_rule.attr)
            mlx5_flow_handle = mlx5_ct_zone_rule.rule
            nat = mlx5_ct_zone_rule.nat
            tupleid = mlx5_ct_zone_rule.tupleid
            print("\tmlx5_ct_entry.zone_rules[%d].rule: nat: %d, tupleid: %d" % (k, nat, tupleid))
            print("\t\tmlx5_ct_zone_rule.rule")
            print_mlx5_flow_handle(mlx5_flow_handle)
        print('')

    flow_table("mlx5_ct_ft.pre_ct.fdb", mlx5_ct_ft.pre_ct.fdb)
    flow_table("mlx5_ct_ft.pre_ct_nat.fdb", mlx5_ct_ft.pre_ct_nat.fdb)

#         print("\tmlx5_ct_entry.zone_rules[1].rule")
#         mlx5_flow_handle = mlx5_ct_entry.zone_rules[1].rule
#         print_mlx5_flow_handle(mlx5_flow_handle)
#         print(mlx5_ct_entry.flow_rule)

#     ct_entries_list = mlx5_ct_ft.ct_entries_list
#     for mlx5_ct_entry in list_for_each_entry('struct mlx5_ct_entry', ct_entries_list.address_of_(), 'list'):
#         print(mlx5_ct_entry)
