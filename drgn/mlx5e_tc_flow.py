#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
from drgn import container_of
import time
import sys
import os

libpath = os.path.dirname(os.path.realpath(__file__))
sys.path.append(libpath)
import lib

def hash(ht, type, member):
    tbl = ht.tbl
    buckets = tbl.buckets
    size = tbl.size.value_()
#     print(tbl)
#     print(size)
#     print(buckets)

    for i in range(size):
        rhash_head = buckets[i]
        while True:
            if rhash_head.value_() & 1:
                break;
            addr = rhash_head.value_()
            print("mlx5e_tc_flow: %lx" % addr)
            obj = container_of(rhash_head, type, member)
            # pointer of cls_fl_filter
            print("cookie: %lx" % obj.cookie)
            rhash_head = rhash_head.next

mlx5e_priv = lib.get_mlx5_pf0(prog)

# struct mlx5_esw_offload
offloads = mlx5e_priv.mdev.priv.eswitch.offloads

# struct mlx5_eswitch_rep
vport = offloads.vport_reps

# struct mlx5_eswitch_rep_if
rep_if = vport.rep_if

# struct mlx5e_rep_priv
priv = rep_if[prog['REP_ETH']].priv
mlx5e_rep_priv = Object(prog, 'struct mlx5e_rep_priv', address=priv.value_())

tc_ht = mlx5e_rep_priv.tc_ht
hash(tc_ht, 'struct mlx5e_tc_flow', 'node')
# print(tc_ht)
