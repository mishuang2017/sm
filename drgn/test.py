#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import sys
import os

sys.path.append('.')
from lib import *

priv = get_pf0_netdev()
print(priv.name.string_().decode())

mlx5_flow_table = Object(prog, 'struct mlx5_flow_table', address=0xffff958995150400)
# print(mlx5_flow_table)
flow_table2("", mlx5_flow_table)
