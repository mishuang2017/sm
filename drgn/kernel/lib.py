from drgn.helpers.linux import *
from drgn import container_of
from drgn import Object
from drgn import cast
import socket
import os

import subprocess
import drgn

prog = drgn.program_from_kernel()
# prog = drgn.program_from_core_dump("/var/crash/vmcore.0")

pf0_name = "ens1f0"
pf1_name = "ens1f1"

def kernel(name):
    b = os.popen('uname -r')
    text = b.read()
    b.close()

#     print("uname -r: %s" % text)

    if name in text:
        return True
    else:
        return False

pf0_name = "enp4s0f0"
if kernel("5.6.0-rc7+"):
    pf0_name = "enp4s0f0np0"
pf1_name = "enp4s0f1"

import os

def name_to_address(name):
    (status, output) = subprocess.getstatusoutput("grep -w " + name + " /proc/kallsyms | awk '{print $1}'")
    print("%d, %s" % (status, output))

    if status:
        return 0

    t = int(output, 16)
    p = Object(prog, 'void *', address=t)

    return p.value_()

# hex returns type str
def address_to_name(address):
#     print(type(address))
    if address == "0x0":
        return "0x0"
#     print("address: %s" % address)
    (status, output) = subprocess.getstatusoutput("grep " + address.replace("0x", "") + " /proc/kallsyms | awk '{print $3}'")
#     print("%d, %s" % (status, output))

    if status:
        return ""

    return output

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
    print("src ip  : %s" % ipv4(socket.ntohl(tuple.src.u3.ip.value_())))
    print("src port: %d" % socket.ntohs(tuple.src.u.all.value_()))
    print("dst ip  : %s" % ipv4(socket.ntohl(tuple.dst.u3.ip.value_())))
    print("dst port: %d" % socket.ntohs(tuple.dst.u.all.value_()))

def print_mlx5e_ct_tuple(k, tuple):
    print("\n=== mlx5e_ct_tuple start ===")
    print("%d: ipv4: %s" % (k, ipv4(socket.ntohl(tuple.ipv4.value_()))))
    print("%d: zone: %d" % (k, tuple.zone.id))
    print("%d: nat: 0x%lx" % (k, tuple.nat))
    print("%d: mlx5e_tc_flow %lx, refcnt: %d" % (k, tuple.flow, tuple.flow.refcnt.refs.counter.value_()))
    print_nf_conntrack_tuple(tuple.tuple)
    print("=== mlx5_ct_tuple end ===\n")

#define TCA_FLOWER_KEY_CT_FLAGS_NEW               0x01
#define TCA_FLOWER_KEY_CT_FLAGS_ESTABLISHED       0x02
#define TCA_FLOWER_KEY_CT_FLAGS_RELATED           0x04
#define TCA_FLOWER_KEY_CT_FLAGS_REPLY_DIR         0x08
#define TCA_FLOWER_KEY_CT_FLAGS_INVALID           0x10
#define TCA_FLOWER_KEY_CT_FLAGS_TRACKED           0x20
#define TCA_FLOWER_KEY_CT_FLAGS_SRC_NAT           0x40
#define TCA_FLOWER_KEY_CT_FLAGS_DST_NAT           0x80

def print_action_stats(a):
    bytes = 0
    packets = 0
    if a.cpu_bstats.value_():
        for cpu in for_each_online_cpu(prog):
            bstats = per_cpu_ptr(a.cpu_bstats, cpu).bstats
            bytes += bstats.bytes
            packets += bstats.packets
        print("\tpercpu bytes: %d, packets: %d" % (bytes, packets))
    else:
        bstats = a.tcfa_bstats
        bytes += bstats.bytes
        packets += bstats.packets
        print("\tbytes: %d, packets: %d" % (bytes, packets))

    bytes = 0
    packets = 0

#     if a.cpu_bstats_hw.value_():
#         for cpu in for_each_online_cpu(prog):
#             bstats = per_cpu_ptr(a.cpu_bstats_hw, cpu).bstats
#             bytes += bstats.bytes
#             packets += bstats.packets
#         print("hw percpu bytes: %d, packets: %d" % (bytes, packets))
#     else:
#         bstats = a.tcfa_bstats_hw
#         bytes += bstats.bytes
#         packets += bstats.packets
#         print("hw bytes: %d, packets: %d" % (bytes, packets))
 
