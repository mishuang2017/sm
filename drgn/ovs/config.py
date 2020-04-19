#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
from drgn import container_of
import socket

import subprocess
import drgn
import sys
import time

sys.path.append(".")
from lib_ovs import *

print("monitor_running: %d" % prog['monitor_running'])
print("monitor_tid: %d" % prog['monitor_running'])
print("n_revalidators: %d" % prog['n_revalidators'])
print("n_handlers: %d" % prog['n_handlers'])
