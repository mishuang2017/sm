#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *

dev_base_head = prog['init_net'].dev_base_head
print(f'You have {dev_base_head} net devices')

for pos in list_for_each(id(dev_base_head)):
	print(f'You have {pos} net devices')
