from drgn.helpers.linux import *
from drgn import container_of
from drgn import Object
from drgn import cast
from socket import ntohl
from socket import ntohs
import os

import subprocess
import drgn

prog = drgn.program_from_kernel()
# prog = drgn.program_from_core_dump("/var/crash/vmcore.0")

def kernel(name):
    b = os.popen('uname -r')
    text = b.read()
    b.close()

#     print("uname -r: %s" % text)

    if name in text:
        return True
    else:
        return False

def hostname(name):
    b = os.popen('hostname -s')
    text = b.read()
    b.close()

#     print("hostname: %s" % text)

    if name in text:
        return True
    else:
        return False

pf0_name = "enp4s0f0"
# if kernel("5.8.0-rc2+"):
pf0_name = "enp4s0f0np0"
pf1_name = "enp4s0f1"

if hostname("clx-ibmc-03") or hostname("clx-ibmc-01"):
    pf0_name = "ens1f0"
    pf1_name = "ens1f1"

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
    print("src ip  : %s" % ipv4(ntohl(tuple.src.u3.ip.value_())))
    print("src port: %d" % ntohs(tuple.src.u.all.value_()))
    print("dst ip  : %s" % ipv4(ntohl(tuple.dst.u3.ip.value_())))
    print("dst port: %d" % ntohs(tuple.dst.u.all.value_()))

def print_mlx5e_ct_tuple(k, tuple):
    print("\n=== mlx5e_ct_tuple start ===")
    print("%d: ipv4: %s" % (k, ipv4(ntohl(tuple.ipv4.value_()))))
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
#         print("hw_stats: %d" % a.hw_stats)
        if kind == "ct":
            print("\tact_ct")
#             print(a)
#             tcf_conntrack_info = Object(prog, 'struct tcf_conntrack_info', address=a.value_())
#             print("\tzone: %d" % tcf_conntrack_info.zone.value_(), end='')
#             print("\tmark: 0x%x" % tcf_conntrack_info.mark.value_(), end='')
#             print("\tlabels[0]: 0x%x" % tcf_conntrack_info.labels[0].value_(), end='')
#             print("\tcommit: %d" % tcf_conntrack_info.commit.value_(), end='')
#             print("\tnat: 0x%x" % tcf_conntrack_info.nat.value_())
#             if tcf_conntrack_info.range.min_addr.ip:
#                 print("snat ip: %s" % ipv4(ntohl(tcf_conntrack_info.range.min_addr.ip.value_())))
#             tcf_ct = cast('struct tcf_ct *', a)
#             params = tcf_ct.params
#             print("\tzone: %d\ttcf_ct_flow_table %x\tnf_flowtable %x" % (params.zone, params.ct_ft, params.nf_ft))
#             print(tcf_ct.params)

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
                print("\tsrc ip: %s" % ipv4(ntohl(ip_tunnel_key.u.ipv4.src.value_())))
                print("\tdst ip: %s" % ipv4(ntohl(ip_tunnel_key.u.ipv4.dst.value_())))
                print("\ttp_dst: %d" % ntohs(ip_tunnel_key.tp_dst.value_()))
        if kind == "sample":
            tcf_sample = Object(prog, 'struct tcf_sample', address=a.value_())
#             print(tcf_sample)
            print("\trate: %d, truncate: %d, trunc_size: %d" % (tcf_sample.rate, tcf_sample.truncate, tcf_sample.trunc_size), end='\t')
            print("\tpsample_group_num: %d" % tcf_sample.psample_group_num)
#             print(tcf_sample.psample_group)

def print_cls_fl_filter(f):
    print("handle: 0x%x" % f.handle)
    k = f.mkey
#     print("ct_state: %x" % k.ct_state)
#     print("mask ct_state: %x" % f.mask.key.ct_state)
    #define FLOW_DIS_IS_FRAGMENT    BIT(0)
    #define FLOW_DIS_FIRST_FRAG     BIT(1)
    # 1 means nofirstfrag
    # 3 means firstfrag
#     print("ip_flags: 0x%x" % k.control.flags)
#     print("ct_state: 0x%x" % k.ct_state.value_())
#     print("ct_zone: %d" % k.ct_zone.value_())
#     print("ct_mark: 0x%x" % k.ct_mark.value_())
#     print("ct_labels[0]: %x" % k.ct_labels[0].value_())
#     print("protocol: %x" % ntohs(k.basic.n_proto))
#     print("dmac: %s" % mac(k.eth.dst))
#     print("smac: %s" % mac(k.eth.src))
#     if k.ipv4.src:
#         print("src ip: ", end='')
#         print(ipv4(ntohl(k.ipv4.src.value_())))
#     if k.ipv4.dst:
#         print("dst ip: ", end='')
#         print(ipv4(ntohl(k.ipv4.dst.value_())))
 
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

