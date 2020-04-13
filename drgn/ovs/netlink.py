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

socket_file_ops = prog['socket_file_ops'].address_of_().value_()
netlink_ops = prog['netlink_ops'].address_of_().value_()
inet_dgram_ops = prog['inet_dgram_ops'].address_of_().value_()

def print_netlink_sock(sock):
    print("sock.sk_protocol: %d" % sock.sk.sk_protocol, end='')
    print("\tportid: %10x, %20d" % (sock.portid, sock.portid), end='')
    print("\tdst_portid: %x" % sock.dst_portid, end='')
    print("\tflags: %x" % sock.flags)

def print_files(files):
    for i in range(64):
        file = files[i]

        if file.value_() == 0:
            continue

        # only print socket file
        if socket_file_ops != file.f_op.value_():
            continue

        sock = Object(prog, "struct socket", address=file.private_data)
        sk = sock.sk
        # only print netlink socket
        if netlink_ops == sock.ops.value_():
            netlink_sock = cast('struct netlink_sock *', sk)
            print_netlink_sock(netlink_sock)
        if inet_dgram_ops == sock.ops.value_():
            print_udp_sock(sk)

def find_task(name):
    print('PID        COMM')
    for task in for_each_task(prog):
        pid = task.pid.value_()
        comm = task.comm.string_().decode()
        if comm == "ovs-vswitchd":
            print(f'{pid:<10} {comm}')
            return task

task = find_task("ovs-vswitchd")
fd_array = task.files.fd_array
print_files(fd_array)
