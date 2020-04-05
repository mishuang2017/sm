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
    gc_work_func = nf_ft.gc_work.work.func
    print(address_to_name(hex(gc_work_func)))
