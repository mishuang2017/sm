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

nfs = prog['net_families']
# print(nfs)

NPROTO = 45

for i in range(NPROTO):
    nf = nfs[i]
    if nf.value_():
        print("family: %2d, create: %s" % (nf.family.value_(), lib.address_to_name(hex(nf.create))))
#         print(nf)
