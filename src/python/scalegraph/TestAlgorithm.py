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
                                    extra_options=["--pr-damping=0.95", "--pr-eps=0.002", "--pr-niter=50"])
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



class TestBetweennessCentrality(TestGraphAlgorithm):

    def setUp(self):
        self.algorithm = GraphAlgorithm.BetweennessCentrality()

    def test_InputRmatOutputOS(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_test")
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')

    def test_InputRmatOutputHDFS(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_test",
                                    output_fs=GraphAlgorithm.HDFS)
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')
        
    def test_RmatScale(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_test", input_rmat_scale=12)
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')

    def test_InputOSOutputOS(self):
        gen = GraphAlgorithm.GenerateGraph()
        gen.run(output_path="input_test")
        self.algorithm.run(input=GraphAlgorithm.FILE,
                           input_path="input_test",
                           output_path="output_test")
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')

    def test_InputHDFSOutputHDFS(self):
        gen = GraphAlgorithm.GenerateGraph()
        gen.run(output_path="input_test", output_fs=GraphAlgorithm.HDFS)
        self.algorithm.run(input=GraphAlgorithm.FILE,
                           input_path="input_test",
                           input_fs=GraphAlgorithm.HDFS,
                           output_path="output_test",
                           output_fs=GraphAlgorithm.HDFS)
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')

    def test_ExtraOptions(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_test",
                                    extra_options=["--bc-weighted=true"])
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')

        
class TestHyperANF(TestGraphAlgorithm):

    def setUp(self):
        self.algorithm = GraphAlgorithm.HyperANF()

    def test_InputRmatOutputOS(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_test")
        self.assertEqual(self.algorithm.outputNumFiles, 1)
        self.assertEqual(self.algorithm.outputNumLines, 1002)

    def test_InputRmatOutputHDFS(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_test",
                                    output_fs=GraphAlgorithm.HDFS)
        self.assertEqual(self.algorithm.outputNumFiles, 1)
        self.assertEqual(self.algorithm.outputNumLines, 1002)
        
    def test_RmatScale(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_test", input_rmat_scale=12)
        self.assertEqual(self.algorithm.outputNumFiles, 1)
        self.assertEqual(self.algorithm.outputNumLines, 1002)

    def test_InputOSOutputOS(self):
        gen = GraphAlgorithm.GenerateGraph()
        gen.run(output_path="input_test")
        self.algorithm.run(input=GraphAlgorithm.FILE,
                           input_path="input_test",
                           output_path="output_test")
        self.assertEqual(self.algorithm.outputNumFiles, 1)
        self.assertEqual(self.algorithm.outputNumLines, 1002)

    def test_InputHDFSOutputHDFS(self):
        gen = GraphAlgorithm.GenerateGraph()
        gen.run(output_path="input_test", output_fs=GraphAlgorithm.HDFS)
        self.algorithm.run(input=GraphAlgorithm.FILE,
                           input_path="input_test",
                           input_fs=GraphAlgorithm.HDFS,
                           output_path="output_test",
                           output_fs=GraphAlgorithm.HDFS)
        self.assertEqual(self.algorithm.outputNumFiles, 1)
        self.assertEqual(self.algorithm.outputNumLines, 1002)

    def test_ExtraOptions(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output_path="output_test",
                                    extra_options=["--hanf-niter=100"])
        self.assertEqual(self.algorithm.outputNumFiles, 1)
        self.assertEqual(self.algorithm.outputNumLines, 102)


class TestStronglyConnectedComponent(unittest.TestCase):

    def setUp(self):
        self.algorithm = GraphAlgorithm.StronglyConnectedComponent()

    def test_ErrorNoInput(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(output1_path="output1_test",
                                        output2_path="output2_test")

    def test_ErrorNoInputFilePath(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.FILE,
                                        output1_path="output1_test",
                                        output2_path="output2_test")
            
    def test_ErrorInvalidInputFs(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.FILE,
                                        input_path=123,
                                        input_fs=99999,
                                        output1_path="output1_test",
                                        output2_path="output2_test")


    def test_ErrorNotStrInputFilePath(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.FILE,
                                        input_path=123,
                                        output1_path="output1_test",
                                        output2_path="output2_test")

    def test_ErrorInvalidRmatScale(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                        input_rmat_scale="abc",
                                        output1_path="output1_test",
                                        output2_path="output2_test")

    def test_ErrorInvalidInput(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=99999,
                                        output1_path="output1_test",
                                        output2_path="output2_test")
            
    def test_ErrorNoOutput(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT)

    def test_ErrorNoOutput1(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                        output2_path="output2_test")

    def test_ErrorNoOutput2(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                        output1_path="output1_test")
            
    def test_ErrorInvalidOutput1Fs(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                        output1_path="output1_test",
                                        output2_path="output2_test",
                                        output1_fs=99999)

    def test_ErrorInvalidOutput2Fs(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                        output1_path="output1_test",
                                        output2_path="output2_test",
                                        output2_fs=99999)
            
    def test_ErrorNotStrOutput1FilePath(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                        output1_path=123,
                                        output2_path="output2_test")

    def test_ErrorNotStrOutput2FilePath(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                        output1_path="output1_test",
                                        output2_path=123)

    def test_ErrorTypeExtraOptions(self):
        with self.assertRaises(GraphAlgorithm.ArgumentError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                        output1_path="output1_test",
                                        output2_path="output2_test",
                                        extra_options=99999)

    def test_ErrorApiDriver(self):
        with self.assertRaises(GraphAlgorithm.ScaleGraphError):
            status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                        output1_path="output1_test",
                                        output2_path="output2_test",
                                        extra_options=["--invalid-option"])

    def test_InputRmatOutputOS(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output1_path="output1_test",
                                    output2_path="output2_test")
        self.assertEqual(self.algorithm.output1Summary, (4, 257, 'ID<Long>,sccA<Long>'))
        self.assertEqual(self.algorithm.output2Summary, (4, 257, 'ID<Long>,sccB<Long>'))

    def test_InputRmatOutputHDFS(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output1_path="output1_test",
                                    output2_path="output2_test",
                                    output1_fs=GraphAlgorithm.HDFS,
                                    output2_fs=GraphAlgorithm.HDFS)
        self.assertEqual(self.algorithm.output1Summary, (4, 257, 'ID<Long>,sccA<Long>'))
        self.assertEqual(self.algorithm.output2Summary, (4, 257, 'ID<Long>,sccB<Long>'))
        
    def test_RmatScale(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output1_path="output1_test",
                                    output2_path="output2_test",
                                    input_rmat_scale=12)
        self.assertEqual(self.algorithm.output1Summary, (4, 4097, 'ID<Long>,sccA<Long>'))
        self.assertEqual(self.algorithm.output2Summary, (4, 4097, 'ID<Long>,sccB<Long>'))

    def test_InputOSOutputOS(self):
        gen = GraphAlgorithm.GenerateGraph()
        gen.run(output_path="input_test")
        self.algorithm.run(input=GraphAlgorithm.FILE,
                           input_path="input_test",
                           output1_path="output1_test",
                           output2_path="output2_test")
        self.assertEqual(self.algorithm.output1Summary, (4, 257, 'ID<Long>,sccA<Long>'))
        self.assertEqual(self.algorithm.output2Summary, (4, 257, 'ID<Long>,sccB<Long>'))

    def test_InputHDFSOutputHDFS(self):
        gen = GraphAlgorithm.GenerateGraph()
        gen.run(output_path="input_test", output_fs=GraphAlgorithm.HDFS)
        self.algorithm.run(input=GraphAlgorithm.FILE,
                           input_path="input_test",
                           input_fs=GraphAlgorithm.HDFS,
                           output1_path="output1_test",
                           output2_path="output2_test",
                           output1_fs=GraphAlgorithm.HDFS,
                           output2_fs=GraphAlgorithm.HDFS)
        self.assertEqual(self.algorithm.output1Summary, (4, 257, 'ID<Long>,sccA<Long>'))
        self.assertEqual(self.algorithm.output2Summary, (4, 257, 'ID<Long>,sccB<Long>'))

    def test_ExtraOptions(self):
        status = self.algorithm.run(input=GraphAlgorithm.RMAT,
                                    output1_path="output1_test",
                                    output2_path="output2_test",
                                    output1_fs=GraphAlgorithm.HDFS,
                                    output2_fs=GraphAlgorithm.HDFS,
                                    extra_options=["--scc-niter=100", "--enable-log-stderr"])
        self.assertEqual(self.algorithm.output1Summary, (4, 257, 'ID<Long>,sccA<Long>'))
        self.assertEqual(self.algorithm.output2Summary, (4, 257, 'ID<Long>,sccB<Long>'))
        
        
if __name__ == '__main__':
    
    suiteGenerateGraph = unittest.TestLoader().loadTestsFromTestCase(TestGenerateGraph)
    suitePageRank = unittest.TestLoader().loadTestsFromTestCase(TestPageRank)
    suiteDegreeDistribution = unittest.TestLoader().loadTestsFromTestCase(TestDegreeDistribution)
    suiteBetweennessCentrality = unittest.TestLoader().loadTestsFromTestCase(TestBetweennessCentrality)
    suiteHyperANF = unittest.TestLoader().loadTestsFromTestCase(TestHyperANF)
    suiteStronglyConnectedComponent = unittest.TestLoader().loadTestsFromTestCase(TestStronglyConnectedComponent)
    
    suiteAll = unittest.TestSuite([suiteGenerateGraph,
                                   suitePageRank,
                                   suiteDegreeDistribution,
                                   suiteBetweennessCentrality,
                                   suiteHyperANF,
                                   suiteStronglyConnectedComponent])
#    suiteAll = unittest.TestSuite([suiteStronglyConnectedComponent])
    runner = unittest.TextTestRunner(verbosity=2)
    runner.run(suiteAll)
    
