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
    print(devlink.ops.reload_down)
    print(devlink.ops.reload_up)
#     print(devlink.dev.kobj)
    for port in list_for_each_entry('struct devlink_port', devlink.port_list.address_of_(), 'list'):
#         print(port.attrs)
        print(port.index)
