#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import time
import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
import lib

mlx5e_priv = lib.get_mlx5_pf0()
# struct mlx5_eswitch_rep
vport_reps = mlx5e_priv.mdev.priv.eswitch.offloads.vport_reps
print(vport_reps)
