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
sys.path.append('/Users/tosiyuki/EBD/scalegraph-dev/src/python')

from scalegraph import GraphAlgorithm

if __name__ == '__main__':
    print("Start Test")
    pr = GraphAlgorithm.PageRank()
    pr.doTest()
    
    
    
