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

print('')
print("ovs_datapath_family: %2d, used for revalidator,      kenrel function ovs_dp_cmd_new" % prog['ovs_datapath_family'])
print("ovs_vport_family:    %2d" % prog['ovs_vport_family'])
print("ovs_flow_family:     %2d, used for install dp flows, kernel function ovs_flow_cmd_new" % prog['ovs_flow_family'])
print("ovs_packet_family:   %2d, used for receive upcall,   kernel function queue_userspace_packet" % prog['ovs_packet_family'])
print("ovs_vport_mcgroup:   %2d" % prog['ovs_vport_mcgroup'])
print("ovs_meter_family:    %2d" % prog['ovs_meter_family'])
print("ovs_ct_limit_family: %2d" % prog['ovs_ct_limit_family'])

print("psample_mcgroup:     %2d" % prog['psample_mcgroup'])

print("next_id:             %2d" % prog['next_id'])
