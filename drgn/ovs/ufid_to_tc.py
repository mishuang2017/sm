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

def print_ufid_tc_data(data):
    print("name: %s" % data.netdev.name.string_().decode())
    print_ufid(data.ufid)

ufid_tc_datas = print_hmap(prog['ufid_to_tc'], "ufid_tc_data", "ufid_to_tc_node")
for i, ufid_tc_data in enumerate(ufid_tc_datas):
    print_ufid_tc_data(ufid_tc_data)
