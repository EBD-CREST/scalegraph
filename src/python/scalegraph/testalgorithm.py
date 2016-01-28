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
import graphalgorithm


class TestGraphAlgorithm(unittest.TestCase):

    def test_ErrorNoInput(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(output_path="output_test")

    def test_ErrorNoInputFilePath(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=graphalgorithm.FILE,
                                        output_path="output_test")
            
    def test_ErrorInvalidInputFs(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=graphalgorithm.FILE,
                                        input_path=123,
                                        input_fs=99999,
                                        output_path="output_test")

    def test_ErrorNotStrInputFilePath(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=graphalgorithm.FILE,
                                        input_path=123,
                                        output_path="output_test")

    def test_ErrorInvalidRmatScale(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=graphalgorithm.RMAT,
                                        input_rmat_scale="abc",
                                        output_path="output_test")

    def test_ErrorInvalidInput(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=99999,
                                        output_path="output_test")
            
    def test_ErrorNoOutput(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=graphalgorithm.RMAT)

    def test_ErrorInvalidOutputFs(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=graphalgorithm.RMAT,
                                        output_path="output_test",
                                        output_fs=99999)
        
    def test_ErrorNotStrOutputFilePath(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=graphalgorithm.RMAT,
                                        output_path=123)

    def test_ErrorTypeExtraOptions(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=graphalgorithm.RMAT,
                                        output_path="output_test",
                                        extra_options=99999)

    def test_ErrorInvalidExtraOptions(self):
        with self.assertRaises(graphalgorithm.ScaleGraphError):
            status = self.algorithm.run(input=graphalgorithm.RMAT,
                                        output_path="output_test",
                                        extra_options=["--cause-error"])

    def test_ErrorNoValueInputHeaderSource(self):
        with self.assertRaises(graphalgorithm.ScaleGraphError):
            status = self.algorithm.run(input=graphalgorithm.RMAT,
                                        output_path="output_test",
                                        extra_options=["--input-data-file-header-source"])

    def test_ErrorNoValueInputHeaderTarget(self):
        with self.assertRaises(graphalgorithm.ScaleGraphError):
            status = self.algorithm.run(input=graphalgorithm.RMAT,
                                        output_path="output_test",
                                        extra_options=["--input-data-file-header-target"])

    def test_ErrorNoValueInputHeaderWeight(self):
        with self.assertRaises(graphalgorithm.ScaleGraphError):
            status = self.algorithm.run(input=graphalgorithm.RMAT,
                                        output_path="output_test",
                                        extra_options=["--input-data-file-header-weight"])

    def test_ErrorNoValueOutputHeaderSource(self):
        with self.assertRaises(graphalgorithm.ScaleGraphError):
            status = self.algorithm.run(input=graphalgorithm.RMAT,
                                        output_path="output_test",
                                        extra_options=["--output-data-file-header-source"])

    def test_ErrorNoValueOutputHeaderTarget(self):
        with self.assertRaises(graphalgorithm.ScaleGraphError):
            status = self.algorithm.run(input=graphalgorithm.RMAT,
                                        output_path="output_test",
                                        extra_options=["--output-data-file-header-target"])

    def test_ErrorNoValueOutputHeaderWeight(self):
        with self.assertRaises(graphalgorithm.ScaleGraphError):
            status = self.algorithm.run(input=graphalgorithm.RMAT,
                                        output_path="output_test",
                                        extra_options=["--output-data-file-header-weight"])

            
class TestGenerateGraph(TestGraphAlgorithm):

    def setUp(self):
        self.algorithm = graphalgorithm.GenerateGraph()

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
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output_path="output_test")
        self.assertEqual(self.algorithm.outputSummary, (4, 4097, 'ID<Long>,source<Long>,target<Long>,weight<Double>'))

    def test_OutputHDFS(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output_path="output_test",
                                    output_fs=graphalgorithm.HDFS)
        self.assertEqual(self.algorithm.outputSummary, (4, 4097, 'ID<Long>,source<Long>,target<Long>,weight<Double>'))
        
    def test_RmatScale(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output_path="output_test", input_rmat_scale=10)
        self.assertEqual(self.algorithm.outputSummary, (4, 16385, 'ID<Long>,source<Long>,target<Long>,weight<Double>'))

    def test_HeaderOutputOS(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output_path="output_test",
                                    extra_options=["--output-data-file-header-source=newsource",
                                                   "--output-data-file-header-target=newtarget",
                                                   "--output-data-file-header-weight=newweight"])
        self.assertEqual(self.algorithm.outputSummary, (4, 4097, 'ID<Long>,newsource<Long>,newtarget<Long>,newweight<Double>'))


