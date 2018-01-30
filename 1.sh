set $g_xbridge = (*(struct xlate_cfg*) xcfgp)->xbridges.one
x (*(struct xbridge *) $g_xbridge ).xbundles.next
set $g_xbundles_head = $_
p/x $g_xbundles_head

define print-xbridge
	p (*(struct xbridge *) $g_xbridge )
end

define print-mbridge
	set $mbridge = (*(struct xbridge *) $g_xbridge).mbridge
	p/x $mbridge
	p (*(struct mbridge *) $mbridge )

	set $mirror = (*(struct xbridge *) $g_xbridge).mbridge.mirrors[0]
	p/x $mirror
	p (*(struct mirror *) $mirror )

	set $out = (*(struct xbridge *) $g_xbridge).mbridge.mirrors[0].out
	p/x $out
	p (*(struct mbundle *) $out )

	set $bundle = (*(struct xbridge *) $g_xbridge).mbridge.mirrors[0].out.ofbundle
	p/x $bundle
	p (*(struct ofbundle *) $bundle )
end

define print-xbundle
	if $argc == 1
		ls xbundle 0x18 $arg0
	end
	if $argc == 2
		ls xbundle 0x18 $arg0 $arg1
	end
end

define ls
	if $argc < 3
		echo ls "struct name" "offset" "list head address"\n
	else
		set $offset = $arg1
		set $head = $arg2
		set $node = $arg2
		set $i = 1
		while $i != 0
			if $node == $head
				set $node = *$node
			end
			if $argc == 3
				p (*(struct $arg0 *) (($node = *$node) - $offset))
			else
				p (*(struct $arg0 *) (($node = *$node) - $offset)).$arg3
			end
			p/x $node - $offset
			if $node == $head
				set $i = 0
			end
		end
	end
end

# print-xbundle $g_xbundles_head name

define print-xports
	set $p = (*(struct xlate_cfg*) xcfgp)->xports.buckets
	p/x $p
	set $num = (*(struct xlate_cfg*) xcfgp)->xports.n

	set $i = 0
	while $i != $num
		set $a = *$p
		if $a != 0
			p *(struct xport *) $a
			p/x $a
			set $i = $i + 1
			p/x $i
			set $node = (*(struct xport *) $a)->hmap_node.next
			while $node != 0
				p *(struct xport *) $node
				set $node = (*(struct xport *) $node)->hmap_node.next
				echo node-->
				p/x $node
				set $i = $i + 1
				p/x $i
			end
		end
		set $p = $p + 0x1
		p/x $p
	end
end

define print-port-to-netdev
	set $p = port_to_netdev.buckets
	p/x $p
	set $num = port_to_netdev.n
	p/x $num

	set $i = 0
	while $i != $num
		set $a = *$p
		if $a != 0
			echo node-->
			p/x $a
			p *(struct port_to_netdev_data *) $a
			set $i = $i + 1
			p/x $i
			set $node = (*(struct port_to_netdev_data *) $a)->node.next
			while $node != 0
				echo node-->
				p/x $node
				p *(struct port_to_netdev_data *) $node
				set $node = (*(struct port_to_netdev_data *) $node)->node.next
				set $i = $i + 1
				p/x $i
			end
		end
		set $p = $p + 0x1
		p/x $p
	end
end

define print-ifindex-to-port
	set $p = ifindex_to_port.buckets
	p/x $p
	set $num = ifindex_to_port.n
	p/x $num

	set $i = 0
	while $i != $num
		set $a = *$p
		if $a != 0
			set $i = $i + 1
			p/x $i
			echo node-->
			p/x $a
			p *(struct ifindex_to_port_data *) $a
			set $node = (*(struct ifindex_to_port_data *) $a)->node.next
			while $node != 0
				set $i = $i + 1
				p/x $i
				echo node-->
				p/x $node
				p *(struct ifindex_to_port_data *) $node
				set $node = (*(struct ifindex_to_port_data *) $node)->node.next
			end
		end
		set $p = $p + 0x1
		p/x $p
	end
end


define print-netdev
	set $p = port_to_netdev.buckets
	p/x $p
	set $num = port_to_netdev.n
	p/x $num

	set $i = 0
	while $i != $num
		set $a = *$p
		if $a != 0
			set $i = $i + 1
			p/x $i
			echo node-->
			set $dev = (*(struct port_to_netdev_data *) $a).netdev
			p/x $dev
			p *(struct netdev *) $dev
			set $node = (*(struct port_to_netdev_data *) $a)->node.next
			while $node != 0
				set $i = $i + 1
				p/x $i
				set $dev = (*(struct port_to_netdev_data *) $a).netdev
				echo node-->
				p/x $dev
				p *(struct netdev *) $dev
				set $node = (*(struct port_to_netdev_data *) $node)->node.next
			end
		end
		set $p = $p + 0x1
		p/x $p
	end
end

define print-ofports
	set $p = (*(struct xlate_cfg*) xcfgp)->xports.buckets
	p/x $p
	set $num = (*(struct xlate_cfg*) xcfgp)->xports.n

	set $i = 0
	while $i != $num
		set $a = *$p
		if $a != 0
			set $ofport = (*(struct xport *) $a)->ofport
			p/x $ofport
			p (*(struct ofport_dpif *) $ofport).odp_port
			p (*(struct ofport_dpif *) $ofport)
			set $i = $i + 1
			set $node = (*(struct xport *) $a)->hmap_node.next
			while $node != 0
