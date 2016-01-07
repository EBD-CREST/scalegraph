
import xpregel

class pagerank(xpregel.base):

    def compute(self, ctx, messages):
        print("compute invoked!!")

    def aggregate(self, outputs):
        return sum(outputs)

    def end(self, superstep, aggValue):
        print("PageRank at superstep " + superstep + " = " + aggValue + "\n")
        return superstep == 30


if __name__ == '__main__':
    pr = pagerank()
    pr.run()
