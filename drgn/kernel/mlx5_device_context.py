#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import time
import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
import lib

# crash> list -H intf_list -s mlx5_interface -l mlx5_interface.list
# ffffffffc0af51a8
# struct mlx5_interface {
#   add = 0xffffffffc0a68fa0 <mlx5e_add>,
#   remove = 0xffffffffc0a68ed0 <mlx5e_remove>,
#   attach = 0xffffffffc0a68d70 <mlx5e_attach>,
#   detach = 0xffffffffc0a68e40 <mlx5e_detach>,
#   protocol = 0x1,
#   list = {
#     next = 0xffffffffc0b76028 <mlx5_ib_interface+40>,
#     prev = 0xffffffffc0af3730 <intf_list>
#   }
# }
# ffffffffc0b76028
# struct mlx5_interface {
#   add = 0xffffffffc0b34740 <mlx5_ib_add>,
#   remove = 0xffffffffc0b34600 <mlx5_ib_remove>,
#   attach = 0x0,
#   detach = 0x0,
#   protocol = 0x0,
#   list = {
#     next = 0xffffffffc0af3730 <intf_list>,
#     prev = 0xffffffffc0af51a8 <mlx5e_interface+40>
#   }
# }

mlx5e_priv = lib.get_mlx5_pf0()
mlx5e_core_dev = mlx5e_priv.mdev
print("mlx5e_core_dev %lx\n" % mlx5e_core_dev.value_())
mlx5_priv = mlx5e_core_dev.priv
ctx_list = mlx5_priv.ctx_list

for ctx in list_for_each_entry('struct mlx5_device_context', ctx_list.address_of_(), 'list'):
    intf = ctx.intf
    print("intf %20s, state: %x, contex: %lx" % (lib.address_to_name(hex(intf)), ctx.state, ctx.context))
    print(ctx)

print('')

# intf_list = prog['intf_list']
# for intf in list_for_each_entry('struct mlx5_interface', intf_list.address_of_(), 'list'):
#     add = intf.add
#     remove = intf.remove
#     attach = intf.attach
#     detach = intf.detach
#     print("add   : %s" % (lib.address_to_name(hex(add))))
#     print("remove: %s" % (lib.address_to_name(hex(remove))))
#     print("attach: %s" % (lib.address_to_name(hex(attach))))
#     print("detach: %s" % (lib.address_to_name(hex(detach))))
#     print(intf)
