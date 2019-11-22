#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import time
import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
import lib

for x, dev in enumerate(lib.get_netdevs()):
    name = dev.name.string_().decode()
    addr = dev.value_()
    if "enp" in name:
        print("%20s%20x" % (name, addr))
