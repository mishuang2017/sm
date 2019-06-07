from drgn.helpers.linux import *
from drgn import Object
from drgn import container_of
import socket

def ipv4(addr):
    ip = ""
    for i in range(4):
        v = (addr >> (3 - i) * 8) & 0xff
        ip += str(v)
        if i < 3:
            ip += "."
    return ip

def mac(m):
    s = ""
    for i in range(6):
        s += ("%02x" % m[i].value_())
        if i < 5:
            s += ":"
    return s

def print_nf_conntrack_tuple(tuple):
    print("src: %s" % ipv4(socket.ntohl(tuple.src.u3.ip.value_())))
    print("dst: %s" % ipv4(socket.ntohl(tuple.dst.u3.ip.value_())))

def print_mlx5e_ct_tuple(t, k):
    print("%d: ipv4: %s" % (k, ipv4(socket.ntohl(t.ipv4.value_()))))
    print("%d: zone: %d" % (k, t.zone.id))
    print("%d: nat: 0x%lx" % (k, t.nat))
    print_nf_conntrack_tuple(t.tuple)
    print('')

#define TCA_FLOWER_KEY_CT_FLAGS_NEW               0x01
#define TCA_FLOWER_KEY_CT_FLAGS_ESTABLISHED       0x02
#define TCA_FLOWER_KEY_CT_FLAGS_RELATED           0x04
#define TCA_FLOWER_KEY_CT_FLAGS_REPLY_DIR         0x08
#define TCA_FLOWER_KEY_CT_FLAGS_INVALID           0x10
#define TCA_FLOWER_KEY_CT_FLAGS_TRACKED           0x20
#define TCA_FLOWER_KEY_CT_FLAGS_SRC_NAT           0x40
#define TCA_FLOWER_KEY_CT_FLAGS_DST_NAT           0x80

def print_exts(prog, e):
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
                ip_tunnel_key = tun.params.tcft_enc_metadata.u.tun_info.key
                print("TCA_TUNNEL_KEY_ACT_SET")
                print("tun_id: 0x%x" % ip_tunnel_key.tun_id.value_())
                print("src ip: %s" % ipv4(socket.ntohl(ip_tunnel_key.u.ipv4.src.value_())))
                print("dst ip: %s" % ipv4(socket.ntohl(ip_tunnel_key.u.ipv4.dst.value_())))

def print_cls_fl_filter(prog, f):
    k = f.mkey
    print("ct_state: 0x%x" % k.ct_state.value_())
    print("ct_zone: %d" % k.ct_zone.value_())
    print("ct_mark: 0x%x" % k.ct_mark.value_())
    print("ct_labels[0] %x: " % k.ct_labels[0].value_())
    print("protocol: %x" % socket.ntohs(k.basic.n_proto))
    print("dmac: %s" % mac(k.eth.dst))
    print("smac: %s" % mac(k.eth.src))
    if k.ipv4.src:
        print("src ip: ", end='')
        print(ipv4(socket.ntohl(k.ipv4.src.value_())))
    if k.ipv4.dst:
        print("dst ip: ", end='')
        print(ipv4(socket.ntohl(k.ipv4.dst.value_())))

    print_exts(prog, f.exts)

def get_netdevs(prog):
    devs = []
    dev_base_head = prog['init_net'].dev_base_head.address_of_()
    for dev in list_for_each_entry('struct net_device', dev_base_head, 'dev_list'):
        devs.append(dev)
    return devs

def get_mlx5(prog, dev):
    mlx5e_priv_addr = dev.value_() + prog.type('struct net_device').size
    mlx5e_priv = Object(prog, 'struct mlx5e_priv', address=mlx5e_priv_addr)
    return mlx5e_priv

def get_mlx5_pf0(prog):
    for x, dev in enumerate(get_netdevs(prog)):
        name = dev.name.string_().decode()
        if name == "enp4s0f0":
            mlx5e_priv = get_mlx5(prog, dev)
    return mlx5e_priv

def get_mlx5e_rep_priv(prog):
    mlx5e_priv = get_mlx5_pf0(prog)

    # struct mlx5_esw_offload
    offloads = mlx5e_priv.mdev.priv.eswitch.offloads

    # struct mlx5_eswitch_rep
    vport = offloads.vport_reps

    # struct mlx5_eswitch_rep_if
    rep_if = vport.rep_if

    # struct mlx5e_rep_priv
    priv = rep_if[prog['REP_ETH']].priv
    mlx5e_rep_priv = Object(prog, 'struct mlx5e_rep_priv', address=priv.value_())
    return mlx5e_rep_priv

def hash(rhashtable, type, member):
    nodes = []

    tbl = rhashtable.tbl

    buckets = tbl.buckets
    size = tbl.size.value_()

    for i in range(size):
        rhash_head = buckets[i]
        while True:
            if rhash_head.value_() & 1:
                break;
            obj = container_of(rhash_head, type, member)
            nodes.append(obj)
            rhash_head = rhash_head.next

    return nodes