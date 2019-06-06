#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import socket

miniflow_list = []

for flow in list_for_each_entry('struct mlx5e_tc_flow', prog['ct_list'].address_of_(), 'nft_node'):
    print("mlx5e_tc_flow: %lx" % flow.value_())
    for mini in list_for_each_entry('struct mlx5e_miniflow', flow.miniflow_list.address_of_(), 'node'):
        mlx5e_miniflow_node = Object(prog, 'struct mlx5e_miniflow_node', address=mini.value_())
        miniflow = mlx5e_miniflow_node.miniflow
        print("mlx5e_miniflow: %lx" % miniflow)
        if miniflow not in miniflow_list:
            miniflow_list.append(miniflow)

def print_nf_conntrack_tuple(tuple):
    print("src: ", end='')
    print(tuple.src.u3.in6.in6_u.u6_addr8)
    print("dst: ", end='')
    print(tuple.dst.u3.in6.in6_u.u6_addr8)

def print_mac(m):
    for i in range(6):
        if i == 5:
            print("%02x" % m[i].value_(), end='')
        else:
            print("%02x:" % m[i].value_(), end='')

#define TCA_FLOWER_KEY_CT_FLAGS_NEW               0x01
#define TCA_FLOWER_KEY_CT_FLAGS_ESTABLISHED       0x02
#define TCA_FLOWER_KEY_CT_FLAGS_RELATED           0x04
#define TCA_FLOWER_KEY_CT_FLAGS_REPLY_DIR         0x08
#define TCA_FLOWER_KEY_CT_FLAGS_INVALID           0x10
#define TCA_FLOWER_KEY_CT_FLAGS_TRACKED           0x20
#define TCA_FLOWER_KEY_CT_FLAGS_SRC_NAT           0x40
#define TCA_FLOWER_KEY_CT_FLAGS_DST_NAT           0x80

def print_exts(e):
    print("\nnr_actions: %d" % e.nr_actions)
    for i in range(e.nr_actions):
        a = e.actions[i]
        kind = a.ops.kind.string_().decode()
        print('')
        print(kind)
        if kind == "ct":
#             print(a)
            tcf_conntrack_info = Object(prog, 'struct tcf_conntrack_info', address=a.value_())
            print("zone: %d" % tcf_conntrack_info.zone.value_())
            print("mark: 0x%x" % tcf_conntrack_info.mark.value_())
            print("labels[0]: 0x%x" % tcf_conntrack_info.labels[0].value_())
            print("commit: %d" % tcf_conntrack_info.commit.value_())
            print("nat: 0x%x" % tcf_conntrack_info.nat.value_())
            if tcf_conntrack_info.range.min_addr.ip:
                print("snat ip: ", tcf_conntrack_info.range.min_addr.in6.in6_u.u6_addr8)
        if kind == "pedit":
            tcf_pedit = Object(prog, 'struct tcf_pedit', address=a.value_())
            print("%lx" % a.value_())
            n = tcf_pedit.tcfp_nkeys
            print("tcf_pedit.tcfp_nkeys: %d" % n)
            for i in range(n):
                print(tcf_pedit.tcfp_keys_ex[i].htype)
                print("offset: %x" % tcf_pedit.tcfp_keys[i].off)
                print("mask:   %08x" % tcf_pedit.tcfp_keys[i].mask)
                print("value:  %08x" % tcf_pedit.tcfp_keys[i].val)
        if kind == "mirred":
            tcf_mirred = Object(prog, 'struct tcf_mirred', address=a.value_())
            print("output: %s" % tcf_mirred.tcfm_dev.name.string_().decode())
        if kind == "gact":
            print("recirc_id: 0x%x, %d" % (a.goto_chain.index, a.goto_chain.index))

def print_cls_fl_filter(f):
    k = f.mkey
    print("ct_state: 0x%x" % k.ct_state.value_())
    print("ct_zone: %d" % k.ct_zone.value_())
    print("ct_mark: 0x%x" % k.ct_mark.value_())
    print("ct_labels[0] %x: " % k.ct_labels[0].value_())
    print("protocol: %x" % socket.ntohs(k.basic.n_proto))
    print("dmac: ", end='')
    print_mac(k.eth.dst)
    print('')
    print("smac: ", end='')
    print_mac(k.eth.src)
    print('')
    if k.ipv4.src:
        print("src ip: ", end='')
        print(k.ipv6.src.in6_u.u6_addr8)
    if k.ipv4.dst:
        print("dst ip: ", end='')
        print(k.ipv6.dst.in6_u.u6_addr8)

    print_exts(f.exts)

def print_ct_tuples(t, k):
    print("%d: ipv4: 0x%x" % (k, t.ipv4))
    print("%d: zone: %d" % (k, t.zone.id))
    print("%d: nat: 0x%lx" % (k, t.nat))
#     print("tuple: ", t.tuple)

for i in miniflow_list:
    name = i.priv.netdev.name.string_().decode()
#     print(i.nr_flows)
#     print("cookie: %lx" % i.cookie)     # pointer of skb
#     print('{0}'.format(i.tuple))

    if name == "enp4s0f0_1" or name == "enp4s0f0":
#     if name == "enp4s0f0_1":
        for j in range(8):
            flow = i.path.flows[j]
            if flow:
                print(name, j)
                attr = flow.esw_attr[0]
                print("action: %4x, chain: %d" % (attr.action, attr.chain))
                print('')

        for j in range(8):
            flow = i.path.cookies[j]
            if flow:
                addr = flow.value_()
                if (addr & 1):
                    print("=========== %d %s %s ==========" % (j, name, "nf_conntrack_tuple"))
                    addr = flow.value_() & ~0x1
                    nf_conntrack_tuple = Object(prog, 'struct nf_conntrack_tuple', address=addr)
                    print_nf_conntrack_tuple(nf_conntrack_tuple)
                else:
                    print("=========== %d %s %s ==========" % (j, name, "cls_fl_filter"))
                    cls_fl_filter = Object(prog, 'struct cls_fl_filter', address=addr)
                    print_cls_fl_filter(cls_fl_filter)


        n = i.nr_ct_tuples
        print("\nnr_ct_tuples: %x" % n)
        for k in range(n):
            print_ct_tuples(i.ct_tuples[k], k)
        print("+++++++++++++++++++++ end ++++++++++++++++++++\n")
