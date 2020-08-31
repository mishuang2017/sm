#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
from drgn import container_of
import socket

import subprocess
import drgn
import sys
import time

sys.path.append(".")
from lib_ovs import *

port_to_netdev_datas = print_hmap(prog["port_to_netdev"], "port_to_netdev_data", "portno_node")
for i, port in enumerate(port_to_netdev_datas):
    print("ifindex: %d, name: %15s, type: %10s, port_no: %d" % \
        (port.ifindex, port.dpif_port.name.string_().decode(), \
        port.dpif_port.type.string_().decode(), port.dpif_port.port_no))
    print(port.netdev)
