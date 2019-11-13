#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import container_of
from drgn import Object

import socket
import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
import lib

mlx5e_priv = lib.get_mlx5_pf0()

# struct mlx5_esw_offload
offloads = mlx5e_priv.mdev.priv.eswitch.offloads

# ofed 4.6
mod_hdr_tbl = offloads.mod_hdr_tbl

# ofed 4.7
# mod_hdr_tbl = offloads.mod_hdr.hlist

field_name = {
    0x1: "OUT_SMAC_47_16",
    0x2: "OUT_SMAC_15_0",
    0x3: "OUT_ETHERTYPE",
    0x4: "OUT_DMAC_47_16",
    0x5: "OUT_DMAC_15_0",
    0x6: "OUT_IP_DSCP",
    0x7: "OUT_TCP_FLAGS",
    0x8: "OUT_TCP_SPORT",
    0x9: "OUT_TCP_DPORT",
    0xA: "OUT_IPV4_TTL",
    0xB: "OUT_UDP_SPORT",
    0xC: "OUT_UDP_DPORT",
    0xD: "OUT_SIPV6_127_96",
    0xE: "OUT_SIPV6_95_64",
    0xF: "OUT_SIPV6_63_32",
    0x10: "OUT_SIPV6_31_0",
    0x11: "OUT_DIPV6_127_96",
    0x12: "OUT_DIPV6_95_64",
    0x13: "OUT_DIPV6_63_32",
    0x14: "OUT_DIPV6_31_0",
    0x15: "OUT_SIPV4",
    0x16: "OUT_DIPV4",
    0x31: "IN_SMAC_47_16",
    0x32: "IN_SMAC_15_0",
    0x33: "IN_ETHERTYPE",
    0x34: "IN_DMAC_47_16",
    0x35: "IN_DMAC_15_0",
    0x36: "IN_IP_DSCP",
    0x37: "IN_TCP_FLAGS",
    0x38: "IN_TCP_SPORT",
    0x39: "IN_TCP_DPORT",
    0x3A: "IN_IPV4_TTL",
    0x3B: "IN_UDP_SPORT",
    0x3C: "IN_UDP_DPORT",
    0x3D: "IN_SIPV6_127_96",
    0x3E: "IN_SIPV6_95_64",
    0x3F: "IN_SIPV6_63_32",
    0x40: "IN_SIPV6_31_0",
    0x41: "IN_DIPV6_127_96",
    0x42: "IN_DIPV6_95_64",
    0x43: "IN_DIPV6_63_32",
    0x44: "IN_DIPV6_31_0",
    0x45: "IN_SIPV4",
    0x46: "IN_DIPV4",
    0x47: "OUT_IPV6_HOPLIMIT",
    0x48: "IN_IPV6_HOPLIMIT",
    0x49: "METADATA_REG_A",
    0x50: "METADATA_REG_B",
    0x51: "METADATA_REG_C_0",
    0x52: "METADATA_REG_C_1",
    0x53: "METADATA_REG_C_2",
    0x54: "METADATA_REG_C_3",
    0x55: "METADATA_REG_C_4",
    0x56: "METADATA_REG_C_5",
    0x57: "METADATA_REG_C_6",
    0x58: "METADATA_REG_C_7",
    0x59: "OUT_TCP_SEQ_NUM",
    0x5A: "IN_TCP_SEQ_NUM",
    0x5B: "OUT_TCP_ACK_NUM",
    0x5C: "IN_TCP_ACK_NUM"
}

def parse_pedit(l, h):
    print("%lx" % l)
    print("%lx" % h)
    action_type = (l & 0xf0000000) >> 28
    field = (l & 0xfff0000) >> 16
    offset = (l & 0x1f00) >> 8
    print("action_type: %x, field: %2x, name: %-15s, offset: %d" % \
        (action_type, field, field_name.get(field), offset))
    if field == 0x15 or field == 0x16:
        print("%s" % lib.ipv4(h))
    if field == 0x8 or field == 0x9:
        print("%x, %d" % (h, h))
    print("")

for i in range(256):
    node = mod_hdr_tbl[i].first
    while node.value_():
        obj = container_of(node, "struct mlx5e_mod_hdr_entry", "mod_hdr_hlist")
        print("mlx5e_mod_hdr_entry %lx" % obj.value_())
        mlx5e_mod_hdr_entry = Object(prog, 'struct mlx5e_mod_hdr_entry', address=obj.value_())
        print("mod_hdr_id %lx" % mlx5e_mod_hdr_entry.mod_hdr_id.value_())

        print(mlx5e_mod_hdr_entry.key)
        actions = mlx5e_mod_hdr_entry.key.actions
        num_actions = mlx5e_mod_hdr_entry.key.num_actions
#         print(actions)
        for j in range(num_actions):
            p = Object(prog, 'void *', address=actions.value_())
            p = p.value_()
            l = socket.ntohl(p & 0xffffffff)
            h = socket.ntohl((p & 0xffffffff00000000) >> 32)
            parse_pedit(l, h)
            actions = actions + 8

        node = node.next
        print("")