def print_exts(e):
    print("\nnr_actions: %d" % e.nr_actions)
    for i in range(e.nr_actions):
        a = e.actions[i]
        kind = a.ops.kind.string_().decode()
        print("action %d: %10s: tc_action %lx" % (i+1, kind, a.value_()), end='')
#         print(a.cpu_bstats_hw)
        if kind == "ct":
#             print(a)
#             tcf_conntrack_info = Object(prog, 'struct tcf_conntrack_info', address=a.value_())
#             print("\tzone: %d" % tcf_conntrack_info.zone.value_(), end='')
#             print("\tmark: 0x%x" % tcf_conntrack_info.mark.value_(), end='')
#             print("\tlabels[0]: 0x%x" % tcf_conntrack_info.labels[0].value_(), end='')
#             print("\tcommit: %d" % tcf_conntrack_info.commit.value_(), end='')
#             print("\tnat: 0x%x" % tcf_conntrack_info.nat.value_())
#             if tcf_conntrack_info.range.min_addr.ip:
#                 print("snat ip: %s" % ipv4(socket.ntohl(tcf_conntrack_info.range.min_addr.ip.value_())))
            tcf_ct = cast('struct tcf_ct *', a)
            print(tcf_ct.params)

        if kind == "pedit":
            tcf_pedit = Object(prog, 'struct tcf_pedit', address=a.value_())
#             print("%lx" % a.value_())
            n = tcf_pedit.tcfp_nkeys
            print("tcf_pedit.tcfp_nkeys: %d" % n)
            for i in range(n):
                print(tcf_pedit.tcfp_keys_ex[i].htype)
                print("\toffset: %x" % tcf_pedit.tcfp_keys[i].off)
                print("\tmask:   %08x" % tcf_pedit.tcfp_keys[i].mask)
                print("\tvalue:  %08x" % tcf_pedit.tcfp_keys[i].val)
        if kind == "mirred":
            tcf_mirred = Object(prog, 'struct tcf_mirred', address=a.value_())
            print("\toutput: %s" % tcf_mirred.tcfm_dev.name.string_().decode())
            print_action_stats(a)
        if kind == "gact":
            print("\ttcf_chain %lx" % a.goto_chain.value_(), end='')
            print("\trecirc_id: %d, 0x%x" % (a.goto_chain.index, a.goto_chain.index))
        if kind == "tunnel_key":
            tun = Object(prog, 'struct tcf_tunnel_key', address=a.value_())
            if tun.params.tcft_action == 1:
                ip_tunnel_key = tun.params.tcft_enc_metadata.u.tun_info.key
                print("\tTCA_TUNNEL_KEY_ACT_SET")
                print("\tip_tunnel_info: %x" % tun.params.tcft_enc_metadata.u.tun_info.address_of_().value_())
                print("\ttun_id: 0x%x" % ip_tunnel_key.tun_id.value_())
                print("\tsrc ip: %s" % ipv4(socket.ntohl(ip_tunnel_key.u.ipv4.src.value_())))
                print("\tdst ip: %s" % ipv4(socket.ntohl(ip_tunnel_key.u.ipv4.dst.value_())))
                print("\ttp_dst: %d" % socket.ntohs(ip_tunnel_key.tp_dst.value_()))
        if kind == "sample":
            tcf_sample = Object(prog, 'struct tcf_sample', address=a.value_())
            print(tcf_sample)
            print("\trate: %d" % tcf_sample.rate)
            print("\tpsample_group_num: %d" % tcf_sample.psample_group_num)

def print_cls_fl_filter(f):
    print("handle: 0x%x" % f.handle)
    k = f.mkey
    #define FLOW_DIS_IS_FRAGMENT    BIT(0)
    #define FLOW_DIS_FIRST_FRAG     BIT(1)
    # 1 means nofirstfrag
    # 3 means firstfrag
