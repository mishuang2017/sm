#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import sys
import os

sys.path.append('.')
from lib import *

priv = get_pf0_netdev()
print(priv.name.string_().decode())
