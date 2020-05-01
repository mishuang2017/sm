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

ofproto_dpif = get_ofproto_dpif("br")
ofproto = ofproto_dpif.up

# ofproto_dpif = container_of(ofproto.address_of_(), "struct ofproto_dpif", "up")
parts = ofproto_dpif.uuid.parts
print("%x-%x-%x-%x" % (parts[0], parts[1], parts[2], parts[3]))

set_sflow = ofproto.ofproto_class.set_sflow
print(address_to_name(hex(set_sflow.value_())))

# print(ofproto.ofproto_class)

ofproto_ports = print_hmap(ofproto.ports.address_of_(), "ofport", "hmap_node")
for j, ofproto_port in enumerate(ofproto_ports):
    print("name: %15s, ofp_port: %d" % (ofproto_port.netdev.name.string_().decode(), ofproto_port.ofp_port))
#     print(ofproto_port)
#     print(ofproto_port.netdev)

n_tables = ofproto.n_tables
print(n_tables)
for i in range(1):
    table = ofproto.tables[i]
    print(table)
