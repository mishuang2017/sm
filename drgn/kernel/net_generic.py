#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import time
import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
import lib

gen = prog['init_net'].gen
id = prog['tcf_action_net_id']
print("tcf_action_net_id: %d" % id)
ptr = gen.ptr[id]
tcf_action_net = Object(prog, 'struct tcf_action_net', address=ptr.value_())
print("tcf_action_net %lx" % tcf_action_net.address_of_())

for cb in list_for_each_entry('struct tcf_action_egdev_cb', tcf_action_net.egdev_list.address_of_(), 'list'):
    print(cb)
