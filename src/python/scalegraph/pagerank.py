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

class PageRank(xpregel.XPregelBase):

    def compute(self, ctx, messages):
        if ctx.superstep == 0:
            value = 1.0 / ctx.numVertices
        else:
            value = 0.15 / ctx.numVertices + 0.85 * sum(messages)
        ctx.aggregate(abs(value - ctx.getVertexValue()))
        ctx.setVertexValue(value)
        numOutEdges = len(ctx.outEdges)
        if numOutEdges > 0:
            msg = value / numOutEdges
            for d in ctx.outEdges:
                ctx.sendMessage(d, msg)
#        if numOutEdges > 0:
#            ctx.sendMessageToAllNeighbors(value / numOutEdges)


    def aggregator(self, outputs):
        return sum(outputs)

    def terminator(self, superstep, aggregatedValue):
#        ctx.log("PageRank at superstep " + superstep + " = " + aggValue + "\n")
        return superstep == 30


if __name__ == '__main__':
    pr = PageRank()
    pr.run()

