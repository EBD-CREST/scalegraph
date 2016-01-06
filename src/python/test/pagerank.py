
import xpregel

class pagerank(xpregel.base):

    def compute(self, ctx, messages):
        if ctx.superstep == 0:
            value = 1.0 / ctx.numberOfVertices
        else:
            value = 0.15 / ctx.numberOfVertices + 0.85 * sum(messages)
        ctx.output(abs(value - ctx.value))
        ctx.value = value
        next = value / ctx.numberOfOutEdges
        ctx.sendMessages(ctx.outEdges, next)

    def aggregate(self, outputs):
        return sum(outputs)

    def end(self, superstep, aggValue):
        print("PageRank at superstep " + superstep + " = " + aggValue + "\n")
        return superstep == 30


if __name__ == '__main__':
    pr = pagerank()
    pr.run()
