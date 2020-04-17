#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
from lib import *

# ppriv = get_mlx5e_rep_priv()
# print(ppriv.vport_rx_rule)
# print_dest(ppriv.vport_rx_rule.rule[0])

for x, dev in enumerate(get_netdevs()):
    name = dev.name.string_().decode()
    if "enp4s0f0np0" in name:
        print(name)
        mlx5e_priv_addr = dev.value_() + prog.type('struct net_device').size
        mlx5e_priv = Object(prog, 'struct mlx5e_priv', address=mlx5e_priv_addr)
        ppriv = mlx5e_priv.ppriv
        if ppriv:
            mlx5e_rep_priv = Object(prog, 'struct mlx5e_rep_priv', address=ppriv.value_())
            print("flow %lx" % mlx5e_rep_priv.root_ft.value_())
            print_dest(mlx5e_rep_priv.vport_rx_rule.rule[0])
