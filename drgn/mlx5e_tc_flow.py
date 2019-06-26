#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object

import sys
import os

libpath = os.path.dirname(os.path.realpath(__file__))
sys.path.append(libpath)
import lib

mlx5e_rep_priv = lib.get_mlx5e_rep_priv()

# for old kernel
# tc_ht = mlx5e_rep_priv.tc_ht

# for new kernel
tc_ht = mlx5e_rep_priv.uplink_priv.tc_ht

# print(tc_ht)

for i, flow in enumerate(lib.hash(tc_ht, 'struct mlx5e_tc_flow', 'node')):
    name = flow.priv.netdev.name.string_().decode()
    print("%s: mlx5e_tc_flow %lx" % (name, flow.value_()))
    print("refcnt: %d" % (flow.refcnt.refs.counter.value_()))
