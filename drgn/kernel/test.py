#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
import lib

rep = lib.get_mlx5e_rep_priv()
print(rep.rep.esw.mode)
#         .rep = (struct mlx5_eswitch_rep *)0xffff9694bdde5a78,
