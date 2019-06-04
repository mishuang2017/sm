#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
from drgn import reinterpret
import time
import socket

dev_base_head = prog['init_net'].dev_base_head.address_of_()
# print(f'&init_net->dev_base_head is {dev_base_head}')

def print_mac(mac):
    for i in range(6):
        v = (mac >> (5 - i) * 8) & 0xff
        print("%02x" % v, end='')
        if i < 5:
            print(":", end='')

def print_match(fte):
    val = fte.val
#     smac = str(socket.ntohl(hex(val[0])))
    print("%x: " % fte.index.value_(), end='')
    smac_47_16 = socket.ntohl(val[0].value_())
    smac_15_0 = socket.ntohl(val[1].value_() & 0x0000ffff)
    smac_47_16 <<= 16
    smac_15_0 >>= 16
    smac = smac_47_16 | smac_15_0
    print("smac: ", end='')
    print_mac(smac)
    print(" ", end='')

    dmac_47_16 = socket.ntohl(val[2].value_())
    dmac_15_0 = socket.ntohl(val[3].value_() & 0x0000ffff)
    dmac_47_16 <<= 16
    dmac_15_0 >>= 16
    dmac = dmac_47_16 | dmac_15_0
    print("dmac: ", end='')
    print_mac(dmac)

    ethertype = socket.ntohl(val[1].value_() & 0xffff0000)
    print(" ethertype: %x" % ethertype, end='')

    vport = socket.ntohl(val[1].value_() & 0xffff0000)
    print(" vport: %x" % val[17], end='')

    print("")


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

for dev in list_for_each_entry('struct net_device', dev_base_head, 'dev_list'):
    name = dev.name.string_().decode()
    if name == "enp4s0f0":
        print(dev.name)
        size = prog.type('struct net_device').size
#         print("%lx" % size)
        mlx5e_priv_addr = dev.value_() + size
#         print("%lx" % mlx5e_priv_addr)
        mlx5e_priv = Object(prog, 'struct mlx5e_priv', address=mlx5e_priv_addr)
        mlx5_eswitch_fdb = mlx5e_priv.mdev.priv.eswitch.fdb_table
        for i in range(4):
            for j in range(17):
                for k in range(2):
                    num_rules = mlx5_eswitch_fdb.offloads.fdb_prio[i][j][k].num_rules
                    if num_rules:
                        print(i, j, k, num_rules);
                        fdb = mlx5_eswitch_fdb.offloads.fdb_prio[i][j][k].fdb
                        print("id: %x" % fdb.id.value_())
                        flow(fdb)



