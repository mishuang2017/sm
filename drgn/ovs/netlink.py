#!/usr/local/bin/drgn -k

from drgn.helpers.linux.pid import for_each_task
from drgn.helpers.linux import *
from drgn import Object
from drgn import container_of
from drgn import cast

import subprocess
import drgn
import sys
import time

sys.path.append("..")
from lib import *

null_fops = prog['null_fops'].address_of_().value_()
xfs_file_operations = prog['xfs_file_operations'].address_of_().value_()
shmem_file_operations = prog['shmem_file_operations'].address_of_().value_()
pipefifo_fops = prog['pipefifo_fops'].address_of_().value_()

eventpoll_fops = prog['eventpoll_fops'].address_of_().value_()

socket_file_ops = prog['socket_file_ops'].address_of_().value_()
# both netlink_ops and netlink_ops belong to socket
netlink_ops = prog['netlink_ops'].address_of_().value_()
inet_dgram_ops = prog['inet_dgram_ops'].address_of_().value_()

def print_netlink_sock(sock):
    print("sock.sk_protocol: %d" % sock.sk.sk_protocol, end='')
    print("\tportid: %10x, %20d" % (sock.portid, sock.portid), end='')
    print("\tdst_portid: %x" % sock.dst_portid, end='')
    print("\tflags: %x" % sock.flags)

def print_eventpoll(file):
    epoll = file.private_data
    epoll = Object(prog, "struct eventpoll", address=file.private_data)
    rb_root = epoll.rbr.rb_root

    print("eventpoll\t", end='')
#     print(epoll)
    for node in rbtree_inorder_for_each_entry("struct epitem", rb_root, "rbn"):
        print("%d" % node.ffd.fd.value_(), end=' ')
    print('')

def print_files(files, n):
    for i in range(n):
        file = files[i]

        print("%2d" % i, end='\t')
        # only print socket file
        if file.f_op.value_() == eventpoll_fops:
            print_eventpoll(file)
        elif file.f_op.value_() == socket_file_ops:
            sock = Object(prog, "struct socket", address=file.private_data)
            sk = sock.sk
            # only print netlink socket
            if netlink_ops == sock.ops.value_():
                netlink_sock = cast('struct netlink_sock *', sk)
                print_netlink_sock(netlink_sock)
            elif inet_dgram_ops == sock.ops.value_():
                print_udp_sock(sk)
            else:
                print('')
        elif file.f_op.value_() == pipefifo_fops:
            print('pipefifo_fops')
        elif file.f_op.value_() == null_fops:
            print('null_fops')
        elif file.f_op.value_() == xfs_file_operations:
            print('xfs_file_operations')
        elif file.f_op.value_() == shmem_file_operations:
            print('shmem_file_operations')
        else:
            print(file.f_op)

#         print("%2d" % i, end='\t')
def find_task(name):
    print('PID        COMM')
    for task in for_each_task(prog):
        pid = task.pid.value_()
        comm = task.comm.string_().decode()
        if comm == "ovs-vswitchd":
            print(f'{pid:<10} {comm}')
            return task

task = find_task("ovs-vswitchd")
next_fd = task.files.next_fd.value_()
open_fds_init = task.files.open_fds_init

fdt = task.files.fdt
# print(fdt)

print_files(fdt.fd, next_fd)
