#
# This file is part of the ScaleGraph project (https://sites.google.com/site/scalegraph/).
# 
#  This file is licensed to You under the Eclipse Public License (EPL);
#  You may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#      http://www.opensource.org/licenses/eclipse-1.0.php
# 
#  (C) Copyright ScaleGraph Team 2011-2016.
#

import sys
sys.path.append('../')

from scalegraph import GraphAlgorithm


def sample_func(fix, *args):
    print(fix)
    print(args)

def sample_func2(fix, arg1=1, arg2=2, arg3=3):
    print(fix)
    print(arg1)
    print(arg2)
    print(arg3)
    
from enum import Enum
class TestEnum:
    RED = 1
    BLUE = 2
    YELLOW = 3

if __name__ == '__main1__':
    print("Start Test")
    pr = GraphAlgorithm.PageRank()
    pr.doTest()

class AException(Exception):
    pass

class Base:
    def __init__(self):
        self.value = 123
        
    def increment(self):
        self.value += 1

class Derived(Base):
    def __init__(self):
        super(Derived, self).__init__()
        pass
#        self.value = 0

    def test(self):
        self.increment()
        self.increment()
        self.increment()
        print(self.value)

import subprocess
    
if __name__ == '__main__0':
    print("ARG Test")
    sample_func('arg1', 'arg2', 'arg3')
    sample_func2('aaa', arg3=11, arg1=TestEnum.BLUE)
    print(subprocess.PIPE)
    print(TestEnum.RED)

if __name__ == '__main__':
    d = Derived()
    d.test()
    print(d.value)
