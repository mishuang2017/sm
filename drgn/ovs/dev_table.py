#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
from drgn import cast
import subprocess
from socket import ntohl
from socket import ntohs
import time
import sys
import os

sys.path.append("..")
import lib

(status, output) = subprocess.getstatusoutput("grep -w dev_table /proc/kallsyms | grep openvswitch | awk '{print $1}'")
print("%d, %s" % (status, output))

if status:
    sys.exit(1)

t = int(output, 16)
p = Object(prog, 'struct hlist_head *', address=t)

for i in range(1024):
    for vport in hlist_for_each_entry('struct vport', p, 'hash_node'):
        name = vport.dev.name.string_().decode()
        port_no = vport.port_no
        upcall_portids = vport.upcall_portids
        ids = upcall_portids.ids
        id = ids[0].value_()
        print("name: %10s,  n_ids: %d, id: %x, %d" % (name, upcall_portids.n_ids, id, id))
        print("vport %lx" % vport)
        print("datapath %lx" % vport.dp)
        print("vport_portids %lx" % upcall_portids)
        print("portid[0] %lx, %d" % (id, id))
        print("vport_no %d" % port_no)
        print("")
    p = p + 1

table = vport.dp.table
# print(table)
ufid_count = table.count.value_()
ufid_ti = table.ufid_ti
print("ufid_count: %d" % ufid_count)
# print(ufid_ti)
buckets = ufid_ti.buckets
# print(buckets)

n_buckets = ufid_ti.n_buckets.value_()
node_ver = ufid_ti.node_ver.value_()
print("n_buckets: %d, node_ver: %d" % (n_buckets, node_ver))

def print_mac(mac):
    a = ("%02x:%02x:%02x:%02x:%02x:%02x") % (mac[0], mac[1], mac[2], mac[3], mac[4], mac[5])
    return a

def print_eth(eth):
    print("eth: ", end='')
    type = eth.type
    print("type: %4x, src: %s, dst: %s" % (ntohs(type), print_mac(eth.src), print_mac(eth.dst)))

def print_flow_key(key):
#     MAC_PROTO_ETHERNET = 1
#     mac_proto = key.mac_proto
#     print(mac_proto)
    print("recird_id: 0x%-3x" % key.recirc_id, end='\t')
    print_eth(key.eth)
    proto = key.ip.proto.value_()
    print("proto: %d, src: %s" % (proto, lib.ipv4(ntohl(key.ipv4.addr.src.value_()))))
    tp_dst = key.tp.dst
    print("tp_dst: %d" % ntohs(tp_dst))

def print_ovs_conntrack_info(info):
    print("zone: %d, nf_conn %lx" % (info.zone.id, info.ct))

def print_flow_act(acts):
#     print(acts)
#     return
    nlattr = acts.actions[0]
#     print(nlattr)
    nla_type = nlattr.nla_type
#     print("nla_type: %d" % nla_type)
    actions_len = acts.actions_len
    actions_addr = acts.actions.address_of_()
    NLA_HDRLEN = prog.type('struct nlattr').size
    ovs_conntrack_info__len = prog.type('struct ovs_conntrack_info').size
    print("\tactions_len: %d, actions: %lx" % (actions_len, actions_addr))

    remaining = actions_len
    while remaining > 0:
#         print("remaining: %d" % remaining)
#         time.sleep(1)
        if nla_type == prog['OVS_ACTION_ATTR_OUTPUT']:  # 1
            addr = nlattr.address_of_().value_() + NLA_HDRLEN
            port = Object(prog, 'int', address=addr)
            print("\tOVS_ACTION_ATTR_OUTPUT: %d" % port)
            remaining -= (NLA_HDRLEN + 4)
        elif nla_type == prog['OVS_ACTION_ATTR_CT']:  # 12
            print("\tOVS_ACTION_ATTR_CT:", end=' ')
#             print(nlattr)
            addr = nlattr.address_of_().value_() + NLA_HDRLEN
            ovs_conntrack_info = Object(prog, 'struct ovs_conntrack_info', address=addr)
            print_ovs_conntrack_info(ovs_conntrack_info)

            addr += (ovs_conntrack_info__len)
            nlattr = Object(prog, 'struct nlattr', address=addr)
            nla_type = nlattr.nla_type
            remaining -= (NLA_HDRLEN + ovs_conntrack_info__len)
        elif nla_type == prog['OVS_ACTION_ATTR_RECIRC']:  # 7
            addr = nlattr.address_of_().value_() + NLA_HDRLEN
            recirc_id = Object(prog, 'int', address=addr)
            print("\tOVS_ACTION_ATTR_RECIRC: %d" % recirc_id)
            remaining -= (NLA_HDRLEN + 4)
        elif nla_type == prog['OVS_ACTION_ATTR_SAMPLE']:  # 7
            print(nlattr)
            sample_len = nlattr.nla_len.value_()
            print("\tsample_len: %d" % sample_len)
            act_addr = acts.actions.address_of_().value_() + 4
            nlattr = Object(prog, 'struct nlattr', address=act_addr)
            arg_len = nlattr.nla_len.value_()
            print("\targ_len: %d" % arg_len)

            if nlattr.nla_type == prog['OVS_SAMPLE_ATTR_ARG']: # 4
                act_addr = act_addr + NLA_HDRLEN + 4 # 4 for bool exec
                probability = Object(prog, 'u32', address=act_addr)
                print("\tprobability: %x, %.2f" % (probability, probability.value_() / 4294967295))
            act_addr = acts.actions.address_of_().value_() + sample_len
            nlattr = Object(prog, 'struct nlattr', address=act_addr)
            nla_type = nlattr.nla_type
            remaining -= sample_len
            print(nlattr)
        else:
            print(nlattr)
            break

def print_flow_stat(stat):
    print("\tpacket_count: %d" % stat[0].packet_count)

for i in range(n_buckets):
    for flow in hlist_for_each_entry('struct sw_flow', ufid_ti.buckets[i].address_of_(), 'ufid_table'):
        print_flow_key(flow.key)
        print_flow_act(flow.sf_acts)
        print_flow_stat(flow.stats)
        print("")
