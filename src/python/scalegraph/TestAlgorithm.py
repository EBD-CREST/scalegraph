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

import unittest
from . import GraphAlgorithm

class TestPageRank(unittest.TestCase):

    def test_ErrorNoInput(self):
        algorithm = GraphAlgorithm.PageRank()
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = algorithm.run(output_path="output_pr")

    def test_ErrorNoInputFilePath(self):
        algorithm = GraphAlgorithm.PageRank()
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = algorithm.run(input=GraphAlgorithm.FILE,
                                   output_path="output_pr")
            
    def test_ErrorNotStrInputFilePath(self):
        algorithm = GraphAlgorithm.PageRank()
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = algorithm.run(input=GraphAlgorithm.FILE,
                                   input_path=123,
                                   output_path="output_pr")

    def test_OutputOS(self):
        algorithm = GraphAlgorithm.PageRank()
        status = algorithm.run(input=GraphAlgorithm.RMAT,
                               output_path="output_pr")
        self.assertEqual(status, 0)
        self.assertEqual(algorithm.outputSummary, (4, 257, 'ID<Long>,pagerank<Double>'))

    def test_RmatScale(self):
        algorithm = GraphAlgorithm.PageRank()
        status = algorithm.run(input=GraphAlgorithm.RMAT,
                               output_path="output_pr", input_rmat_scale=12)
        self.assertEqual(status, 0)
        self.assertEqual(algorithm.outputSummary, (4, 4097, 'ID<Long>,pagerank<Double>'))

    def test_ExtraOptions(self):
        algorithm = GraphAlgorithm.PageRank()
        status = algorithm.run(input=GraphAlgorithm.RMAT,
                               output_path="output_pr",
                               extra_options=["--damping=0.95", "--eps=0.002", "--niter=50"])
        self.assertEqual(status, 0)
        self.assertEqual(algorithm.outputSummary, (4, 257, 'ID<Long>,pagerank<Double>'))
