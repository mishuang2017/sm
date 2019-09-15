#!/usr/local/bin/drgn -k

from drgn import container_of
from drgn.helpers.linux import *
from drgn import Object

import sys
import os

libpath = os.path.dirname(os.path.realpath(__file__))
sys.path.append(libpath)
import lib

def print_worker_pool(pool):
#     print("worker_pool.id: %d" % pool.id.value_())
#     print("worker_pool.cpu: %d" % pool.cpu.value_())
    workers = pool.workers.address_of_()
    for worker in list_for_each_entry('struct worker', workers, 'node'):
        desc = worker.desc.string_().decode()
        if desc == "miniflow" or pool.id.value_() == 32:
            print("worker.id: %d, task.cpu: %d, current_func: %x" % (worker.id.value_(), worker.task.cpu.value_(), worker.current_func.value_()))

idr = prog['worker_pool_idr'].address_of_()

for i in radix_tree_for_each(idr.idr_rt):
    pool = Object(prog, 'struct worker_pool', address=i[1])
    print_worker_pool(pool)

# sys.exit(0)

wqs =  prog['workqueues'].address_of_()
for wq in list_for_each_entry('struct workqueue_struct', wqs, 'list'):
    name = wq.name.string_().decode()
    if name == "miniflow":
        miniflow_wq = wq
        break

# print(miniflow_wq)
pwqs = miniflow_wq.pwqs.address_of_()
print("\ndfl_pwq: %lx" % miniflow_wq.dfl_pwq)
for pwq in list_for_each_entry('struct pool_workqueue', pwqs, 'pwqs_node'):
    nr_active = pwq.nr_active.value_()
    if nr_active != 0:
        print("pool_workqueue %lx" % pwq)
        print(pwq.nr_in_flight.value_())
        print("worker_pool.nr_active: %d" % pwq.nr_active.value_())
        print("worker_pool.max_active: %d" % pwq.max_active.value_())
#         print(pwq.pool)
        print_worker_pool(pwq.pool)