#     print("ip_flags: 0x%x" % k.control.flags)
#     print("ct_state: 0x%x" % k.ct_state.value_())
#     print("ct_zone: %d" % k.ct_zone.value_())
#     print("ct_mark: 0x%x" % k.ct_mark.value_())
#     print("ct_labels[0]: %x" % k.ct_labels[0].value_())
#     print("protocol: %x" % socket.ntohs(k.basic.n_proto))
#     print("dmac: %s" % mac(k.eth.dst))
#     print("smac: %s" % mac(k.eth.src))
#     if k.ipv4.src:
#         print("src ip: ", end='')
#         print(ipv4(socket.ntohl(k.ipv4.src.value_())))
#     if k.ipv4.dst:
#         print("dst ip: ", end='')
#         print(ipv4(socket.ntohl(k.ipv4.dst.value_())))
 
    print_exts(f.exts)

def get_netdevs():
    devs = []
    dev_base_head = prog['init_net'].dev_base_head.address_of_()
    for dev in list_for_each_entry('struct net_device', dev_base_head, 'dev_list'):
        devs.append(dev)
    return devs

def get_veth(veth_name):
    veths = []
    for x, dev in enumerate(get_netdevs()):
        name = dev.name.string_().decode()
        if name == veth_name:
            veth_addr = dev.value_() + prog.type('struct net_device').size
            veth = Object(prog, 'struct veth_priv', address=veth_addr)
            veths.append(veth)

            dev_peer = veth.peer
            veth_addr = dev_peer.value_() + prog.type('struct net_device').size
            veth = Object(prog, 'struct veth_priv', address=veth_addr)
            veths.append(veth)

    return veths

def get_veth_netdev(veth_name):
    devs = []
    for x, dev in enumerate(get_netdevs()):
        name = dev.name.string_().decode()
        if name == veth_name:
            veth_addr = dev.value_() + prog.type('struct net_device').size
            veth = Object(prog, 'struct veth_priv', address=veth_addr)
            devs.append(dev)

            dev_peer = veth.peer
            veth_addr = dev_peer.value_() + prog.type('struct net_device').size
            veth = Object(prog, 'struct veth_priv', address=veth_addr)
            devs.append(dev)

    return devs

def get_mlx5(dev):
    mlx5e_priv_addr = dev.value_() + prog.type('struct net_device').size
    mlx5e_priv = Object(prog, 'struct mlx5e_priv', address=mlx5e_priv_addr)
    return mlx5e_priv

def get_mlx5e_priv(n):
    for x, dev in enumerate(get_netdevs()):
        name = dev.name.string_().decode()
        if name == n:
            mlx5e_priv = get_mlx5(dev)
    return mlx5e_priv

def get_mlx5_pf0():
    for x, dev in enumerate(get_netdevs()):
        name = dev.name.string_().decode()
        if name == pf0_name:
            mlx5e_priv = get_mlx5(dev)
    return mlx5e_priv

def get_mlx5_pf1():
    for x, dev in enumerate(get_netdevs()):
        name = dev.name.string_().decode()
        if name == pf1_name:
            mlx5e_priv = get_mlx5(dev)
    return mlx5e_priv


def get_pf0_netdev():
    for x, dev in enumerate(get_netdevs()):
        name = dev.name.string_().decode()
        if name == pf0_name:
            return dev

def get_mlx5e_rep_priv():
    mlx5e_priv = get_mlx5_pf0()
    ppriv = mlx5e_priv.ppriv
    mlx5e_rep_priv = Object(prog, 'struct mlx5e_rep_priv', address=ppriv.value_())

    return mlx5e_rep_priv

def get_mlx5e_rep_priv2():
    mlx5e_priv = get_mlx5_pf0()

    # struct mlx5_esw_offload
    offloads = mlx5e_priv.mdev.priv.eswitch.offloads

    total_vports = mlx5e_priv.mdev.priv.eswitch.total_vports.value_()

#     print("total_vports: %d" % total_vports)

    # struct mlx5_eswitch_rep

    if kernel("4.20.16+") or kernel("4.20.0-rc1+"):
        mlx5_eswitch_rep = offloads.vport_reps[0]
    else:
        mlx5_eswitch_rep = offloads.vport_reps[total_vports - 1]

#     for i in range(total_vports):
#         print("%lx" % offloads.vport_reps[i].address_of_())
#     print("%lx" % vport.address_of_())

    # struct mlx5_eswitch_rep_if
    rep_if = mlx5_eswitch_rep.rep_if

    # struct mlx5e_rep_priv
    priv = rep_if[prog['REP_ETH']].priv

#     print("priv: %lx" % priv.value_())

    mlx5e_rep_priv = Object(prog, 'struct mlx5e_rep_priv', address=priv.value_())
    return mlx5e_rep_priv

