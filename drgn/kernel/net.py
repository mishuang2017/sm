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

# TODO: multiple address
def print_ip_address(dev):
    ifa_list = dev.ip_ptr.ifa_list
    if ifa_list:
        print("%s" % lib.ipv4(socket.ntohl(dev.ip_ptr.ifa_list.ifa_address.value_())))
    else:
        print("")

for x, dev in enumerate(lib.get_netdevs()):
    name = dev.name.string_().decode()
    addr = dev.value_()
#     if "enp" in name:
    print("%20s%20x\t" % (name, addr), end="")
    print_ip_address(dev)
