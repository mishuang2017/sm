#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
from drgn import reinterpret
import time
import socket

import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
from lib import *

print(pf0_name)

mlx5e_priv = get_mlx5e_priv(pf0_name)
mlx5_eswitch_fdb = mlx5e_priv.mdev.priv.eswitch.fdb_table

slow_fdb = mlx5e_priv.mdev.priv.eswitch.fdb_table.offloads.slow_fdb
flow_table("mlx5e_priv.mdev.priv.eswitch.fdb_table.offloads.slow_fdb", slow_fdb)
vport_to_tir = mlx5e_priv.mdev.priv.eswitch.offloads.ft_offloads
flow_table("mlx5e_priv.mdev.priv.eswitch.offloads.ft_offloads", vport_to_tir)
