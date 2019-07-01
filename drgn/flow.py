#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
from drgn import reinterpret
import time
import socket

import sys
import os

libpath = os.path.dirname(os.path.realpath(__file__))
sys.path.append(libpath)
import lib

def print_mac(mac):
    for i in range(6):
        v = (mac >> (5 - i) * 8) & 0xff
        print("%02x" % v, end='')
        if i < 5:
            print(":", end='')

def print_match(fte):
    val = fte.val
#     smac = str(socket.ntohl(hex(val[0])))
    print("%8x: " % fte.index.value_(), end='')
    smac_47_16 = socket.ntohl(val[0].value_())
    smac_15_0 = socket.ntohl(val[1].value_() & 0xffff)
    smac_47_16 <<= 16
    smac_15_0 >>= 16
    smac = smac_47_16 | smac_15_0
    print(" s: ", end='')
    print_mac(smac)

    dmac_47_16 = socket.ntohl(val[2].value_())
    dmac_15_0 = socket.ntohl(val[3].value_() & 0xffff)
    dmac_47_16 <<= 16
    dmac_15_0 >>= 16
    dmac = dmac_47_16 | dmac_15_0
    print(" d: ", end='')
    print_mac(dmac)

    ethertype = socket.ntohl(val[1].value_() & 0xffff0000)
    if ethertype:
        print(" et: %x" % ethertype, end='')

    vport = socket.ntohl(val[17].value_() & 0xffff0000)
    if vport:
        print(" vport: %4x" % vport, end='')

    ip_protocol = val[4].value_() & 0xff
    if ip_protocol:
        print(" ip: %-2d" % ip_protocol, end='')

    tcp_flags = (val[4].value_() & 0xff000000) >> 24
    if tcp_flags:
        print(" tflags: %2x" % tcp_flags, end='')

    ip_version = (val[4].value_() & 0xff0000) >> 17
    if ip_version:
        print(" ipv: %-2x" % ip_version, end='')

#     print("\n  ", end='')

    tcp_sport = socket.ntohs(val[5].value_() & 0xffff)
    if tcp_sport:
        print(" sport: %5d" % tcp_sport, end='')

    tcp_dport = socket.ntohs(val[5].value_() >> 16 & 0xffff)
    if tcp_dport:
        print(" dport: %6d" % tcp_dport, end='')

    udp_sport = socket.ntohs(val[7].value_() & 0xffff)
    if udp_sport:
        print(" sport: %6d" % udp_sport, end='')

    udp_dport = socket.ntohs(val[7].value_() >> 16 & 0xffff)
    if udp_dport:
        print(" dport: %6d" % udp_dport, end='')

    src_ip = socket.ntohl(val[11].value_())
    if src_ip:
        print(" src_ip: %12s" % lib.ipv4(src_ip), end='')

    dst_ip = socket.ntohl(val[15].value_())
    if src_ip:
        print(" dst_ip: %12s" % lib.ipv4(dst_ip), end='')

    vni = socket.ntohl(val[21].value_() & 0xffffff) >> 8
    if vni:
        print(" vni: %6d" % vni, end='')

    source_sqn = socket.ntohl(val[16].value_() & 0xffffff00)
    if source_sqn:
        print(" source_sqn: %6x" % source_sqn, end='')

    if vni:
        smac_47_16 = socket.ntohl(val[32].value_())
        smac_15_0 = socket.ntohl(val[33].value_() & 0xffff)
        smac_47_16 <<= 16
        smac_15_0 >>= 16
        smac = smac_47_16 | smac_15_0
        print("\n           s: ", end='')
        print_mac(smac)

        dmac_47_16 = socket.ntohl(val[34].value_())
        dmac_15_0 = socket.ntohl(val[35].value_() & 0xffff)
        dmac_47_16 <<= 16
        dmac_15_0 >>= 16
        dmac = dmac_47_16 | dmac_15_0
        print(" d: ", end='')
        print_mac(dmac)

        ethertype = socket.ntohl(val[33].value_() & 0xffff0000)
        print(" et: %x" % ethertype, end='')

    print(" action %4x: " % fte.action.action.value_())

def print_dest(rule):
    if prog['MLX5_FLOW_DESTINATION_TYPE_COUNTER'] == rule.dest_attr.type:
        return
    if prog['MLX5_FLOW_DESTINATION_TYPE_VPORT'] == rule.dest_attr.type:
        print("\t\tdest: vport: %x" % rule.dest_attr.vport.num)
        return
    if prog['MLX5_FLOW_DESTINATION_TYPE_TIR'] == rule.dest_attr.type:
        print("\t\tdest: tir_num: %x" % rule.dest_attr.tir_num)
        return
    else:
        print(rule)

def flow(flow):
#     print("flow table address")
#     print("%lx" % flow.value_())
    fs_node = Object(prog, 'struct fs_node', address=flow.value_())
#     print("%lx" % fs_node.address_of_())
#     print(fs_node)
    group_addr = fs_node.address_of_()
#     print("fs_node address")
#     print("%lx" % group_addr.value_())
    group_addr = fs_node.children.address_of_()
#     print(group_addr)
    for group in list_for_each_entry('struct fs_node', group_addr, 'list'):
        fte_addr = group.children.address_of_()
        for fte in list_for_each_entry('struct fs_node', fte_addr, 'list'):
            fs_fte = Object(prog, 'struct fs_fte', address=fte.value_())
            print_match(fs_fte)
            dest_addr = fte.children.address_of_()
            for dest in list_for_each_entry('struct fs_node', dest_addr, 'list'):
                rule = Object(prog, 'struct mlx5_flow_rule', address=dest.value_())
                print_dest(rule)

mlx5e_priv = lib.get_mlx5_pf0()
mlx5_eswitch_fdb = mlx5e_priv.mdev.priv.eswitch.fdb_table

for i in range(4):
    for j in range(17):
        for k in range(2):
            num_rules = mlx5_eswitch_fdb.offloads.fdb_prio[i][j][k].num_rules
            if num_rules:
                print("")
                print(i, j, k, num_rules);
                fdb = mlx5_eswitch_fdb.offloads.fdb_prio[i][j][k].fdb
                print("flow table id: %x leve: %x" % (fdb.id.value_(), fdb.level.value_()))
                flow(fdb)

# slow_fdb = mlx5e_priv.mdev.priv.eswitch.fdb_table.offloads.slow_fdb
# print("\nflow table id: %x leve: %x" % (slow_fdb.id.value_(), slow_fdb.level.value_()))
# flow(slow_fdb)
# 
# vport_to_tir = mlx5e_priv.mdev.priv.eswitch.offloads.ft_offloads
# print("\nflow table id: %x leve: %x" % (vport_to_tir.id.value_(), vport_to_tir.level.value_()))
# flow(vport_to_tir)
