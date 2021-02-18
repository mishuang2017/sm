#!/usr/local/bin/drgn -k

from drgn import container_of
from drgn.helpers.linux import *
from drgn import Object

import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
from lib import *

try:
    table_addr = prog['_flowtable']
except LookupError as x:
    print("no _flowtable")
    sys.exit(1)

# table_addr = lib.name_to_address("_flowtable")
if table_addr.value_() == 0:
    print("_flowtable is not initialized")
    sys.exit(1)

table = Object(prog, 'struct flow_offload_table', address=table_addr)
# print(table)

def hash1(rhashtable):
    nodes = []

    tbl = rhashtable.tbl

    buckets = tbl.buckets
    size = tbl.size.value_()

    for i in range(size):
        rhash_head = buckets[i]
        if struct_exist("struct rhash_lock_head"):
            rhash_head = cast("struct rhash_head *", rhash_head)
            if rhash_head.value_() == 0:
                continue

        while True:
            if rhash_head.value_() & 1:
                break;
            nodes.append(rhash_head)
            rhash_head = rhash_head.next

    return nodes

entries = []
print("in get_entries")
for i, flow in enumerate(hash1(table.rhashtable)):
    print("index: %d" % i)
    flow_offload_tuple_rhash = Object(prog, 'struct flow_offload_tuple_rhash', address=flow.value_())
    dir = flow_offload_tuple_rhash.tuple.dst.dir

    size = prog.type('struct flow_offload_tuple_rhash').size
#     print("size: %lx" % (size))
    print("flow_offload_tuple_rhash %lx" % (flow_offload_tuple_rhash.address_of_()))

    if dir == 0:
        offset = 0
    if dir == 1:
        offset = size

    flow_offload_entry = flow_offload_tuple_rhash.address_of_().value_() - offset
    if flow_offload_entry not in entries:
        entries.append(flow_offload_entry)

print("entries: %d" % len(entries))

for i in entries:
    flow_offload_entry = Object(prog, 'struct flow_offload_entry', address=i)
    print("flow_offload_entry %lx" % flow_offload_entry.address_of_().value_())

    deps = flow_offload_entry.deps
    for flow in list_for_each_entry('struct mlx5e_tc_flow', deps.address_of_(), 'nft_node'):
        name = flow.priv.netdev.name.string_().decode()
        lastuse = flow.dummy_counter.cache.lastuse
        refcnt = flow.refcnt.refs.counter.value_()
        print("\t%-10s: %lx, lastuse: %ld, refcnt: %d" % (name, flow.value_(), lastuse / 1000, refcnt))
