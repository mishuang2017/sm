#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import time
import socket
import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
import lib

devlink_list = prog['devlink_list']
for devlink in list_for_each_entry('struct devlink', devlink_list.address_of_(), 'list'):
    print('')
    print("devlink %x" % devlink)
    pci_name = devlink.dev.kobj.name.string_().decode()
#     print(devlink)
    print(pci_name)
    print(devlink._net)
    print(devlink.ops.reload_down)
    print(devlink.ops.reload_up)
    mlx5_core_dev = Object(prog, 'struct mlx5_core_dev', address=devlink.priv.address_of_().value_())
    print("mlx5_core_dev %x" % mlx5_core_dev.address_of_())
    for port in list_for_each_entry('struct devlink_port', devlink.port_list.address_of_(), 'list'):
#         print(port.attrs)
        print("\tport index: %d" % port.index)