def get_mlx5_ib_dev():
    mlx5e_priv = get_mlx5_pf0()

    # struct mlx5_esw_offload
    offloads = mlx5e_priv.mdev.priv.eswitch.offloads

    total_vports = mlx5e_priv.mdev.priv.eswitch.total_vports.value_()

#     print("total_vports: %d" % total_vports)

    # struct mlx5_eswitch_rep

    if kernel("4.20.16+") or kernel("4.20.0-rc1+"):
        mlx5_eswitch_rep = offloads.vport_reps[0]
    else:
        mlx5_eswitch_rep = offloads.vport_reps[total_vports - 1]

#     print(mlx5_eswitch_rep)

#     for i in range(total_vports):
#         print("%lx" % offloads.vport_reps[i].address_of_())
#     print("%lx" % vport.address_of_())

    # struct mlx5_eswitch_rep_if
    rep_if = mlx5_eswitch_rep.rep_if

    # struct mlx5e_rep_priv
    priv = rep_if[prog['REP_IB']].priv

#     print("priv: %lx" % priv.value_())

    mlx5_ib_dev = Object(prog, 'struct mlx5_ib_dev', address=priv.value_())
    return mlx5_ib_dev

def struct_exist(name):
    try:
        prog.type(name)
        return True
    except LookupError as x:
        return False

def hash(rhashtable, type, member):
    nodes = []

    tbl = rhashtable.tbl

#     print("rhashtable %lx" % rhashtable.address_of_())
#     print("bucket_table %lx" % tbl)
#     buckets = tbl.buckets
#     print("buckets %lx" % buckets.address_of_())

    buckets = tbl.buckets
    size = tbl.size.value_()

    print("")
    for i in range(size):
        rhash_head = buckets[i]
        if struct_exist("struct rhash_lock_head"):
            rhash_head = cast("struct rhash_head *", rhash_head)
            if rhash_head.value_() == 0:
                continue
        while True:
            if rhash_head.value_() & 1:
                break
            obj = container_of(rhash_head, type, member)
            nodes.append(obj)
            rhash_head = rhash_head.next

    return nodes

def print_mlx5_flow_handle(handle):
    print("\n=== mlx5_flow_handle start ===")
    num = handle.num_rules.value_()
    print("num_rules: %d" % (num))
    for i in range(num):
        print(handle.rule[i].dest_attr)
    print("=== mlx5_flow_handle end ===\n")

def print_mlx5_fc(fc):
    p = fc.lastpackets
    b = fc.lastbytes
    id = fc.id
    dummy = fc.dummy
    nr_dummies = fc.nr_dummies.counter.value_()
    cachepackets = fc.cache.packets
    cachebytes = fc.cache.bytes
    lastuse = fc.cache.lastuse
    print("mlx5_fc: %lx, id: %4x, dummy: %d, nr_dummy: %d, lastpackets: %-10ld, lastbytes: %-10ld, packets: %-10ld, bytes: %-10ld, lastuse: %-10ld" % (fc, id, dummy, nr_dummies, p, b, cachepackets, cachebytes, lastuse / 1000))
#     print(fc.cache)

def get_mlx5_core_devs():
    devs = {}

    bus_type = prog["pci_bus_type"]
    subsys_private = bus_type.p
    k_list = subsys_private.klist_devices.k_list

    for dev in list_for_each_entry('struct device_private', k_list.address_of_(), 'knode_bus.n_node'):
        addr = dev.value_()
        device_private = Object(prog, 'struct device_private', address=addr)
        device = device_private.device

        # struct pci_dev {
        #     struct device dev;
        # }
        pci_dev = container_of(device, "struct pci_dev", "dev")

        driver_data = device.driver_data
        mlx5_core = Object(prog, 'struct mlx5_core_dev', address=driver_data)
        driver = device.driver
        if driver_data.value_():
            name = driver.name.string_().decode()
            if name == "mlx5_core":
                pci_name = device.kobj.name.string_().decode()
                index = pci_name.split('.')[1]
                devs[int(index)] = mlx5_core

    return devs

def get_mlx5_core_dev(index):
    devs = get_mlx5_core_devs()
    return devs[index]

