#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import time
import sys
import os

libpath = os.path.dirname(os.path.realpath(__file__))
sys.path.append(libpath)
import lib

mlx5e_priv = lib.get_mlx5_pf0(prog)
mlx5_eswitch_fdb = mlx5e_priv.mdev.priv.eswitch.fdb_table
while True:
    for i in range(4):
        for j in range(17):
            for k in range(2):
                num_rules = mlx5_eswitch_fdb.offloads.fdb_prio[i][j][k].num_rules
                if num_rules:
                    print(i, j, k, num_rules)
                    time.sleep(1)
