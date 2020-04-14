#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
from drgn import reinterpret
import time
import socket

import sys
import os

sys.path.append("..")
from lib import *

# mlx5e_priv = get_mlx5_pf0()
mlx5e_priv = get_mlx5e_priv(pf0_name)
offloads = mlx5e_priv.mdev.priv.eswitch.fdb_table.offloads
# print(offloads)
slow_fdb = offloads.slow_fdb
esw_chains_priv = offloads.esw_chains_priv
chains_ht = esw_chains_priv.chains_ht
prios_ht = esw_chains_priv.prios_ht
mapping_ctx = esw_chains_priv.chains_mapping
tc_end_fdb = esw_chains_priv.tc_end_fdb

print("tc_end_fdb %lx, slow_fdb: %lx" % (tc_end_fdb, slow_fdb))
# print(esw_chains_priv)

for i, chain in enumerate(hash(chains_ht, 'struct fdb_chain', 'node')):
#     print(chain)
#     print("chain id: %x" % chain.chain)
    for prio in list_for_each_entry('struct fdb_prio', chain.prios_list.address_of_(), 'list'):
        next_fdb = prio.next_fdb
        miss_group = prio.miss_group
        miss_rule = prio.miss_rule
        print("\n=== chain: %x, prio: %x, level: %x ===" % \
            (prio.key.chain, prio.key.prio, prio.key.level))
        print("fdb_prio %lx" % prio)
        print("next_fdb: %lx, miss_group: %lx, miss_rule: mlx5_flow_handle %lx" % \
            (next_fdb, miss_group, miss_rule))
        table = prio.fdb
        flow_table("", table)

def print_mapping_item(item):
    print("mapping_item %lx" % item, end='\t')
    print("cnt: %d" % item.cnt, end='\t')
    print("id (chain_mapping): %d" % item.id, end='\t')
    data = Object(prog, 'int *', address=item.data.address_of_())
    print("data (chain): 0x%x" % data.value_())

print('\n=== mapping_ctx ===\n')
ht = mapping_ctx.ht
print("mapping_ctx %lx" % mapping_ctx)
for i in range(256):
    for item in hlist_for_each_entry('struct mapping_item', ht[i], 'node'):
        print_mapping_item(item)

# for i, prio in enumerate(hash(prios_ht, 'struct fdb_prio', 'node')):
#     print(i)
#     print(prio)
#     table = prio.fdb
#     flow_table("", table)