def parse_ct_status(status):
    IPS_EXPECTED = prog['IPS_EXPECTED'].value_()
    IPS_SEEN_REPLY = prog['IPS_SEEN_REPLY'].value_()
    IPS_ASSURED = prog['IPS_ASSURED'].value_()
    IPS_CONFIRMED = prog['IPS_CONFIRMED'].value_()
    IPS_SRC_NAT = prog['IPS_SRC_NAT'].value_()
    IPS_DST_NAT = prog['IPS_DST_NAT'].value_()
    IPS_SEQ_ADJUST = prog['IPS_SEQ_ADJUST'].value_()
    IPS_SRC_NAT_DONE = prog['IPS_SRC_NAT_DONE'].value_()
    IPS_DST_NAT_DONE = prog['IPS_DST_NAT_DONE'].value_()
    IPS_DYING = prog['IPS_DYING'].value_()
    IPS_FIXED_TIMEOUT = prog['IPS_FIXED_TIMEOUT'].value_()
    IPS_TEMPLATE = prog['IPS_TEMPLATE'].value_()
    IPS_UNTRACKED = prog['IPS_UNTRACKED'].value_()
    IPS_HELPER = prog['IPS_HELPER'].value_()
    IPS_OFFLOAD = prog['IPS_OFFLOAD'].value_()

    print("status: %4x" % status, end=' ')
    if status & IPS_EXPECTED:
        print("IPS_EXPECTED", end=" | ")
    if status & IPS_SEEN_REPLY:
        print("IPS_SEEN_REPLY", end=" | ")
    if status & IPS_ASSURED:
        print("IPS_ASSURED", end=" | ")
    if status & IPS_CONFIRMED:
        print("IPS_CONFIRMED", end=" | ")
    if status & IPS_SRC_NAT:
        print("IPS_SRC_NAT", end=" | ")
    if status & IPS_DST_NAT:
        print("IPS_DST_NAT", end=" | ")
    if status & IPS_SEQ_ADJUST:
        print("IPS_SEQ_ADJUST", end=" | ")
    if status & IPS_SRC_NAT_DONE:
        print("IPS_SRC_NAT_DONE", end=" | ")
    if status & IPS_DST_NAT_DONE:
        print("IPS_DST_NAT_DONE", end=" | ")
    if status & IPS_DYING:
        print("IPS_DYING", end=" | ")
    if status & IPS_FIXED_TIMEOUT:
        print("IPS_FIXED_TIMEOUT", end=" | ")
    if status & IPS_TEMPLATE:
        print("IPS_TEMPLATE", end=" | ")
    if status & IPS_UNTRACKED:
        print("IPS_UNTRACKED", end=" | ")
    if status & IPS_HELPER:
        print("IPS_HELPER", end=" | ")
    if status & IPS_OFFLOAD:
        print("IPS_OFFLOAD", end=" | ")

    print("")

# enum tcp_conntrack {
#         TCP_CONNTRACK_NONE,
#         TCP_CONNTRACK_SYN_SENT,
#         TCP_CONNTRACK_SYN_RECV,
#         TCP_CONNTRACK_ESTABLISHED,
#         TCP_CONNTRACK_FIN_WAIT,
#         TCP_CONNTRACK_CLOSE_WAIT,
#         TCP_CONNTRACK_LAST_ACK,
#         TCP_CONNTRACK_TIME_WAIT,
#         TCP_CONNTRACK_CLOSE,
#         TCP_CONNTRACK_LISTEN,   /* obsolete */
#         TCP_CONNTRACK_MAX,
#         TCP_CONNTRACK_IGNORE,
#         TCP_CONNTRACK_RETRANS,
#         TCP_CONNTRACK_UNACK,
#         TCP_CONNTRACK_TIMEOUT_MAX
# };

