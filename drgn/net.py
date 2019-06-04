#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import time

dev_base_head = prog['init_net'].dev_base_head.address_of_()
# print(f'&init_net->dev_base_head is {dev_base_head}')

for dev in list_for_each_entry('struct net_device', dev_base_head,
                               'dev_list'):
    name = dev.name.string_().decode()
    addr = dev.value_()
    if "enp4s0f" in name:
        print("%20s" % name, end='')
        print("%20x" % addr)
