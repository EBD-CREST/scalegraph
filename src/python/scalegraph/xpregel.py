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

import cloudpickle
import pickle
import subprocess
import config


class XPregelBase():

    def __init__(self):
        pass

    def save(self):
        pickled_compute = cloudpickle.dumps(self.compute)
        pickled_aggregator = cloudpickle.dumps(self.aggregator)
        pickled_terminator = cloudpickle.dumps(self.terminator)
        f = open(config.work_dir + '_xpregel_closure.bin', 'wb')
        pickle.dump((pickled_compute, pickled_aggregator, pickled_terminator), f)
        f.close()
        
    def run(self):
        self.save()

