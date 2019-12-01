#!/usr/local/bin/drgn -k

from drgn.helpers.linux import *
from drgn import Object
import time
import socket
import sys
import os

libpath = os.path.dirname(os.path.realpath("__file__"))
sys.path.append(libpath)
import lib

def IS_TRIE(n):
    return n.pos >= 32

def IS_TNODE(n):
    return n.bits

def IS_LEAF(n):
    if n.bits:
        return 0
    else:
        return 1

def print_fib(fib):
    trie = fib.tb_data
    print(fib)

    trie = Object(prog, 'struct trie', address=trie)
    print(trie)

    kv = trie.kv
    print(kv)
    print(type(kv))

    for i in range(32):
        if IS_TRIE(kv[i]):
            print("kv[%d] is TRIE" % i)
        if IS_TNODE(kv[i]):
            print("kv[%d] is TNODE" % i)
            print(kv[i])
            print("key[%d]: %x, ip: %s" % (i, kv[i].key, lib.ipv4(socket.ntohl(kv[i].key.value_()))))
            break
        if IS_LEAF(kv[i]):
            print("kv[%d] is LEAF" % i)

#     for n in hlist_for_each_entry('struct fib_alias', leaf.address_of_(), 'fa_list'):
#         print(n)

ipv4 = prog['init_net'].ipv4
hash = ipv4.fib_table_hash[0]
for fib in hlist_for_each_entry('struct fib_table', hash.address_of_(), 'tb_hlist'):
    print_fib(fib)