def get_mlx5e_rep_priv2(port):
    mlx5e_priv = get_mlx5_pf0()

    # struct mlx5_esw_offload
    offloads = mlx5e_priv.mdev.priv.eswitch.offloads

    total_vports = mlx5e_priv.mdev.priv.eswitch.total_vports.value_()

#     print("total_vports: %d" % total_vports)

    # struct mlx5_eswitch_rep

    if port == 0:
        port = total_vports - 1
    if kernel("4.20.16+") or kernel("4.20.0-rc1+"):
        mlx5_eswitch_rep = offloads.vport_reps[0]
    else:
        mlx5_eswitch_rep = offloads.vport_reps[port]

#     for i in range(total_vports):
#         print("%lx" % offloads.vport_reps[i].address_of_())
#     print("%lx" % vport.address_of_())

    # struct mlx5_eswitch_rep_data
    rep_data = mlx5_eswitch_rep.rep_data

    # struct mlx5e_rep_priv
    priv = rep_data[prog['REP_ETH']].priv

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
        dport = ntohs(tuple.tuple.dst.u.tcp.port.value_())
        sport = ntohs(tuple.tuple.src.u.tcp.port.value_())
    if protonum == IPPROTO_UDP:
        dport = ntohs(tuple.tuple.dst.u.udp.port.value_())
        sport = ntohs(tuple.tuple.src.u.udp.port.value_())
    if dport != 4000:
        return

    print("nf_conn %lx" % ct.value_())
#     print("nf_conntrack_tuple %lx" % tuple.value_())

    if protonum == IPPROTO_TCP and dir == IP_CT_DIR_ORIGINAL:
        print("src ip: %20s:%6d" % (ipv4(ntohl(tuple.tuple.src.u3.ip.value_())), sport), end=' ')
        print("dst ip: %20s:%6d" % (ipv4(ntohl(tuple.tuple.dst.u3.ip.value_())), dport), end=' ')
        print("protonum: %3d" % protonum, end=' ')
        print("dir: %3d" % dir, end=' ')
        state = ct.proto.tcp.state
        print("state: %x, tcp_state: %s" % (state, get_tcp_state(state)))
#         print("timeout: %d" % ct.timeout);
        parse_ct_status(ct.status)

def print_tun(tun):
    print("\ttun_info: id: %x, dst ip: %s, dst port: %d" % \
        (tun.key.tun_id, ipv4(ntohl(tun.key.u.ipv4.dst.value_())), \
        ntohs(tun.key.tp_dst.value_())))

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
    if prog['MLX5_FLOW_DESTINATION_TYPE_FLOW_SAMPLER'] == rule.dest_attr.type:
        print("\t\t\tdest: sampler_id: %x" % rule.dest_attr.sampler_id)
        return
    else:
        print(rule)

def print_mlx5_flow_handle(handle):
    num_rules = handle.num_rules
    for k in range(num_rules):
        print_dest(handle.rule[k])

def print_mlx5_esw_flow_attr(attr):
    print("\t\taction: %x" % attr.action, end='\t')
    print("chain: %x" % attr.chain, end='\t')
    print("dest_chain: %x" % attr.dest_chain, end='\t')
    print("prio: %x" % attr.prio, end='\t')
    print("fdb: %20x" % attr.fdb, end='\t')
    print("dest_ft: %20x" % attr.dest_ft, end='\t')
#     print(attr.modify_hdr)
    print('')

def flow_table2(name, table):
    print("\nflow table name: %s\nflow table id: %x leve: %x, type: %x (FS_FT_FDB: %d, FS_FT_NIC_RX: %d)" % \
        (name, table.id.value_(), table.level.value_(), table.type, prog['FS_FT_FDB'], prog['FS_FT_NIC_RX']))
    print("mlx5_flow_table %lx" % table.address_of_())
#     print("flow table address")
#     print("%lx" % table.value_())
    fs_node = Object(prog, 'struct fs_node', address=table.address_of_())
#     print("%lx" % fs_node.address_of_())
#     print(fs_node)
    group_addr = fs_node.address_of_()
#     print("fs_node address")
#     print("%lx" % group_addr.value_())
    group_addr = fs_node.children.address_of_()
