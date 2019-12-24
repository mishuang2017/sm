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
    print("portid: %x" % sock.portid)
#     print("dst_portid: %x" % sock.dst_portid)
#     print("flags: %x" % sock.flags)

print('PID        COMM')
for task in for_each_task(prog):
    pid = task.pid.value_()
    comm = task.comm.string_().decode()
    if comm == "ovs-vswitchd":
        print(f'{pid:<10} {comm}')
        fd_array = task.files.fd_array
        for i in range(64):
            file = fd_array[i]
            if file and socket_file_ops == file.f_op.value_():
                socket = Object(prog, "struct socket", address=file.private_data)
                if netlink_ops == socket.ops.value_():
                    sock = socket.sk
                    netlink_sock = cast('struct netlink_sock *', sock)
                    print_netlink_sock(netlink_sock)