# 				p *(struct xport *) $node
				set $ofport = (*(struct xport *) $node)->ofport
# 				p *(struct ofport_dpif *) $ofport
				p (*(struct ofport_dpif *) $ofport).odp_port
				p (*(struct ofport_dpif *) $ofport)
				set $node = (*(struct xport *) $node)->hmap_node.next
				echo node-->
				set $i = $i + 1
			end
		end
		set $p = $p + 0x1
		p/x $p
	end
end

define print-xbundles
	set $p = (*(struct xlate_cfg*) xcfgp)->xbundles.buckets
	p/x $p
	set $num = (*(struct xlate_cfg*) xcfgp)->xbundles.n
	p/x $num

	set $i = 0
	while $i != $num
		set $a = *$p
		if $a != 0
			p *(struct xbundle *) $a
			set $i = $i + 1
			set $node = (*(struct xbundle *) $a)->hmap_node.next
			while $node != 0
				p *(struct xbundle *) $node
				set $node = (*(struct xbundle *) $node)->hmap_node.next
				set $i = $i + 1
			end
		end
		set $p = $p + 0x1
	end
end

set $dpif = all_ofproto_dpifs.one

define print-dpif
	p/x $dpif
	p/x *(struct ofproto_dpif *)$dpif
# 	p/x (*(struct ofproto_dpif *)$dpif)->netflow
end

set $ofproto = all_ofprotos.one

define print-ofproto
	echo struct ofproto\t
# 	p $ofproto
# 	p *(struct ofproto*)$ofproto

	set $tables = (*(struct ofproto*)$ofproto).tables
# 	echo struct oftable\t
# 	p $tables
# 	p/x *(struct oftable*) $tables

	set $cls = (*(struct ofproto*)$ofproto).tables->cls
# 	echo struct classifier\t
# 	p/s $cls
# 	p/x *(struct classifier*) $cls

	set $subtables = (*(struct ofproto*)$ofproto).tables->cls.subtables.impl.p
# 	echo struct subtable\t
# 	p $subtables
# 	p/x *(struct pvector_impl*) $subtables

	set $size = (*(struct pvector_impl*) $subtables).size
	p/x $size
	set $vector = (*(struct pvector_impl*) $subtables).vector
	p/x $vector

	set $i = 0
	while $i != $size
		set $i = $i + 1
		p/x *(struct pvector_entry*) $vector
		set $cls_subtable = (*(struct pvector_entry*) $vector).ptr
# 		echo struct cls_subtable\t
# 		p/x $cls_subtable
# 		p/x *(struct cls_subtable*) $cls_subtable

		set $rules = (*(struct cls_subtable*)$cls_subtable).rules.impl.p
		p/x $rules

		x (*(struct cls_subtable*)$cls_subtable).rules_list.prev
		set $rules_list = $_
		echo cls_rule\t
		p/x $rules_list
		p/x *(struct cls_rule*) $rules_list
		set $o = &((struct rule*)0)->cr
		# 8 bytes
		set $rule_dpif = $rules_list - 2
		echo rule_dpif\t
		p/x $rule_dpif
		p/x *(struct rule_dpif*) $rule_dpif

		set $rule_actions = (*(struct rule_dpif*) $rule_dpif)->up.actions
		echo rule_actions\t
		p/x $rule_actions
		p/x *(struct rule_actions*)$rule_actions

		set $ofpacts = (*(struct rule_actions*)$rule_actions)->ofpacts
		echo ofpacts\t
		p/x $ofpacts
		p/x *(struct ofpact_output*)$ofpacts

		set $miniflow = (*(struct cls_rule*)$rules_list)->match.flow
		x/50 $miniflow

		set $cls_match = (*(struct cls_rule*)$rules_list)->cls_match.p
		echo cls_match\t
		p/x $i
		p/x $cls_match
		p/x *(struct cls_match*) $cls_match

# 		echo cmap_impl\n
# 		p/x *(struct cmap_impl*) $rules

		set $vector = $vector + 1
# 		p/x $vector
	end

# 	p/x (*(struct ofproto_dpif *)$dpif)->netflow
end

define print-ofports
	set $p = (*(struct ofproto*)$ofproto)->ports.buckets
	set $n = (*(struct ofproto*)$ofproto)->ports.n
	p/x $p
	p/x $n

	set $i = 0
	while $i != $n
		set $a = *$p
		if $a != 0
			p/x *(struct ofport *) $a
			set $i = $i + 1
			set $node = (*(struct ofport *) $a)->hmap_node.next
			while $node != 0
				p/x *(struct ofport *) $node
				set $node = (*(struct ofport *) $node)->hmap_node.next
				set $i = $i + 1
			end
		end
		set $p = $p + 0x1
	end

end

define print-ofbundls
	set $a = (*(struct ofproto_dpif *)$dpif)->bundles
	p $a

	set $p = (*(struct ofproto_dpif *) $dpif)->bundles.buckets
	p/x $p
	set $num = (*(struct ofproto_dpif *) $dpif)->bundles.n
	p/x $num

	set $i = 0
	while $i != $num
		set $a = *$p
		if $a != 0
			p *(struct ofbundle *) $a
			set $i = $i + 1
			set $node = (*(struct ofbundle *) $a)->hmap_node.next
			while $node != 0
				p *(struct ofbundle *) $node
				set $node = (*(struct ofbundle *) $node)->hmap_node.next
				set $i = $i + 1
			end
		end
		set $p = $p + 0x1
	end

end
