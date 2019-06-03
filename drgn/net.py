#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object

dev_base_head = prog['init_net'].dev_base_head.address_of_()
print(f'&init_net->dev_base_head is {dev_base_head}')

for dev in list_for_each_entry('struct net_device', dev_base_head,
                               'dev_list'):
    name = dev.name.string_().decode()
    if name == "enp4s0f0":
        print(dev.name)
        size = prog.type('struct net_device').size
        print(size)
        mlx5 = dev.value_() + size
        print("%lx" % mlx5)
        obj = Object(prog, 'struct mlx5e_priv', address=mlx5)
        print(obj.channels)
