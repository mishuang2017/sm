#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
from drgn import container_of
import time

dev_base_head = prog['init_net'].dev_base_head.address_of_()
# print(f'&init_net->dev_base_head is {dev_base_head}')

def show_hash(ht, type, memeber):
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
            obj = container_of(rhash_head, type, memeber)
            # pointer of cls_fl_filter
#             print("cookie: %lx" % obj.cookie)
            rhash_head = rhash_head.next

for dev in list_for_each_entry('struct net_device', dev_base_head,
                               'dev_list'):
    name = dev.name.string_().decode()
    if name == "enp4s0f0":
        print(dev.name)
        size = prog.type('struct net_device').size
#         print("%lx" % size)
        mlx5e_priv_addr = dev.value_() + size
#         print("%lx" % mlx5e_priv_addr)
        mlx5e_priv = Object(prog, 'struct mlx5e_priv', address=mlx5e_priv_addr)

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
        show_hash(tc_ht, 'struct mlx5e_tc_flow', 'node')
#         print(tc_ht)
