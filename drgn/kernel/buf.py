#!/usr/local/bin/drgn -k

from drgn import container_of
from drgn.helpers.linux import *
from drgn import Object

import sys
import os
import string

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
import lib

try:
    buf = prog['__mlx5e_log_buf']
except LookupError as x:
    print("no mlx5_buf")
    sys.exit(1)

for i in str(buf.string_()).split('\\n'):
    print(i.strip("'"))
