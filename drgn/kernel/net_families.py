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
        print("family: %2d, create: %20s" % (nf.family.value_(), lib.address_to_name(hex(nf.create))))

inetsw = prog['inetsw']

SOCK_PACKET = prog['SOCK_PACKET']
SOCK_MAX = SOCK_PACKET.value_() + 1
print("")

for i in range(SOCK_MAX):
    head = inetsw[i]
    for a in list_for_each_entry('struct inet_protosw', head.address_of_(), 'list'):
        print("type: %d, protocol: %3d, prot: %15s, ops: %20s" % (a.type.value_(),
            a.protocol.value_(),
            lib.address_to_name(hex(a.prot)),
            lib.address_to_name(hex(a.ops))))

SOCK_STREAM = prog['SOCK_STREAM']
SOCK_DGRAM = prog['SOCK_DGRAM']
SOCK_RAW = prog['SOCK_RAW']

print("")
print("SOCK_STREAM: %d" % SOCK_STREAM.value_())
print("SOCK_DGRAM: %d" % SOCK_DGRAM.value_())
print("SOCK_RAW: %d" % SOCK_RAW.value_())
