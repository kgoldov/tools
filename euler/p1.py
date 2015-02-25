#!/usr/bin/env python

import sys

def p1(limit):

    # We are interested in the sum of multiples less than limit
    limit = limit - 1
    # sum of multiples of n
    def _sum_mult(n):
        return ((limit // n + 1) * (limit // n) / 2) * n

    return int(_sum_mult(3) + _sum_mult(5) - \
        _sum_mult(15)) # Don't double count

if __name__ == '__main__':
    arg = int(sys.argv[1]) if len(sys.argv) > 1 else 10
    print( p1(arg) )
