#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import socket

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
                print("snat ip: %s" % ipv4(socket.ntohl(tcf_conntrack_info.range.min_addr.ip.value_())))
        if kind == "pedit":
            tcf_pedit = Object(prog, 'struct tcf_pedit', address=a.value_())
#             print("%lx" % a.value_())
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
        if kind == "tunnel_key":
            tun = Object(prog, 'struct tcf_tunnel_key', address=a.value_())
            if tun.params.tcft_action == 1:
                print("TCA_TUNNEL_KEY_ACT_SET")
                print("tun_id: 0x%x" % tun.params.tcft_enc_metadata.u.tun_info.key.tun_id.value_())
                print("src ip: %s" % ipv4(socket.ntohl(tun.params.tcft_enc_metadata.u.tun_info.key.u.ipv4.src.value_())))
                print("dst ip: %s" % ipv4(socket.ntohl(tun.params.tcft_enc_metadata.u.tun_info.key.u.ipv4.dst.value_())))

def ipv4(addr):
    ip=""
    for i in range(4):
        v = (addr >> (3 - i) * 8) & 0xff
        ip+=str(v)
        if i < 3:
            ip+="."
    return ip

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
        print(ipv4(socket.ntohl(k.ipv4.src.value_())))
    if k.ipv4.dst:
        print("dst ip: ", end='')
        print(ipv4(socket.ntohl(k.ipv4.dst.value_())))

    print_exts(f.exts)

def print_ct_tuples(t, k):
    print("%d: ipv4: 0x%x" % (k, t.ipv4))
    print("%d: zone: %d" % (k, t.zone.id))
    print("%d: nat: 0x%lx" % (k, t.nat))
#     print("tuple: ", t.tuple)

dev_base_head = prog['init_net'].dev_base_head.address_of_()

for dev in list_for_each_entry('struct net_device', dev_base_head,
                               'dev_list'):
    name = dev.name.string_().decode()
    addr = dev.value_()
    if "enp4s0f0" not in name and "vxlan_sys_4789" != name:
        continue
    print("%20s" % name, end='')
    print("%20x" % addr)
    print('')

    ingress_queue = dev.ingress_queue
    if ingress_queue.value_() == 0:
        continue
    qdisc = ingress_queue.qdisc
    qdisc_size = prog.type('struct Qdisc').size

#     print("%lx" % qdisc.value_())
    addr = qdisc.value_() + qdisc_size
    ingress_sched_data = Object(prog, 'struct ingress_sched_data', address=addr)
#     print(ingress_sched_data)
    block = ingress_sched_data.block
    if block.value_() == 0:
        continue
#     print(block)
    chain_list_addr = block.chain_list.address_of_()
    for chain in list_for_each_entry('struct tcf_chain', chain_list_addr, 'list'):
        print("chain index: %d, 0x%x" % (chain.index, chain.index))
        tcf_proto = chain.filter_chain
        while True:
#             print(tcf_proto)
            head = Object(prog, 'struct cls_fl_head', address=tcf_proto.root.value_())
#             print(head)
            for node in radix_tree_for_each(head.handle_idr.idr_rt):
#                 print("%lx" % node[1].value_())
                f = Object(prog, 'struct cls_fl_filter', address=node[1].value_())
                print_cls_fl_filter(f)
                print("==========================================\n")
            tcf_proto = tcf_proto.next
            if tcf_proto.value_() == 0:
                break
