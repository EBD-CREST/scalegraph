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

    def setUp(self):
        self.algorithm = GraphAlgorithm.PageRank()

    def test_ErrorNoInput(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(output_path="output_pr")

    def test_ErrorNoInputFilePath(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.FILE,
                                        output_path="output_pr")
            
    def test_ErrorInvlidInputFs(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.FILE,
                                        input_path=123,
                                        input_fs=99999,
                                        output_path="output_pr")

    def test_ErrorNotStrInputFilePath(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.FILE,
                                        input_path=123,
                                        output_path="output_pr")

    def test_ErrorInvalidRmatScale(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                        input_rmat_scale="abc",
                                        output_path="output_pr")

    def test_ErrorInvalidInput(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=99999,
                                        output_path="output_pr")
            
    def test_ErrorNoOutput(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT)

    def test_ErrorInvalidOutputFs(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                        output_path="output_pr",
                                        output_fs=99999)
        
    def test_ErrorNotStrOutputFilePath(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                        output_path=123)

    def test_ErrorTypeExtraOptions(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                        output_path="output_pr",
                                        extra_options=99999)

    def test_ErrorApiDriver(self):
        with self.assertRaises(GraphAlgorithm.ScaleGraphError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                        output_path="output_pr",
                                        extra_options=["--invalid-option"])
    
    def test_OutputOS(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_pr")
        self.assertEqual(self.algorithm.outputSummary, (4, 257, 'ID<Long>,pagerank<Double>'))

    def test_OutputHDFS(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_pr",
                                    output_fs=GraphAlgorithm.HDFS)
        self.assertEqual(self.algorithm.outputSummary, (4, 257, 'ID<Long>,pagerank<Double>'))
        
    def test_RmatScale(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_pr", input_rmat_scale=12)
        self.assertEqual(self.algorithm.outputSummary, (4, 4097, 'ID<Long>,pagerank<Double>'))

    def test_ExtraOptions(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_pr",
                                    extra_options=["--damping=0.95", "--eps=0.002", "--niter=50"])
        self.assertEqual(self.algorithm.outputSummary, (4, 257, 'ID<Long>,pagerank<Double>'))


class TestAll(TestPageRank):
    pass

