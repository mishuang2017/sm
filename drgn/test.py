#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import container_of
from drgn import Object

import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
from lib import *

mlx5e_priv = get_mlx5_pf0()
mlx5e_rep_priv = get_mlx5e_rep_priv()
uplink_priv = mlx5e_rep_priv.uplink_priv
sample_priv = uplink_priv.tc_psample
print(uplink_priv)
