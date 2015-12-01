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
import GraphAlgorithm


class TestGraphAlgorithm(unittest.TestCase):

    def test_ErrorNoInput(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(output_path="output_test")

    def test_ErrorNoInputFilePath(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.FILE,
                                        output_path="output_test")
            
    def test_ErrorInvalidInputFs(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.FILE,
                                        input_path=123,
                                        input_fs=99999,
                                        output_path="output_test")

    def test_ErrorNotStrInputFilePath(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.FILE,
                                        input_path=123,
                                        output_path="output_test")

    def test_ErrorInvalidRmatScale(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                        input_rmat_scale="abc",
                                        output_path="output_test")

    def test_ErrorInvalidInput(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=99999,
                                        output_path="output_test")
            
    def test_ErrorNoOutput(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT)

    def test_ErrorInvalidOutputFs(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                        output_path="output_test",
                                        output_fs=99999)
        
    def test_ErrorNotStrOutputFilePath(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                        output_path=123)

    def test_ErrorTypeExtraOptions(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                        output_path="output_test",
                                        extra_options=99999)

    def test_ErrorApiDriver(self):
        with self.assertRaises(GraphAlgorithm.ScaleGraphError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                        output_path="output_test",
                                        extra_options=["--invalid-option"])

            
class TestGenerateGraph(TestGraphAlgorithm):

    def setUp(self):
        self.algorithm = GraphAlgorithm.GenerateGraph()

    def test_ErrorNoInput(self):
        pass

    def test_ErrorNoInputFilePath(self):
        pass

    def test_ErrorInvalidInputFs(self):
        pass

    def test_ErrorNotStrInputFilePath(self):
        pass

    def test_ErrorInvalidInput(self):
        pass

    def test_OutputOS(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_test")
        self.assertEqual(self.algorithm.outputSummary, (4, 4097, 'ID<Long>,source<Long>,target<Long>,weight<Double>'))

    def test_OutputHDFS(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_test",
                                    output_fs=GraphAlgorithm.HDFS)
        self.assertEqual(self.algorithm.outputSummary, (4, 4097, 'ID<Long>,source<Long>,target<Long>,weight<Double>'))
        
    def test_RmatScale(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_test", input_rmat_scale=12)
        self.assertEqual(self.algorithm.outputSummary, (4, 65537, 'ID<Long>,source<Long>,target<Long>,weight<Double>'))



class TestPageRank(TestGraphAlgorithm):

    def setUp(self):
        self.algorithm = GraphAlgorithm.PageRank()
    
    def test_InputRmatOutputOS(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_test")
        self.assertEqual(self.algorithm.outputSummary, (4, 257, 'ID<Long>,pagerank<Double>'))

    def test_InputRmatOutputHDFS(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_test",
                                    output_fs=GraphAlgorithm.HDFS)
        self.assertEqual(self.algorithm.outputSummary, (4, 257, 'ID<Long>,pagerank<Double>'))
        
    def test_RmatScale(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_test", input_rmat_scale=12)
        self.assertEqual(self.algorithm.outputSummary, (4, 4097, 'ID<Long>,pagerank<Double>'))

    def test_ExtraOptions(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_test",
                                    extra_options=["--damping=0.95", "--eps=0.002", "--niter=50"])
        self.assertEqual(self.algorithm.outputSummary, (4, 257, 'ID<Long>,pagerank<Double>'))

    def test_InputOSOutputOS(self):
        gen = GraphAlgorithm.GenerateGraph()
        gen.run(output_path="input_test")
        self.algorithm.run(input=GraphAlgorithm.FILE,
                           input_path="input_test",
                           output_path="output_test")
        self.assertEqual(self.algorithm.outputSummary, (4, 257, 'ID<Long>,pagerank<Double>'))

    def test_InputHDFSOutputHDFS(self):
        gen = GraphAlgorithm.GenerateGraph()
        gen.run(output_path="input_test", output_fs=GraphAlgorithm.HDFS)
        self.algorithm.run(input=GraphAlgorithm.FILE,
                           input_path="input_test",
                           input_fs=GraphAlgorithm.HDFS,
                           output_path="output_test",
                           output_fs=GraphAlgorithm.HDFS)
        self.assertEqual(self.algorithm.outputSummary, (4, 257, 'ID<Long>,pagerank<Double>'))

        
class TestDegreeDistribution(TestGraphAlgorithm):

    def setUp(self):
        self.algorithm = GraphAlgorithm.DegreeDistribution()

    def test_InputRmatOutputOS(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_test")
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,inoutdeg<Long>')

    def test_InputRmatOutputHDFS(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_test",
                                    output_fs=GraphAlgorithm.HDFS)
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,inoutdeg<Long>')
        
    def test_RmatScale(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_test", input_rmat_scale=12)
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,inoutdeg<Long>')

    def test_InputOSOutputOS(self):
        gen = GraphAlgorithm.GenerateGraph()
        gen.run(output_path="input_test")
        self.algorithm.run(input=GraphAlgorithm.FILE,
                           input_path="input_test",
                           output_path="output_test")
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,inoutdeg<Long>')


    def test_InputHDFSOutputHDFS(self):
        gen = GraphAlgorithm.GenerateGraph()
        gen.run(output_path="input_test", output_fs=GraphAlgorithm.HDFS)
        self.algorithm.run(input=GraphAlgorithm.FILE,
                           input_path="input_test",
                           input_fs=GraphAlgorithm.HDFS,
                           output_path="output_test",
                           output_fs=GraphAlgorithm.HDFS)
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,inoutdeg<Long>')

        

if __name__ == '__main__':
    
    suiteGenerateGraph = unittest.TestLoader().loadTestsFromTestCase(TestGenerateGraph)
    suitePageRank = unittest.TestLoader().loadTestsFromTestCase(TestPageRank)
    suiteDegreeDistribution = unittest.TestLoader().loadTestsFromTestCase(TestDegreeDistribution)
    suiteAll = unittest.TestSuite([suiteGenerateGraph,
                                   suitePageRank,
                                   suiteDegreeDistribution])
    runner = unittest.TextTestRunner(verbosity=2)
    runner.run(suiteAll)
    
