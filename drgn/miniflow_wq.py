#!/usr/local/bin/drgn -k

from drgn import container_of
from drgn.helpers.linux import *
from drgn import Object

import sys
import os

libpath = os.path.dirname(os.path.realpath(__file__))
sys.path.append(libpath)
import lib

# table = prog.variable('_flowtable', "/images/chrism/linux/drivers/net/ethernet/mellanox/mlx5/core/miniflow_aging.c")
# table = prog.variable('_flowtable')
# table = prog.variable('first_device')
wq_addr = 0xffff8fb2544bb400
wq = Object(prog, 'struct workqueue_struct', address=wq_addr)
pwqs = wq.pwqs.address_of_()
# print(wq)
for pwq in list_for_each_entry('struct pool_workqueue', pwqs, 'pwqs_node'):
    print(pwq.nr_in_flight.value_())
    nr_active = pwq.nr_active.value_()
#     print(nr_active)
    if nr_active != 0:
#         print(pwq.pool)
        print("worker_pool.id: %d" % pwq.pool.id.value_())
        print("worker_pool.nr_active: %d" % pwq.nr_active.value_())
        print("worker_pool.max_active: %d" % pwq.max_active.value_())
        workers = pwq.pool.workers.address_of_()
        for worker in list_for_each_entry('struct worker', workers, 'node'):
            desc = worker.desc.string_().decode()
            if desc == "miniflow":
                print("worker.id: %d, task.cpu: %d" % (worker.id.value_(), worker.task.cpu.value_()))
#                 print(worker)
