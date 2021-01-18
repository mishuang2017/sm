#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import container_of
from drgn import Object

import sys
import os

sys.path.append(".")
from lib import *

lock_classes = prog['lock_classes']

# for i in range(100):
#     print(lock_classes[i].name.string_().decode())

i=1
all_lock_classes = prog['all_lock_classes']
for lock in list_for_each_entry('struct lock_class', all_lock_classes.address_of_(), 'lock_entry'):
    print(i)
    print(lock.name)
    i=i+1