def get_tcp_state(state):
    TCP_CONNTRACK_ESTABLISHED = prog['TCP_CONNTRACK_ESTABLISHED'].value_()
    TCP_CONNTRACK_TIME_WAIT = prog['TCP_CONNTRACK_TIME_WAIT'].value_()
    TCP_CONNTRACK_FIN_WAIT = prog['TCP_CONNTRACK_FIN_WAIT'].value_()
    TCP_CONNTRACK_CLOSE_WAIT = prog['TCP_CONNTRACK_CLOSE_WAIT'].value_()
    TCP_CONNTRACK_CLOSE = prog['TCP_CONNTRACK_CLOSE'].value_()

    if state == TCP_CONNTRACK_ESTABLISHED:
        return "TCP_CONNTRACK_ESTABLISHED"
    elif state == TCP_CONNTRACK_TIME_WAIT:
        return "TCP_CONNTRACK_TIME_WAIT"
    elif state == TCP_CONNTRACK_FIN_WAIT:
        return "TCP_CONNTRACK_FIN_WAIT"
    elif state == TCP_CONNTRACK_CLOSE_WAIT:
        return "TCP_CONNTRACK_CLOSE_WAIT"
    elif state == TCP_CONNTRACK_CLOSE:
        return "TCP_CONNTRACK_CLOSE"

def print_tuple(tuple, ct):
    IP_CT_DIR_ORIGINAL = prog['IP_CT_DIR_ORIGINAL'].value_()
    IPPROTO_UDP = prog['IPPROTO_UDP'].value_()
    IPPROTO_TCP = prog['IPPROTO_TCP'].value_()

    protonum = tuple.tuple.dst.protonum.value_()
    dir = tuple.tuple.dst.dir.value_()
    sport = 0;
    dport = 0;
    if protonum == IPPROTO_TCP:
        dport = socket.ntohs(tuple.tuple.dst.u.tcp.port.value_())
        sport = socket.ntohs(tuple.tuple.src.u.tcp.port.value_())
    if protonum == IPPROTO_UDP:
        dport = socket.ntohs(tuple.tuple.dst.u.udp.port.value_())
        sport = socket.ntohs(tuple.tuple.src.u.udp.port.value_())
    if dport != 4000:
        return

    print("nf_conn %lx" % ct.value_())
#     print("nf_conntrack_tuple %lx" % tuple.value_())

    if protonum == IPPROTO_TCP and dir == IP_CT_DIR_ORIGINAL:
        print("src ip: %20s:%6d" % (ipv4(socket.ntohl(tuple.tuple.src.u3.ip.value_())), sport), end=' ')
        print("dst ip: %20s:%6d" % (ipv4(socket.ntohl(tuple.tuple.dst.u3.ip.value_())), dport), end=' ')
        print("protonum: %3d" % protonum, end=' ')
        print("dir: %3d" % dir, end=' ')
        state = ct.proto.tcp.state
        print("state: %x, tcp_state: %s" % (state, get_tcp_state(state)))
#         print("timeout: %d" % ct.timeout);
        parse_ct_status(ct.status)

def print_tun(tun):
    print("\ttun_info: id: %x, dst ip: %s, dst port: %d" % \
        (tun.key.tun_id, ipv4(socket.ntohl(tun.key.u.ipv4.dst.value_())), \
        socket.ntohs(tun.key.tp_dst.value_())))

def print_dest(rule):
    print("\t\tmlx5_flow_rule %lx" % rule.address_of_().value_())
    if prog['MLX5_FLOW_DESTINATION_TYPE_COUNTER'] == rule.dest_attr.type:
        print("\t\t\tdest: counter_id: %x" % (rule.dest_attr.counter_id))
        return
    if prog['MLX5_FLOW_DESTINATION_TYPE_VPORT'] == rule.dest_attr.type:
        print("\t\t\tdest: vport: %x" % rule.dest_attr.vport.num)
        return
    if prog['MLX5_FLOW_DESTINATION_TYPE_TIR'] == rule.dest_attr.type:
        print("\t\t\tdest: tir_num: %x" % rule.dest_attr.tir_num)
        return
    if prog['MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE'] == rule.dest_attr.type:
        print("\t\t\tdest: ft: %lx" % (rule.dest_attr.ft.value_()))
#         flow_table("goto table", rule.dest_attr.ft)
        return
    else:
        print(rule)

def print_mlx5_flow_handle(handle):
    num_rules = handle.num_rules
    for k in range(num_rules):
        print_dest(handle.rule[k])

def print_mlx5_esw_flow_attr(attr):
    print("\t\taction: %x" % attr.action, end='\t')
    print("dest_chain: %x" % attr.dest_chain, end='\t')
    print("prio: %x" % attr.prio, end='\t')
    print("fdb: %20x" % attr.fdb, end='\t')
    print("dest_ft: %20x" % attr.dest_ft, end='\t')
    print('')
