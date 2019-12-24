#!/usr/local/bin/drgn -k

from drgn.helpers.linux.pid import for_each_task
from drgn.helpers.linux import *
from drgn import Object
from drgn import container_of
from drgn import cast
import socket

import subprocess
import drgn
import sys
import time

socket_file_ops = prog['socket_file_ops'].address_of_().value_()
netlink_ops = prog['netlink_ops'].address_of_().value_()

def print_netlink_sock(sock):
    print("sock.sk_protocol: %d" % sock.sk.sk_protocol, end='')
    print("\tportid: %10x" % sock.portid, end='')
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

        socket = Object(prog, "struct socket", address=file.private_data)
        # only print netlink socket
        if netlink_ops != socket.ops.value_():
            continue

        sock = socket.sk
        netlink_sock = cast('struct netlink_sock *', sock)
        print_netlink_sock(netlink_sock)

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
