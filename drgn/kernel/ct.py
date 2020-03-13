#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)

size = prog['nf_conntrack_htable_size']
hash = prog['nf_conntrack_hash']
print("nf_conntrack_htable_size: %d" % size)

for i in range(size):
    head = hash[i]
    if head.first.value_() & 0x1:
        continue;
    for ct in hlist_nulls_for_each_entry("struct nf_conn", head.address_of_(), "tuplehash[0].hnnode"):
        print("%x" % ct.value_())
