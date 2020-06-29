#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import sys
import os

sys.path.append('.')
from lib import *

priv = get_pf0_netdev()
print(priv.name.string_().decode())

nr_of_total_mf_alloc_flow = prog['nr_of_total_mf_alloc_flow']
nr_of_total_mf_dealloc_flow = prog['nr_of_total_mf_dealloc_flow']

print(nr_of_total_mf_alloc_flow)
print(nr_of_total_mf_dealloc_flow)
