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

xbridge = get_xbridge("br")
# print(xbridge)

sflow = xbridge.sflow
print(sflow)

sflow_ports = print_hmap(sflow.ports.address_of_(), "dpif_sflow_port", "hmap_node")
for i, sflow_port in enumerate(sflow_ports):
    print("sflow port odp_port: %d, dsi: %d" % (sflow_port.odp_port, sflow_port.dsi.ds_index))
collectors = sflow.collectors
for j in range(collectors.n_fds):
    print("fds[%d] = %d" % (j, collectors.fds[j]))
#     print(sflow.sflow_agent)
print(sflow.sflow_agent.samplers)
#     print(sflow.sflow_agent.samplers.agent)
#     print(sflow.options)
targets = sflow.options.targets
ssets = print_hmap(targets.map, "sset_node", "hmap_node")
for k, sset in enumerate(ssets):
    print("ofproto_dpif.sflow.options.targets: %s" % sset.name[0].address_of_().string_().decode())
