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
import pickle
import config
import x10xpregeladapter
import xpregel

class Bitmap():

    bitsPerWord = 64
    
    def __init__(self, size):
        self.numWords = round((size + self.bitsPerWord - 1) / self.bitsPerWord - 0.5);
        self.size = size


class XPregelContext():

    def __init__(self):

        # get runtime information
        self.place_id = x10xpregeladapter.place_id()
        self.thread_id = x10xpregeladapter.thread_id()
        self.num_threads = x10xpregeladapter.num_threads()

        # prepare prefix for log output
        self.log_prefix = "[" + str(self.place_id) + ":" + str(self.thread_id) + "]"

        # get type information
        self.vertexValue_type = x10xpregeladapter.vertexValue_type();
        self.message_value_type = x10xpregeladapter.message_value_type();

        # get graph
        self.outEdge_offsets = x10xpregeladapter.outEdge_offsets().cast('q')
        self.outEdge_vertexes = x10xpregeladapter.outEdge_vertexes().cast('q')
        self.inEdge_offsets = x10xpregeladapter.inEdge_offsets().cast('q')
        self.inEdge_vertexes = x10xpregeladapter.inEdge_vertexes().cast('q')

        # get vertex values
        self.vertexValue = x10xpregeladapter.vertexValue().cast(x10xpregeladapter.get_format(self.vertexValue_type))

        # setup place local range of vertexes 
        self.num_place_local_vertexes = len(self.vertexValue)
        self.range_place_local_vertexes = range(0, self.num_place_local_vertexes)
        self.log("range_place_local_vertexes", self.range_place_local_vertexes)
        
        # setup thread local range of vertexes
        numWords = Bitmap(self.num_place_local_vertexes).numWords
        chunkWords = max(round((numWords + self.num_threads - 1) / self.num_threads - 0.5), 1)
        rangeWords_min = min(numWords, self.thread_id * chunkWords)
        rangeWords_max = min(numWords, rangeWords_min + chunkWords)
        rangeThreadLocalVertexes_min = min(self.num_place_local_vertexes, rangeWords_min * Bitmap.bitsPerWord)
        rangeThreadLocalVertexes_max = min(self.num_place_local_vertexes, rangeWords_max * Bitmap.bitsPerWord)
        self.range_thread_local_vertexes = range(rangeThreadLocalVertexes_min, rangeThreadLocalVertexes_max)
        self.log("range_thread_local_vertexes", self.range_thread_local_vertexes)
        
        # get acitve flags
        self.vertexActive = x10xpregeladapter.vertexActive().cast('Q')
        self.vertexShouldBeActive = x10xpregeladapter.vertexShouldBeActive().cast('Q')

        # get messages
        self.message_values = x10xpregeladapter.message_values().cast(x10xpregeladapter.get_format(self.message_value_type))
        self.message_offsets = x10xpregeladapter.message_offsets().cast('q')

    def log(self, *objs):
        print(self.log_prefix, *objs, file=sys.stderr)

    def outEdges(self, vertex_id):
        return self.outEdge_vertexes[self.outEdge_offsets[vertex_id]:
                                     self.outEdge_offsets[vertex_id + 1]]

    def inEdges(self, vertex_id):
        return self.inEdge_vertexes[self.inEdge_offsets[vertex_id]:
                                    self.inEdge_offsets[vertex_id + 1]]

    def receivedMessages(self, vertex_id):
        return self.message_values[self.message_offsets[vertex_id]:
                                   self.message_offsets[vertex_id + 1]]
    
        
def test_context(ctx):
    for value in ctx.outEdge_offsets:
        ctx.log(value)
    for value in ctx.vertexValue:
        ctx.log(value)


def test_outEdges(ctx):
    size_total_edges = 0
    size_max_edges = 0
    for vid in ctx.range_place_local_vertexes:
        size = len(ctx.outEdges(vid))
        size_total_edges += size
        size_max_edges = max(size_max_edges, size)
    ctx.log("outEdges", len(ctx.outEdge_vertexes), size_total_edges, size_max_edges)

    
def test_inEdges(ctx):
    size_total_edges = 0
    size_max_edges = 0
    for vid in ctx.range_place_local_vertexes:
        size = len(ctx.inEdges(vid))
        size_total_edges += size
        size_max_edges = max(size_max_edges, size)
    ctx.log("inEdges", len(ctx.inEdge_vertexes), size_total_edges, size_max_edges)

    
def test_receivedMessages(ctx):
    size_total_msgs = 0
    size_max_msgs = 0
    for vid in ctx.range_place_local_vertexes:
        size = len(ctx.receivedMessages(vid))
        size_total_msgs += size
        size_max_msgs = max(size_max_msgs, size)
    ctx.log("receivedMessages", len(ctx.message_values), size_total_msgs, size_max_msgs)
        
        
def run():
    print("start")
    f = open(config.work_dir + '_xpregel_closure.bin', 'rb')
#    (pickled_compute, pickled_aggregator, pickled_terminator)=pickle.loads(closures.tobytes())
    (pickled_compute, pickled_aggregator, pickled_terminator)=pickle.load(f)
    f.close()
    compute=pickle.loads(pickled_compute)
    aggregator=pickle.loads(pickled_aggregator)
    terminator=pickle.loads(pickled_terminator)
    ctx = XPregelContext()
    compute(ctx, [])
    test_outEdges(ctx)
    test_inEdges(ctx)
    test_receivedMessages(ctx)
    