#     print(group_addr)
    for group in list_for_each_entry('struct fs_node', group_addr, 'list'):
        print("mlx5_flow_group %lx" % group)
        fte_addr = group.children.address_of_()
        for fte in list_for_each_entry('struct fs_node', fte_addr, 'list'):
            fs_fte = Object(prog, 'struct fs_fte', address=fte.value_())
            print_match(fs_fte)
            dest_addr = fte.children.address_of_()
            for dest in list_for_each_entry('struct fs_node', dest_addr, 'list'):
                rule = Object(prog, 'struct mlx5_flow_rule', address=dest.value_())
                print_dest(rule)



def flow_table(name, table):
    print("\nflow table name: %s\nflow table id: %x leve: %x, \
        type: %x (FS_FT_FDB: %d, FS_FT_NIC_RX: %d, max_fte: %d, %x)" % \
        (name, table.id.value_(), table.level.value_(), table.type, \
        prog['FS_FT_FDB'], prog['FS_FT_NIC_RX'], table.max_fte, table.max_fte))
    print("mlx5_flow_table %lx" % table.value_())
#     print("flow table address")
#     print("%lx" % table.value_())
    fs_node = Object(prog, 'struct fs_node', address=table.value_())
#     print("%lx" % fs_node.address_of_())
#     print(fs_node)
    group_addr = fs_node.address_of_()
#     print("fs_node address")
#     print("%lx" % group_addr.value_())
    group_addr = fs_node.children.address_of_()
#     print(group_addr)
    for group in list_for_each_entry('struct fs_node', group_addr, 'list'):
        print("mlx5_flow_group %lx" % group)
        fte_addr = group.children.address_of_()
        for fte in list_for_each_entry('struct fs_node', fte_addr, 'list'):
            fs_fte = Object(prog, 'struct fs_fte', address=fte.value_())
            print_match(fs_fte)
            if fs_fte.action.action & 0x40:
                print("modify_hdr id: %x" % fs_fte.action.modify_hdr.id)
            dest_addr = fte.children.address_of_()
            for dest in list_for_each_entry('struct fs_node', dest_addr, 'list'):
                rule = Object(prog, 'struct mlx5_flow_rule', address=dest.value_())
                print_dest(rule)

def print_mac(mac):
    for i in range(6):
        v = (mac >> (5 - i) * 8) & 0xff
        print("%02x" % v, end='')
        if i < 5:
            print(":", end='')

def print_match(fte):
    print("fs_fte %lx" % fte.address_of_().value_())
    val = fte.val
#     print(val)
#     smac = str(ntohl(hex(val[0])))
    print("%8x: " % fte.index.value_(), end='')
    tag = fte.flow_context.flow_tag
    if tag:
        print(" flow_tag: %x" % tag, end=' ')
    smac_47_16 = ntohl(val[0].value_())
    smac_15_0 = ntohl(val[1].value_() & 0xffff)
    smac_47_16 <<= 16
    smac_15_0 >>= 16
    smac = smac_47_16 | smac_15_0
    print(" s: ", end='')
    print_mac(smac)

    dmac_47_16 = ntohl(val[2].value_())
    dmac_15_0 = ntohl(val[3].value_() & 0xffff)
    dmac_47_16 <<= 16
    dmac_15_0 >>= 16
    dmac = dmac_47_16 | dmac_15_0
    print(" d: ", end='')
    print_mac(dmac)

    ethertype = ntohl(val[1].value_() & 0xffff0000)
    if ethertype:
        print(" et: %x" % ethertype, end='')

    vport = ntohl(val[17].value_() & 0xffff0000)
    # metadata_reg_c_0
