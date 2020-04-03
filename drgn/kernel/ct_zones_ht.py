#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import container_of
from drgn import Object
import time
import socket
import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
from lib import *

zones_ht = prog['zones_ht']

for i, flow_table in enumerate(hash(zones_ht, 'struct tcf_ct_flow_table', 'node')):
    print(flow_table)
