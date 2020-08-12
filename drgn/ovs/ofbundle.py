#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
from drgn import container_of
from socket import ntohl
import socket

import subprocess
import drgn
import sys
import time

sys.path.append(".")
from lib_ovs import *

ofproto = get_ofproto_dpif("br")

bundles = ofproto.bundles

ofbundles = print_hmap(bundles.address_of_(), "ofbundle", "hmap_node")
for j, ofbundle in enumerate(ofbundles):
    print(ofbundle)
