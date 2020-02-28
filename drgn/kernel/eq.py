#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
# import lib
from lib import *

devs = get_mlx5_core_devs()
eq_table = devs[0].priv.eq_table

num = eq_table.num_comp_eqs.value_()
print("num_comp_eqs: %d" % num)

for comp in list_for_each_entry('struct mlx5_eq_comp', eq_table.comp_eqs_list.address_of_(), "list"):
	print(comp)