class TestPageRank(TestGraphAlgorithm):

    def setUp(self):
        self.algorithm = graphalgorithm.PageRank()
    
    def test_InputRmatOutputOS(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output_path="output_test")
        self.assertEqual(self.algorithm.outputSummary, (4, 257, 'ID<Long>,pagerank<Double>'))

    def test_InputRmatOutputHDFS(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output_path="output_test",
                                    output_fs=graphalgorithm.HDFS)
        self.assertEqual(self.algorithm.outputSummary, (4, 257, 'ID<Long>,pagerank<Double>'))
        
    def test_RmatScale(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output_path="output_test", input_rmat_scale=10)
        self.assertEqual(self.algorithm.outputSummary, (4, 1025, 'ID<Long>,pagerank<Double>'))

    def test_ExtraOptions(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output_path="output_test",
                                    extra_options=["--pr-damping=0.95", "--pr-eps=0.002", "--pr-niter=50"])
        self.assertEqual(self.algorithm.outputSummary, (4, 257, 'ID<Long>,pagerank<Double>'))

    def test_InputOSOutputOS(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test")
        self.algorithm.run(input=graphalgorithm.FILE,
                           input_path="input_test",
                           output_path="output_test")
        self.assertEqual(self.algorithm.outputSummary, (4, 257, 'ID<Long>,pagerank<Double>'))

    def test_InputHDFSOutputHDFS(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test", output_fs=graphalgorithm.HDFS)
        self.algorithm.run(input=graphalgorithm.FILE,
                           input_path="input_test",
                           input_fs=graphalgorithm.HDFS,
                           output_path="output_test",
                           output_fs=graphalgorithm.HDFS)
        self.assertEqual(self.algorithm.outputSummary, (4, 257, 'ID<Long>,pagerank<Double>'))

    def test_ChangeEdgeHeader(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test",
                extra_options=["--output-data-file-header-source=newheader",
                               "--output-data-file-header-target=newtarget"])
        self.algorithm.run(input=graphalgorithm.FILE,
                           input_path="input_test",
                           output_path="output_test",
                           extra_options=["--input-data-file-header-source=newheader",
                                          "--input-data-file-header-target=newtarget"])
        self.assertEqual(self.algorithm.outputSummary, (4, 257, 'ID<Long>,pagerank<Double>'))

    def test_NotReadWeight(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test",
                extra_options=["--output-data-file-header-weight=not-read"])
        self.algorithm.run(input=graphalgorithm.FILE,
                           input_path="input_test",
                           output_path="output_test")
        self.assertEqual(self.algorithm.outputSummary, (4, 257, 'ID<Long>,pagerank<Double>'))

        
class TestDegreeDistribution(TestGraphAlgorithm):

    def setUp(self):
        self.algorithm = graphalgorithm.DegreeDistribution()

    def test_InputRmatOutputOS(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output_path="output_test")
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,inoutdeg<Long>')

    def test_InputRmatOutputHDFS(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output_path="output_test",
                                    output_fs=graphalgorithm.HDFS)
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,inoutdeg<Long>')
        
    def test_RmatScale(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output_path="output_test", input_rmat_scale=10)
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,inoutdeg<Long>')

    def test_InputOSOutputOS(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test")
        self.algorithm.run(input=graphalgorithm.FILE,
                           input_path="input_test",
                           output_path="output_test")
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,inoutdeg<Long>')

    def test_InputHDFSOutputHDFS(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test", output_fs=graphalgorithm.HDFS)
        self.algorithm.run(input=graphalgorithm.FILE,
                           input_path="input_test",
                           input_fs=graphalgorithm.HDFS,
                           output_path="output_test",
                           output_fs=graphalgorithm.HDFS)
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,inoutdeg<Long>')

    def test_NotReadWeight(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test",
                extra_options=["--output-data-file-header-weight=not-read"])
        self.algorithm.run(input=graphalgorithm.FILE,
                           input_path="input_test",
                           output_path="output_test")
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,inoutdeg<Long>')


class TestBetweennessCentrality(TestGraphAlgorithm):

    def setUp(self):
        self.algorithm = graphalgorithm.BetweennessCentrality()

    def test_InputRmatOutputOS(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output_path="output_test")
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')

    def test_InputRmatOutputHDFS(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output_path="output_test",
                                    output_fs=graphalgorithm.HDFS)
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')
        
    def test_RmatScale(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output_path="output_test", input_rmat_scale=10)
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')

    def test_InputOSOutputOS(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test")
        self.algorithm.run(input=graphalgorithm.FILE,
                           input_path="input_test",
                           output_path="output_test")
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')

    def test_InputHDFSOutputHDFS(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test", output_fs=graphalgorithm.HDFS)
        self.algorithm.run(input=graphalgorithm.FILE,
                           input_path="input_test",
                           input_fs=graphalgorithm.HDFS,
                           output_path="output_test",
                           output_fs=graphalgorithm.HDFS)
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')

    def test_ExtraOptions(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output_path="output_test",
                                    extra_options=["--bc-weighted=true"])
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')

    def test_ReadWeight(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test")
        self.algorithm.run(input=graphalgorithm.FILE,
                           input_path="input_test",
                           output_path="output_test",
                           extra_options=["--bc-weighted=true"])
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')

    def test_RandomWeight(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test",
                extra_options=["--output-data-file-header-weight=ignore_this"])
        self.algorithm.run(input=graphalgorithm.FILE,
                           input_path="input_test",
                           output_path="output_test",
                           extra_options=["--bc-weighted=true",
                                          "--input-data-file-weight-random"])
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')

    def test_ErrorNoConstWeight(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test",
                extra_options=["--output-data-file-header-weight=ignore_this"])
        with self.assertRaises(graphalgorithm.ScaleGraphError):
            self.algorithm.run(input=graphalgorithm.FILE,
                               input_path="input_test",
                               output_path="output_test",
                               extra_options=["--bc-weighted=true",
                                              "--input-data-file-weight-constant"])
        
    def test_ConstWeight(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test",
                extra_options=["--output-data-file-header-weight=ignore_this"])
        self.algorithm.run(input=graphalgorithm.FILE,
                           input_path="input_test",
                           output_path="output_test",
                           extra_options=["--bc-weighted=true",
                                          "--input-data-file-weight-constant=0.5"])
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')

    def test_ChangeWeightHeader(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test",
                extra_options=["--output-data-file-header-weight=changed-weight"])
        self.algorithm.run(input=graphalgorithm.FILE,
                           input_path="input_test",
                           output_path="output_test",
                           extra_options=["--bc-weighted=true",
                                          "--input-data-file-header-weight=changed-weight"])
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')
        
    def test_NotReadWeight(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test",
                extra_options=["--output-data-file-header-weight=not-read"])
        self.algorithm.run(input=graphalgorithm.FILE,
                           input_path="input_test",
                           output_path="output_test",
                           extra_options=["--bc-weighted=false"])
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')
        
    def test_ChangeEdgeHeader(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test",
                extra_options=["--output-data-file-header-source=newheader",
                               "--output-data-file-header-target=newtarget"])
        self.algorithm.run(input=graphalgorithm.FILE,
                           input_path="input_test",
                           output_path="output_test",
                           extra_options=["--bc-weighted=true",
                                          "--input-data-file-header-source=newheader",
                                          "--input-data-file-header-target=newtarget"])
        self.assertEqual(self.algorithm.outputNumFiles, 4)
        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')

    def test_ErrorReadWeight(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test",
                extra_options=["--output-data-file-header-weight=cause-error"])
        with self.assertRaises(graphalgorithm.ScaleGraphError):
            self.algorithm.run(input=graphalgorithm.FILE,
                               input_path="input_test",
                               output_path="output_test",
                               extra_options=["--bc-weighted=true"])
        
        
class TestHyperANF(TestGraphAlgorithm):

    def setUp(self):
        self.algorithm = graphalgorithm.HyperANF()

    def test_InputRmatOutputOS(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output_path="output_test")
        self.assertEqual(self.algorithm.outputNumFiles, 1)
        self.assertEqual(self.algorithm.outputNumLines, 1002)

    def test_InputRmatOutputHDFS(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output_path="output_test",
                                    output_fs=graphalgorithm.HDFS)
        self.assertEqual(self.algorithm.outputNumFiles, 1)
        self.assertEqual(self.algorithm.outputNumLines, 1002)
        
    def test_RmatScale(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output_path="output_test", input_rmat_scale=10)
        self.assertEqual(self.algorithm.outputNumFiles, 1)
        self.assertEqual(self.algorithm.outputNumLines, 1002)

    def test_InputOSOutputOS(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test")
        self.algorithm.run(input=graphalgorithm.FILE,
                           input_path="input_test",
                           output_path="output_test")
        self.assertEqual(self.algorithm.outputNumFiles, 1)
        self.assertEqual(self.algorithm.outputNumLines, 1002)

    def test_InputHDFSOutputHDFS(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test", output_fs=graphalgorithm.HDFS)
        self.algorithm.run(input=graphalgorithm.FILE,
                           input_path="input_test",
                           input_fs=graphalgorithm.HDFS,
                           output_path="output_test",
                           output_fs=graphalgorithm.HDFS)
        self.assertEqual(self.algorithm.outputNumFiles, 1)
        self.assertEqual(self.algorithm.outputNumLines, 1002)

    def test_ExtraOptions(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output_path="output_test",
                                    extra_options=["--hanf-niter=100"])
        self.assertEqual(self.algorithm.outputNumFiles, 1)
        self.assertEqual(self.algorithm.outputNumLines, 102)

    def test_NotReadWeight(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test",
                extra_options=["--output-data-file-header-weight=not-read"])
        self.algorithm.run(input=graphalgorithm.FILE,
                           input_path="input_test",
                           output_path="output_test")
        self.assertEqual(self.algorithm.outputNumFiles, 1)
        self.assertEqual(self.algorithm.outputNumLines, 1002)

        
class TestStronglyConnectedComponent(unittest.TestCase):

    def setUp(self):
        self.algorithm = graphalgorithm.StronglyConnectedComponent()

    def test_ErrorNoInput(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(output1_path="output1_test",
                                        output2_path="output2_test")

    def test_ErrorNoInputFilePath(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=graphalgorithm.FILE,
                                        output1_path="output1_test",
                                        output2_path="output2_test")
            
    def test_ErrorInvalidInputFs(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=graphalgorithm.FILE,
                                        input_path=123,
                                        input_fs=99999,
                                        output1_path="output1_test",
                                        output2_path="output2_test")


    def test_ErrorNotStrInputFilePath(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=graphalgorithm.FILE,
                                        input_path=123,
                                        output1_path="output1_test",
                                        output2_path="output2_test")

    def test_ErrorInvalidRmatScale(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=graphalgorithm.RMAT,
                                        input_rmat_scale="abc",
                                        output1_path="output1_test",
                                        output2_path="output2_test")

    def test_ErrorInvalidInput(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=99999,
                                        output1_path="output1_test",
                                        output2_path="output2_test")
            
    def test_ErrorNoOutput(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=graphalgorithm.RMAT)

    def test_ErrorNoOutput1(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=graphalgorithm.RMAT,
                                        output2_path="output2_test")

    def test_ErrorNoOutput2(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=graphalgorithm.RMAT,
                                        output1_path="output1_test")
            
    def test_ErrorInvalidOutput1Fs(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=graphalgorithm.RMAT,
                                        output1_path="output1_test",
                                        output2_path="output2_test",
                                        output1_fs=99999)

    def test_ErrorInvalidOutput2Fs(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=graphalgorithm.RMAT,
                                        output1_path="output1_test",
                                        output2_path="output2_test",
                                        output2_fs=99999)
            
    def test_ErrorNotStrOutput1FilePath(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=graphalgorithm.RMAT,
                                        output1_path=123,
                                        output2_path="output2_test")

    def test_ErrorNotStrOutput2FilePath(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=graphalgorithm.RMAT,
                                        output1_path="output1_test",
                                        output2_path=123)

    def test_ErrorTypeExtraOptions(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            status = self.algorithm.run(input=graphalgorithm.RMAT,
                                        output1_path="output1_test",
                                        output2_path="output2_test",
                                        extra_options=99999)

    def test_ErrorApiDriver(self):
        with self.assertRaises(graphalgorithm.ScaleGraphError):
            status = self.algorithm.run(input=graphalgorithm.RMAT,
                                        output1_path="output1_test",
                                        output2_path="output2_test",
                                        extra_options=["--invalid-option"])

    def test_InputRmatOutputOS(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output1_path="output1_test",
                                    output2_path="output2_test")
        self.assertEqual(self.algorithm.output1Summary, (4, 257, 'ID<Long>,sccA<Long>'))
        self.assertEqual(self.algorithm.output2Summary, (4, 257, 'ID<Long>,sccB<Long>'))

    def test_InputRmatOutputHDFS(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output1_path="output1_test",
                                    output2_path="output2_test",
                                    output1_fs=graphalgorithm.HDFS,
                                    output2_fs=graphalgorithm.HDFS)
        self.assertEqual(self.algorithm.output1Summary, (4, 257, 'ID<Long>,sccA<Long>'))
        self.assertEqual(self.algorithm.output2Summary, (4, 257, 'ID<Long>,sccB<Long>'))
        
    def test_RmatScale(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output1_path="output1_test",
                                    output2_path="output2_test",
                                    input_rmat_scale=10)
        self.assertEqual(self.algorithm.output1Summary, (4, 1025, 'ID<Long>,sccA<Long>'))
        self.assertEqual(self.algorithm.output2Summary, (4, 1025, 'ID<Long>,sccB<Long>'))

    def test_InputOSOutputOS(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test")
        self.algorithm.run(input=graphalgorithm.FILE,
                           input_path="input_test",
                           output1_path="output1_test",
                           output2_path="output2_test")
        self.assertEqual(self.algorithm.output1Summary, (4, 257, 'ID<Long>,sccA<Long>'))
        self.assertEqual(self.algorithm.output2Summary, (4, 257, 'ID<Long>,sccB<Long>'))

    def test_InputHDFSOutputHDFS(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test", output_fs=graphalgorithm.HDFS)
        self.algorithm.run(input=graphalgorithm.FILE,
                           input_path="input_test",
                           input_fs=graphalgorithm.HDFS,
                           output1_path="output1_test",
                           output2_path="output2_test",
                           output1_fs=graphalgorithm.HDFS,
                           output2_fs=graphalgorithm.HDFS)
        self.assertEqual(self.algorithm.output1Summary, (4, 257, 'ID<Long>,sccA<Long>'))
        self.assertEqual(self.algorithm.output2Summary, (4, 257, 'ID<Long>,sccB<Long>'))

    def test_ExtraOptions(self):
        status = self.algorithm.run(input=graphalgorithm.RMAT,
                                    output1_path="output1_test",
                                    output2_path="output2_test",
                                    output1_fs=graphalgorithm.HDFS,
                                    output2_fs=graphalgorithm.HDFS,
                                    extra_options=["--scc-niter=100", "--enable-log-stderr"])
        self.assertEqual(self.algorithm.output1Summary, (4, 257, 'ID<Long>,sccA<Long>'))
        self.assertEqual(self.algorithm.output2Summary, (4, 257, 'ID<Long>,sccB<Long>'))
        
    def test_NotReadWeight(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test",
                extra_options=["--output-data-file-header-weight=not-read"])
        self.algorithm.run(input=graphalgorithm.FILE,
                           input_path="input_test",
                           output1_path="output1_test",
                           output2_path="output2_test")
        self.assertEqual(self.algorithm.output1Summary, (4, 257, 'ID<Long>,sccA<Long>'))
        self.assertEqual(self.algorithm.output2Summary, (4, 257, 'ID<Long>,sccB<Long>'))



class TestMinimumSpanningTree(TestGraphAlgorithm):

    def setUp(self):
        self.algorithm = graphalgorithm.MinimumSpanningTree()

#    def test_InputRmatOutputOS(self):
#        status = self.algorithm.run(input=graphalgorithm.RMAT,
#                                    output_path="output_test")
#        self.assertEqual(self.algorithm.outputNumFiles, 1)
#        self.assertEqual(self.algorithm.outputNumLines, 1002)

#    def test_InputRmatOutputHDFS(self):
#        status = self.algorithm.run(input=graphalgorithm.RMAT,
#                                    output_path="output_test",
#                                    output_fs=graphalgorithm.HDFS)
#        self.assertEqual(self.algorithm.outputNumFiles, 1)
#        self.assertEqual(self.algorithm.outputNumLines, 1002)
        
#    def test_RmatScale(self):
#        status = self.algorithm.run(input=graphalgorithm.RMAT,
#                                    output_path="output_test", input_rmat_scale=10)
#        self.assertEqual(self.algorithm.outputNumFiles, 1)
#        self.assertEqual(self.algorithm.outputNumLines, 1002)

#    def test_InputOSOutputOS(self):
#        gen = graphalgorithm.GenerateGraph()
#        gen.run(output_path="input_test")
#        self.algorithm.run(input=graphalgorithm.FILE,
#                           input_path="input_test",
#                           output_path="output_test",
#                           extra_options=["--enable-log-global"])
#        self.assertEqual(self.algorithm.outputNumFiles, 1)
#        self.assertEqual(self.algorithm.outputNumLines, 1002)

#    def test_InputHDFSOutputHDFS(self):
#        gen = graphalgorithm.GenerateGraph()
#        gen.run(output_path="input_test", output_fs=graphalgorithm.HDFS)
#        self.algorithm.run(input=graphalgorithm.FILE,
#                           input_path="input_test",
#                           input_fs=graphalgorithm.HDFS,
#                           output_path="output_test",
#                           output_fs=graphalgorithm.HDFS)
#        self.assertEqual(self.algorithm.outputNumFiles, 1)
#        self.assertEqual(self.algorithm.outputNumLines, 1002)

#    def test_ReadWeight(self):
#        gen = graphalgorithm.GenerateGraph()
#        gen.run(output_path="input_test")
#        self.algorithm.run(input=graphalgorithm.FILE,
#                           input_path="input_test",
#                           output_path="output_test",
#                           extra_options=["--input-data-file-weight-csv"])
#        self.assertEqual(self.algorithm.outputNumFiles, 4)
#        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')

#    def test_RandomWeight(self):
#        gen = graphalgorithm.GenerateGraph()
#        gen.run(output_path="input_test",
#                extra_options=["--output-data-file-header-weight=ignore_this"])
#        self.algorithm.run(input=graphalgorithm.FILE,
#                           input_path="input_test",
#                           output_path="output_test",
#                           extra_options=["--input-data-file-weight-random"])
#        self.assertEqual(self.algorithm.outputNumFiles, 4)
#        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')

#    def test_ErrorNoConstWeight(self):
#        gen = graphalgorithm.GenerateGraph()
#        gen.run(output_path="input_test",
#                extra_options=["--output-data-file-header-weight=ignore_this"])
#        with self.assertRaises(graphalgorithm.ScaleGraphError):
#            self.algorithm.run(input=graphalgorithm.FILE,
#                               input_path="input_test",
#                               output_path="output_test",
#                               extra_options=["--input-data-file-weight-constant"])

#    def test_ConstWeight(self):
#        gen = graphalgorithm.GenerateGraph()
#        gen.run(output_path="input_test",
#                extra_options=["--output-data-file-header-weight=ignore_this"])
#        with self.assertRaises(graphalgorithm.ScaleGraphError):
#            self.algorithm.run(input=graphalgorithm.FILE,
#                               input_path="input_test",
#                               output_path="output_test",
#                               extra_options=["--input-data-file-weight-constant=0.5"])
#        self.assertEqual(self.algorithm.outputNumFiles, 4)
#        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')

#     def test_ChangeWeightHeader(self):
#        gen = graphalgorithm.GenerateGraph()
#        gen.run(output_path="input_test",
#                extra_options=["--output-data-file-header-weight=changed-weight"])
#        self.algorithm.run(input=graphalgorithm.FILE,
#                           input_path="input_test",
#                           output_path="output_test",
#                           extra_options=["--input-data-file-header-weight=changed-weight"])
#        self.assertEqual(self.algorithm.outputNumFiles, 4)
#        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')

#    def test_ErrorReadWeight(self):
#        gen = graphalgorithm.GenerateGraph()
#        gen.run(output_path="input_test",
#                extra_options=["--output-data-file-header-weight=cause-error"])
#        self.algorithm.run(input=graphalgorithm.FILE,
#                           input_path="input_test",
#                           output_path="output_test")
    
#    def test_ChangeEdgeHeader(self):
#        gen = graphalgorithm.GenerateGraph()
#        gen.run(output_path="input_test",
#                extra_options=["--output-data-file-header-source=newheader",
#                               "--output-data-file-header-target=newtarget"])
#        self.algorithm.run(input=graphalgorithm.FILE,
#                           input_path="input_test",
#                           output_path="output_test",
#                           extra_options=["--input-data-file-header-source=newheader",
#                                          "--input-data-file-header-target=newtarget"])
#        self.assertEqual(self.algorithm.outputNumFiles, 4)
#        self.assertEqual(self.algorithm.outputHeader, 'ID<Long>,bc<Double>')
        

        
class TestMaxFlow(unittest.TestCase):

    def setUp(self):
        self.algorithm = graphalgorithm.MaxFlow()

    def test_ErrorNoInput(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            result = self.algorithm.run(source_id=0, sink_id=1)

    def test_ErrorNoInputFilePath(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            result = self.algorithm.run(input=graphalgorithm.FILE,
                                        source_id=0, sink_id=1)
            
    def test_ErrorInvalidInputFs(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            result = self.algorithm.run(input=graphalgorithm.FILE,
                                        input_path=123,
                                        input_fs=99999,
                                        source_id=0, sink_id=1)

    def test_ErrorNotStrInputFilePath(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            result = self.algorithm.run(input=graphalgorithm.FILE,
                                        input_path=123,
                                        source_id=0, sink_id=1)

    def test_ErrorInvalidRmatScale(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            result = self.algorithm.run(input=graphalgorithm.RMAT,
                                        input_rmat_scale="abc",
                                        source_id=0, sink_id=1)

    def test_ErrorInvalidInput(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            result = self.algorithm.run(input=99999,
                                        source_id=0, sink_id=1)

    def test_ErrorNoSourceIdNoSinkId(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            result = self.algorithm.run(input=graphalgorithm.RMAT)

    def test_ErrorNoSourceId(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            result = self.algorithm.run(input=graphalgorithm.RMAT,
                                        sink_id=1)
            
    def test_ErrorNoSinkId(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            result = self.algorithm.run(input=graphalgorithm.RMAT,
                                        source_id=1)

    def test_ErrorSourceIdEqualSinkId(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            result = self.algorithm.run(input=graphalgorithm.RMAT,
                                        source_id=1, sink_id=1)

    def test_ErrorInvalidSourceId(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            result = self.algorithm.run(input=graphalgorithm.RMAT,
                                        source_id="abc", sink_id=1)

    def test_ErrorInvalidSinkId(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            result = self.algorithm.run(input=graphalgorithm.RMAT,
                                        source_id=0, sink_id="abc")

    def test_ErrorTypeExtraOptions(self):
        with self.assertRaises(graphalgorithm.ArgumentError):
            result = self.algorithm.run(input=graphalgorithm.RMAT,
                                        source_id=0, sink_id=1,
                                        extra_options=99999)

    def test_ErrorInvalidExtraOptions(self):
        with self.assertRaises(graphalgorithm.ScaleGraphError):
            result = self.algorithm.run(input=graphalgorithm.RMAT,
                                        source_id=0, sink_id=1,
                                        extra_options=["--cause-error"])
    
    def test_ErrorNoValueInputHeaderSource(self):
        with self.assertRaises(graphalgorithm.ScaleGraphError):
            result = self.algorithm.run(input=graphalgorithm.RMAT,
                                        source_id=0, sink_id=1,
                                        extra_options=["--input-data-file-header-source"])

    def test_ErrorNoValueInputHeaderTarget(self):
        with self.assertRaises(graphalgorithm.ScaleGraphError):
            result = self.algorithm.run(input=graphalgorithm.RMAT,
                                        source_id=0, sink_id=1,
                                        extra_options=["--input-data-file-header-target"])

    def test_ErrorNoValueInputHeaderWeight(self):
        with self.assertRaises(graphalgorithm.ScaleGraphError):
            result = self.algorithm.run(input=graphalgorithm.RMAT,
                                        source_id=0, sink_id=1,
                                        extra_options=["--input-data-file-header-weight"])

    def test_InputRmat(self):
        result = self.algorithm.run(input=graphalgorithm.RMAT,
                                    source_id=0, sink_id=1)
        self.assertEqual(result, 0.0)

    def test_RmatScale(self):
        result = self.algorithm.run(input=graphalgorithm.RMAT,
                                    input_rmat_scale=6,
                                    source_id=0, sink_id=1)
        self.assertEqual(result, 0.0)

    def test_InputOS(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test")
        result = self.algorithm.run(input=graphalgorithm.FILE,
                                    input_path="input_test",
                                    source_id=0, sink_id=1)
        self.assertEqual(result, 0.0)

    def test_InputHDFS(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test", output_fs=graphalgorithm.HDFS)
        result = self.algorithm.run(input=graphalgorithm.FILE,
                                    input_path="input_test",
                                    input_fs=graphalgorithm.HDFS,
                                    source_id=0, sink_id=1)
        self.assertEqual(result, 0.0)

    def test_ReadWeight(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test")
        result = self.algorithm.run(input=graphalgorithm.FILE,
                                    input_path="input_test",
                                    source_id=0, sink_id=1,
                                    extra_options=["--input-data-file-weight-csv"])
        self.assertEqual(result, 0.0)

    def test_RandomWeight(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test",
                extra_options=["--output-data-file-header-weight=ignore_this"])
        result = self.algorithm.run(input=graphalgorithm.FILE,
                                    input_path="input_test",
                                    source_id=0, sink_id=1,
                                    extra_options=["--input-data-file-weight-random"])
        self.assertEqual(result, 0.0)

    def test_ErrorNoConstWeight(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test",
                extra_options=["--output-data-file-header-weight=ignore_this"])
        with self.assertRaises(graphalgorithm.ScaleGraphError):
            result = self.algorithm.run(input=graphalgorithm.FILE,
                                        input_path="input_test",
                                        source_id=0, sink_id=1,
                                        extra_options=["--input-data-file-weight-constant"])
        
    def test_ConstWeight(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test",
                extra_options=["--output-data-file-header-weight=ignore_this"])
        result = self.algorithm.run(input=graphalgorithm.FILE,
                                    input_path="input_test",
                                    source_id=0, sink_id=1,
                                    extra_options=["--input-data-file-weight-constant=0.5"])
        self.assertEqual(result, 0.0)

    def test_ChangeWeightHeader(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test",
                extra_options=["--output-data-file-header-weight=changed-weight"])
        result = self.algorithm.run(input=graphalgorithm.FILE,
                                    input_path="input_test",
                                    source_id=0, sink_id=1,
                                    extra_options=["--input-data-file-header-weight=changed-weight"])
        self.assertEqual(result, 0.0)
        
    def test_ErrorReadWeight(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test",
                extra_options=["--output-data-file-header-weight=cause-error"])
        with self.assertRaises(graphalgorithm.ScaleGraphError):
            result = self.algorithm.run(input=graphalgorithm.FILE,
                                        input_path="input_test",
                                        source_id=0, sink_id=1)

    def test_ChangeEdgeHeader(self):
        gen = graphalgorithm.GenerateGraph()
        gen.run(output_path="input_test",
                extra_options=["--output-data-file-header-source=newheader",
                               "--output-data-file-header-target=newtarget"])
        result = self.algorithm.run(input=graphalgorithm.FILE,
                                    input_path="input_test",
                                    source_id=0, sink_id=1,
                                    extra_options=["--input-data-file-header-source=newheader",
                                                   "--input-data-file-header-target=newtarget"])
        self.assertEqual(result, 0.0)



class TestSpectralClustering(TestGraphAlgorithm):

    def setUp(self):
        self.algorithm = graphalgorithm.SpectralClustering()

#    def test_InputRmatOutputOS(self):
#        status = self.algorithm.run(input=graphalgorithm.RMAT,
#                                    output_path="output_test")
#        self.assertEqual(self.algorithm.outputNumFiles, 1)
#        self.assertEqual(self.algorithm.outputNumLines, 1002)

#    def test_InputRmatOutputHDFS(self):
#        status = self.algorithm.run(input=graphalgorithm.RMAT,
#                                    output_path="output_test",
#                                    output_fs=graphalgorithm.HDFS)
#        self.assertEqual(self.algorithm.outputNumFiles, 1)
#        self.assertEqual(self.algorithm.outputNumLines, 1002)
        
#    def test_RmatScale(self):
#        status = self.algorithm.run(input=graphalgorithm.RMAT,
#                                    output_path="output_test", input_rmat_scale=10)
#        self.assertEqual(self.algorithm.outputNumFiles, 1)
#        self.assertEqual(self.algorithm.outputNumLines, 1002)

#    def test_InputOSOutputOS(self):
#        gen = graphalgorithm.GenerateGraph()
#        gen.run(output_path="input_test")
#        self.algorithm.run(input=graphalgorithm.FILE,
#                           input_path="input_test",
#                           output_path="output_test")
#        self.assertEqual(self.algorithm.outputNumFiles, 1)
#        self.assertEqual(self.algorithm.outputNumLines, 1002)

#    def test_InputHDFSOutputHDFS(self):
#        gen = graphalgorithm.GenerateGraph()
#        gen.run(output_path="input_test", output_fs=graphalgorithm.HDFS)
#        self.algorithm.run(input=graphalgorithm.FILE,
#                           input_path="input_test",
#                           input_fs=graphalgorithm.HDFS,
#                           output_path="output_test",
#                           output_fs=graphalgorithm.HDFS)
#        self.assertEqual(self.algorithm.outputNumFiles, 1)
#        self.assertEqual(self.algorithm.outputNumLines, 1002)

#    def test_ExtraOptions(self):
#        status = self.algorithm.run(input=graphalgorithm.RMAT,
#                                    output_path="output_test",
#                                    extra_options=["--hanf-niter=100"])
#        self.assertEqual(self.algorithm.outputNumFiles, 1)
#        self.assertEqual(self.algorithm.outputNumLines, 102)

#    def test_NotReadWeight(self):
#        gen = graphalgorithm.GenerateGraph()
#        gen.run(output_path="input_test",
#                extra_options=["--output-data-file-header-weight=not-read"])
#        self.algorithm.run(input=graphalgorithm.FILE,
#                           input_path="input_test",
#                           output_path="output_test")
#        self.assertEqual(self.algorithm.outputNumFiles, 1)
#        self.assertEqual(self.algorithm.outputNumLines, 1002)

        
if __name__ == '__main__':
    
    suiteGenerateGraph = unittest.TestLoader().loadTestsFromTestCase(TestGenerateGraph)
    suitePageRank = unittest.TestLoader().loadTestsFromTestCase(TestPageRank)
    suiteDegreeDistribution = unittest.TestLoader().loadTestsFromTestCase(TestDegreeDistribution)
    suiteBetweennessCentrality = unittest.TestLoader().loadTestsFromTestCase(TestBetweennessCentrality)
    suiteHyperANF = unittest.TestLoader().loadTestsFromTestCase(TestHyperANF)
    suiteStronglyConnectedComponent = unittest.TestLoader().loadTestsFromTestCase(TestStronglyConnectedComponent)
    suiteMinimumSpanningTree = unittest.TestLoader().loadTestsFromTestCase(TestMinimumSpanningTree)
    suiteMaxFlow = unittest.TestLoader().loadTestsFromTestCase(TestMaxFlow)
    suiteSpectralClustering = unittest.TestLoader().loadTestsFromTestCase(TestSpectralClustering)
    
    suiteAll = unittest.TestSuite([
        suiteGenerateGraph,
        suitePageRank,
        suiteDegreeDistribution,
        suiteBetweennessCentrality,
        suiteHyperANF,
        suiteStronglyConnectedComponent,
        suiteMinimumSpanningTree,
        suiteMaxFlow,
        suiteSpectralClustering])
#    suiteAll = unittest.TestSuite([suiteMinimumSpanningTree])
    runner = unittest.TextTestRunner(verbosity=2)
    runner.run(suiteAll)
    
