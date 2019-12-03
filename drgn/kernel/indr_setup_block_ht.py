#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
from drgn import container_of
from drgn import cast
import time
import socket
import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
import lib

indr_setup_block_ht = prog['indr_setup_block_ht']
# print(indr_setup_block_ht)

def hash(rhashtable, type, member):
    nodes = []

    tbl = rhashtable.tbl

    buckets = tbl.buckets
    size = tbl.size.value_()

    for i in range(size):
        addr = buckets[i]
#         print(addr)
        rhash_head = cast("struct rhash_head *", addr)
#         print(rhash_head)
        head = rhash_head
        while True:
            if addr.value_() == 0:
                break;
            obj = container_of(rhash_head, type, member)
#             print(obj)
            nodes.append(obj)
            rhash_head = rhash_head.next.value_() & 0xfffffffffffffffe
#             print("%lx" % rhash_head)
            rhash_head = Object(prog, 'struct rhash_head', address=rhash_head)
#             print(rhash_head)
            rhash_head = rhash_head.next
            if rhash_head == head:
                break;

    return nodes

# hash(indr_setup_block_ht, 'struct flow_indr_block_dev', 'ht_node')

def print_indr_setup_block_ht(block):
    print(block)
    cb_list = block.cb_list
#     print(cb_list)
    for e in list_for_each_entry('struct flow_indr_block_cb', cb_list.address_of_(), 'list'):
#         print(e)
        print(lib.address_to_name(hex(e.cb)))
        priv = Object(prog, "struct mlx5e_rep_priv", address=e.cb_priv.address_of_())
#         print(priv)
        print("mlx5e_rep_priv %lx" % e.cb_priv.address_of_())

for i, node in enumerate(hash(indr_setup_block_ht, 'struct flow_indr_block_dev', 'ht_node')):
    print(i)
    print_indr_setup_block_ht(node)
