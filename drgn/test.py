#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import sys
import os

libpath = os.path.dirname(os.path.realpath(__file__))
sys.path.append(libpath)
import lib

for i, dev in enumerate(lib.get_netdevs()):
    print(i, dev.name.string_().decode())
