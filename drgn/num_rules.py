#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import time

dev_base_head = prog['init_net'].dev_base_head.address_of_()
print(f'&init_net->dev_base_head is {dev_base_head}')

for dev in list_for_each_entry('struct net_device', dev_base_head,
                               'dev_list'):
    name = dev.name.string_().decode()
    if name == "enp4s0f0":
        print(dev.name)
        size = prog.type('struct net_device').size
        print("%lx" % size)
        mlx5e_priv_addr = dev.value_() + size
        print("%lx" % mlx5e_priv_addr)
        mlx5e_priv = Object(prog, 'struct mlx5e_priv', address=mlx5e_priv_addr)
        mlx5_eswitch_fdb = mlx5e_priv.mdev.priv.eswitch.fdb_table
        while True:
            for i in range(4):
                for j in range(17):
                    for k in range(2):
                        num_rules = mlx5_eswitch_fdb.offloads.fdb_prio[i][j][k].num_rules
                        if num_rules:
                            print(i, j, k, num_rules)
                            time.sleep(1)
