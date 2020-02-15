#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
from drgn import container_of
import socket

import subprocess
import drgn
import sys
import time

def ovs_pid():
    (status, output) = subprocess.getstatusoutput("pgrep ovs-vswitchd")

    if status:
        print("ovs is not started")
        sys.exit(1)

    return int(output)

prog = drgn.program_from_pid(ovs_pid())

print("monitor_running: %d" % prog['monitor_running'])
print("monitor_tid: %d" % prog['monitor_running'])
print("n_revalidators: %d" % prog['n_revalidators'])
print("n_handlers: %d" % prog['n_handlers'])