set $print = 1
set $debug = 0

define print-hmap
	set $name = $arg0
	set $p = $arg2
	set $num = $arg3
	set $index = 1

	set $i = 0
	while $i != $num
		set $a = *$p
		if $a != 0
			if $debug == 1
				printf "======= %d =======\n", $index
				set $index = $index + 1
			end
			if $print == 0
				printf "p *(struct %s *) 0x%x\n", $name, $a
			else
				if $argc == 6
					p (*(struct $arg1 *) $a).$arg5
				else
					p *(struct $arg1 *) $a
				end
			end
			set $i = $i + 1
			set $node = (*(struct $arg1 *) $a)->$arg4.next
			while $node != 0
				if $debug == 1
					printf "======= %d =======\n", $index
					set $index = $index + 1
				end
				if $print == 0
					printf "p *(struct %s *) 0x%x\n", $name, $node
				else
					if $argc == 6
						p (*(struct $arg1 *) $node).$arg5
					else
						p *(struct $arg1 *) $node
					end
				end
				set $node = (*(struct $arg1 *) $node)->$arg4.next
				set $i = $i + 1
			end
		end
		set $p = $p + 0x1
	end
end

################################################################################

define print-xports
        set $p = (*(struct xlate_cfg*) xcfgp)->xports.buckets
        set $num = (*(struct xlate_cfg*) xcfgp)->xports.n
	if $arg0 == 0
		set $print = 0
		p/x $num
	else
		set $print = 1
	end
	if $argc == 2
		print-hmap "xport" xport $p $num hmap_node $arg1
	else
		print-hmap "xport" xport $p $num hmap_node
	end
end
define xport
	print-xports 0
end
define xport2
	if $argc == 0
		print-xports 1
	else
		print-xports 1 $arg0
	end
end

################################################################################

define print-xbundles
        set $p = (*(struct xlate_cfg*) xcfgp)->xbundles.buckets
        set $num = (*(struct xlate_cfg*) xcfgp)->xbundles.n
	if $arg0 == 0
		set $print = 0
		p/x $num
	else
		set $print = 1
	end
	if $argc == 2
		print-hmap "xbundle" xbundle $p $num hmap_node $arg1
	else
		print-hmap "xbundle" xbundle $p $num hmap_node
	end
end
define xbundle
	print-xbundles 0
end
define xbundle2
	if $argc == 0
		print-xbundles 1
	else
		print-xbundles 1 $arg0
	end
end

################################################################################

define print-xbridges
        set $p = (*(struct xlate_cfg*) xcfgp)->xbridges.buckets
        set $num = (*(struct xlate_cfg*) xcfgp)->xbridges.n
	if $arg0 == 0
		set $print = 0
		p/x $num
	else
		set $print = 1
	end
	if $argc == 2
		print-hmap "xbridge" xbridge $p $num hmap_node $arg1
	else
		print-hmap "xbridge" xbridge $p $num hmap_node
	end
end
define xbridge
	print-xbridges 0
end
define xbridge2
	if $argc == 0
		print-xbridges 1
	else
		print-xbridges 1 $arg0
	end
end

################################################################################

define print-all-ofprotos
        set $p = all_ofprotos.buckets
        set $num = all_ofprotos.n
	if $arg0 == 0
		set $print = 0
		p/x $num
	else
		set $print = 1
	end
	if $argc == 2
		print-hmap "ofproto" ofproto $p $num hmap_node $arg1
	else
		print-hmap "ofproto" ofproto $p $num hmap_node
	end
end
define ofproto
	print-all-ofprotos 0
end
define ofproto2
	if $argc == 0
		print-all-ofprotos 1
	else
		print-all-ofprotos 1 $arg0
	end
end

################################################################################

define print-port-to-netdevs
	set $p = port_to_netdev.buckets
	set $num = port_to_netdev.n
	if $arg0 == 0
		set $print = 0
		p/x $num
	else
		set $print = 1
	end
	if $argc == 2
		print-hmap "port_to_netdev_data" port_to_netdev_data $p $num node $arg1
	else
		print-hmap "port_to_netdev_data" port_to_netdev_data $p $num node
	end
end
define port-to-netdev
	print-port-to-netdevs 0
end
define port-to-netdev2
	if $argc == 0
		print-port-to-netdevs 1
	else
		print-port-to-netdevs 1 $arg0
	end
end

################################################################################

define print-ifindex-to-ports
	set $p = ifindex_to_port.buckets
	set $num = ifindex_to_port.n
	if $arg0 == 0
		set $print = 0
		p/x $num
	else
		set $print = 1
	end
	if $argc == 2
		print-hmap "ifindex_to_port_data" ifindex_to_port_data $p $num node $arg1
	else
		print-hmap "ifindex_to_port_data" ifindex_to_port_data $p $num node
	end
end
define ifindex-to-port
	print-ifindex-to-ports 0
end
define ifindex-to-port2
	if $argc == 0
		print-ifindex-to-ports 1
	else
		print-ifindex-to-ports 1 $arg0
	end
end

################################################################################

define print-backer
        set $shash_node = all_dpif_backers.map.one
        p/x $shash_node
	set $backer = (*(struct shash_node *) $shash_node)->data
        p/x $backer
        p *(struct dpif_backer *)$backer
end

define print-ofport-dpifs
	if $arg0 == 0
		set $print = 0
		p/x $num
	else
		set $print = 1
	end
	set $shash_node = all_dpif_backers.map.one
	p/x $shash_node
	set $backer = (*(struct shash_node *) $shash_node)->data
	p/x $backer
	p (*(struct dpif_backer *)$backer).odp_to_ofport_map
	set $p = (*(struct dpif_backer *)$backer).odp_to_ofport_map.buckets
	set $num = (*(struct dpif_backer *)$backer).odp_to_ofport_map.n
	if $argc == 2
		print-hmap "ofport_dpif" ofport_dpif $p $num odp_port_node $arg1
	else
		print-hmap "ofport_dpif" ofport_dpif $p $num odp_port_node
	end
end
define ofport-dpif
	print-ofport-dpifs 0
end
define ofport-dpif2
	if $argc == 0
		print-ofport-dpifs 1
	else
		print-ofport-dpifs 1 $arg0
	end
end

################################################################################

define print-mbridge
	set $mbridge = (*(struct xbridge *) $arg0).mbridge
	p/x $mbridge
	p (*(struct mbridge *) $mbridge )

	set $mirror = (*(struct xbridge *) $arg0).mbridge.mirrors[0]
	p/x $mirror
	if $mirror != 0
		p (*(struct mirror *) $mirror )

		set $out = (*(struct xbridge *) $arg0).mbridge.mirrors[0].out
		p/x $out
		p (*(struct mbundle *) $out )

		set $bundle = (*(struct xbridge *) $arg0).mbridge.mirrors[0].out.ofbundle
		p/x $bundle
		p (*(struct ofbundle *) $bundle )
	fi
end

################################################################################

