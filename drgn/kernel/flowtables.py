#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
from lib import *

flowtables = prog['flowtables']

for nf_ft in list_for_each_entry('struct nf_flowtable', flowtables.address_of_(), 'list'):
    hash = nf_ft.rhashtable
    print("nf_flowtable %lx" % nf_ft)
#     print(nf_ft)
    gc_work_func = nf_ft.gc_work.work.func
    print("nf_ft.gc_work.work.func: %s" % address_to_name(hex(gc_work_func)))
    cb_list = nf_ft.flow_block.cb_list
    for cb in list_for_each_entry('struct flow_block_cb', cb_list.address_of_(), 'list'):
#         print(cb)
        print("\tcb: %s" % address_to_name(hex(cb.cb)))
        print("\tmlx5_ct_ft %lx" % cb.cb_priv)
