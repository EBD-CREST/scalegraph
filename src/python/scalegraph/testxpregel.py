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

import xpregel

class TestXPregel(xpregel.XPregelBase):

    def compute(self, ctx, messages):
        print("compute invoked!!")

    def aggregator(self, outputs):
        return sum(outputs)

    def terminator(self, superstep, aggValue):
        print("PageRank at superstep " + superstep + " = " + aggValue + "\n")
        return superstep == 30


if __name__ == '__main__':
    pr = TestXPregel()
    pr.run()
