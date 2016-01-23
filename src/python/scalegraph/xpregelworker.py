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

class XPregelContext():

    def __init__(self):
        self.place_id = x10xpregeladapter.place_id()
        self.thread_id = x10xpregeladapter.thread_id()
        self.vertexValue_type = x10xpregeladapter.vertexValue_type();
        self.message_value_type = x10xpregeladapter.message_value_type();
        self.vertex_range_min = x10xpregeladapter.vertex_range_min()
        self.vertex_range_max = x10xpregeladapter.vertex_range_max()

        self.outEdge_offsets = x10xpregeladapter.outEdge_offsets().cast('q')
        self.outEdge_vertexes = x10xpregeladapter.outEdge_vertexes().cast('q')
        self.inEdge_offsets = x10xpregeladapter.inEdge_offsets().cast('q')
        self.inEdge_vertexes = x10xpregeladapter.inEdge_vertexes().cast('q')
        self.vertexValue = x10xpregeladapter.vertexValue().cast(x10xpregeladapter.get_format(self.vertexValue_type))
        self.vertexActive = x10xpregeladapter.vertexActive().cast('Q')
        self.vertexShouldBeActive = x10xpregeladapter.vertexShouldBeActive().cast('Q')
        self.message_values = x10xpregeladapter.message_values().cast(x10xpregeladapter.get_format(self.message_value_type))
        self.message_offsets = x10xpregeladapter.message_offsets().cast('q')

        self.log_prefix = "[" + str(self.place_id) + ":" + str(self.thread_id) + "]"
        
    def log(self, *objs):
        print(self.log_prefix, *objs, file=sys.stderr)


def test_context(ctx):
    for value in ctx.outEdge_offsets:
        ctx.log(value)
    for value in ctx.vertexValue:
        ctx.log(value)
    
        
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
    