#     vport = ntohl(val[59].value_() & 0xffff0000)
    if vport:
        print(" vport: %4x" % vport, end='')

    ip_protocol = val[4].value_() & 0xff
    if ip_protocol:
        print(" ip: %-2d" % ip_protocol, end='')

    tos = (val[4].value_() & 0xff00) >> 8
    if tos:
        print(" tos: %-2x(dscp: %x)" % (tos, tos >> 2), end='')

    tcp_flags = (val[4].value_() & 0xff000000) >> 24
    if tcp_flags:
        print(" tflags: %2x" % tcp_flags, end='')

    ip_version = (val[4].value_() & 0xff0000) >> 17
    if ip_version:
        print(" ipv: %-2x" % ip_version, end='')

    tcp_sport = ntohs(val[5].value_() & 0xffff)
    if tcp_sport:
        print(" sport: %5d" % tcp_sport, end='')

    tcp_dport = ntohs(val[5].value_() >> 16 & 0xffff)
    if tcp_dport:
        print(" dport: %6d" % tcp_dport, end='')

    udp_sport = ntohs(val[7].value_() & 0xffff)
    if udp_sport:
        print(" sport: %6d" % udp_sport, end='')

    udp_dport = ntohs(val[7].value_() >> 16 & 0xffff)
    if udp_dport:
        print(" dport: %6d" % udp_dport, end='')

    src_ip = ntohl(val[11].value_())
    if src_ip:
        print(" src_ip: %12s" % ipv4(src_ip), end='')

    dst_ip = ntohl(val[15].value_())
    if src_ip:
        print(" dst_ip: %12s" % ipv4(dst_ip), end='')

    vni = ntohl(val[21].value_() & 0xffffff) >> 8
    if vni:
        print(" vni: %6d" % vni, end='')

    source_sqn = ntohl(val[16].value_() & 0xffffff00)
    if source_sqn:
        print(" source_sqn: %6x" % source_sqn, end='')

    reg_c5 = ntohl(val[54].value_())
    if reg_c5:
        print(" reg_c5 (fteid): %4x" % reg_c5, end='')

    reg_c2 = ntohl(val[57].value_())
    if reg_c2:
        print(" reg_c2 (ct_state|ct_zone): %4x" % reg_c2, end='')

    reg_c1 = ntohl(val[58].value_())
    if reg_c1:
        print(" reg_c1: %4x" % reg_c1, end='')

    reg_c0 = ntohl(val[59].value_())
    if reg_c0:
        print(" reg_c0: %4x" % reg_c0, end='')

    if vni:
        smac_47_16 = ntohl(val[32].value_())
        smac_15_0 = ntohl(val[33].value_() & 0xffff)
        smac_47_16 <<= 16
        smac_15_0 >>= 16
        smac = smac_47_16 | smac_15_0
        print("\n           s: ", end='')
        print_mac(smac)

        dmac_47_16 = ntohl(val[34].value_())
        dmac_15_0 = ntohl(val[35].value_() & 0xffff)
        dmac_47_16 <<= 16
        dmac_15_0 >>= 16
        dmac = dmac_47_16 | dmac_15_0
        print(" d: ", end='')
        print_mac(dmac)

        ethertype = ntohl(val[33].value_() & 0xffff0000)
        print(" et: %x" % ethertype, end='')

        ip_protocol = val[36].value_() & 0xff
        if ip_protocol:
            print(" ip: %-2d" % ip_protocol, end='')

        tos = (val[4].value_() & 0xff00) >> 8
        if tos:
            print(" tos: %-2x(dscp: %x)" % (tos, tos >> 2), end='')

        tcp_flags = (val[36].value_() & 0xff000000) >> 24
        if tcp_flags:
            print(" tflags: %2x" % tcp_flags, end='')

        ip_version = (val[36].value_() & 0xff0000) >> 17
        if ip_version:
            print(" ipv: %-2x" % ip_version, end='')

        tcp_sport = ntohs(val[37].value_() & 0xffff)
        if tcp_sport:
            print(" sport: %5d" % tcp_sport, end='')

        tcp_dport = ntohs(val[37].value_() >> 16 & 0xffff)
        if tcp_dport:
            print(" dport: %6d" % tcp_dport, end='')

        udp_sport = ntohs(val[39].value_() & 0xffff)
        if udp_sport:
            print(" sport: %6d" % udp_sport, end='')

        udp_dport = ntohs(val[39].value_() >> 16 & 0xffff)
        if udp_dport:
            print(" dport: %6d" % udp_dport, end='')

        src_ip = ntohl(val[43].value_())
        if src_ip:
            print(" src_ip: %12s" % ipv4(src_ip), end='')

        dst_ip = ntohl(val[47].value_())
        if src_ip:
            print(" dst_ip: %12s" % ipv4(dst_ip), end='')

    print(" action %4x: " % fte.action.action.value_())

def print_udp_sock(sk):
    inet_sock = cast('struct inet_sock *', sk)
    dest_ip = inet_sock.sk.__sk_common.skc_daddr
    src_ip = inet_sock.sk.__sk_common.skc_rcv_saddr
    dest_port = ntohs(inet_sock.sk.__sk_common.skc_dport)
    src_port = ntohs(inet_sock.inet_sport)
    print("dest_ip: %s, src_ip: %s, dest_port: %d, src_port: %d" % \
                (ipv4(ntohl(dest_ip.value_())), ipv4(ntohl(src_ip.value_())), dest_port, src_port))
