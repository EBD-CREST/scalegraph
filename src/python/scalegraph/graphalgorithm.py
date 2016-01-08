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

import subprocess
import json
import config

OS = 231
HDFS = 820
FILE = 133
RMAT = 214


class ArgumentError(Exception):
    pass

class HDFSError(Exception):
    pass

class OSError(Exception):
    pass

class ConfigError(Exception):
    pass

class ScaleGraphError(Exception):
    pass


class GraphAlgorithm:

    def __init__(self):
        pass

    def checkInputArgument(self, input,
                           input_path, input_fs,
                           input_rmat_scale):
        args = []
        if input is None:
            raise ArgumentError("input must be specified")
        elif input == FILE:
            if input_path is None:
                raise ArgumentError("input_path must be specified")
            elif type(input_path) == str:
                args.append("--input-data-file=" + input_path)
                if input_fs == OS:
                    args.append("--input-fs-os")
                elif input_fs == HDFS:
                    args.append("--input-fs-hdfs")
                else:
                    raise ArgumentError("invalid input_fs")
            else:
                raise ArgumentError("input_path must be a string")
        elif input == RMAT:
            args.append("--input-data-rmat")
            if type(input_rmat_scale) == int:
                args.append("--input-data-rmat-scale=" + str(input_rmat_scale))
            else:
                raise ArgumentError("invalid input_rmat_scale")
        else:
            raise ArgumentError("invalid input")
        return args

    def checkOutputArgument(self,
                            output_path, output_fs):
        args = []
        if output_path is None:
            raise ArgumentError("output_path must be specified")
        elif type(output_path) == str:
            args.append("--output-data-file=" + output_path)
            if output_fs == OS:
                args.append("--output-fs-os")
            elif output_fs == HDFS:
                args.append("--output-fs-hdfs")
            else:
                raise ArgumentError("invalid output_fs")
        else:
            raise ArgumentError("output_path must be a string")
        return args

    def checkOutput1Argument(self,
                             output1_path, output1_fs):
        args = []
        if output1_path is None:
            raise ArgumentError("output1_path must be specified")
        elif type(output1_path) == str:
            args.append("--output1-data-file=" + output1_path)
            if output1_fs == OS:
                args.append("--output1-fs-os")
            elif output1_fs == HDFS:
                args.append("--output1-fs-hdfs")
            else:
                raise ArgumentError("invalid output1_fs")
        else:
            raise ArgumentError("output1_path must be a string")
        return args

    def checkOutput2Argument(self,
                             output2_path, output2_fs):
        args = []
        if output2_path is None:
            raise ArgumentError("output2_path must be specified")
        elif type(output2_path) == str:
            args.append("--output2-data-file=" + output2_path)
            if output2_fs == OS:
                args.append("--output2-fs-os")
            elif output2_fs == HDFS:
                args.append("--output2-fs-hdfs")
            else:
                raise ArgumentError("invalid output2_fs")
        else:
            raise ArgumentError("output2_path must be a string")
        return args
    
    
    def checkExtraArgument(self,
                           extra_options):
        args = []
        if type(extra_options) == list:
            args.extend(extra_options)
        else:
            raise ArgumentError("extra_options must be a list")
        return args

    def cleanOutputOS(self, path):
        try:
            subprocess.run(['rm', '-rf', path],
                           stderr=subprocess.DEVNULL,
                           cwd=config.work_dir)
        except:
            raise ConfigError("config problem for os command")

    def cleanOutputHDFS(self, path):
        try:
            proc = subprocess.run(['hdfs', 'dfs', '-rm', '-f', '-r', path],
                                  stdout=subprocess.DEVNULL,
                                  stderr=subprocess.DEVNULL)
        except:
            raise ConfigError("config problem for hdfs command")

    def checkAvailHDFS(self):
        try:
            proc = subprocess.run(['hdfs', 'dfs', '-ls', '.'],
                                  stdout=subprocess.DEVNULL,
                                  stderr=subprocess.DEVNULL)
        except:
            raise ConfigError("failed to run hdfs command")
        if proc.returncode != 0:
            raise ConfigError("no hdfs default dir")

    def checkOutputDirOS(self, path):
        try:
            proc = subprocess.run("ls -l " + path + "/* | wc",
                                  cwd=config.work_dir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True,
                                  shell=True)
            numFiles = int(proc.stdout.split()[0])
            proc = subprocess.run("wc " + path + "/* | tail -1",
                                  cwd=config.work_dir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True,
                                  shell=True)
            numLines = int(proc.stdout.split()[0])
            proc = subprocess.run("head -1 " + path + "/part-00000",
                                  cwd=config.work_dir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True,
                                  shell=True)
            header = proc.stdout.splitlines()[0]
        except:
            raise ConfigError("output not found or check fail")
        return (numFiles, numLines, header)

    def checkOutputFileOS(self, path):
        try:
            proc = subprocess.run("ls -l " + path + " | wc",
                                  cwd=config.work_dir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True,
                                  shell=True)
            numFiles = int(proc.stdout.split()[0])
            proc = subprocess.run("wc " + path,
                                  cwd=config.work_dir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True,
                                  shell=True)
            numLines = int(proc.stdout.split()[0])
            proc = subprocess.run("head -1 " + path,
                                  cwd=config.work_dir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True,
                                  shell=True)
            header = proc.stdout.splitlines()[0]
        except:
            raise ConfigError("output not found or check fail")
        return (numFiles, numLines, header)
    
    def checkOutputDirHDFS(self, path):
        try:
            proc = subprocess.run("hdfs dfs -ls " + path + "/* | wc",
                                  cwd=config.work_dir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True,
                                  shell=True)
            numFiles = int(proc.stdout.split()[0])
            proc = subprocess.run("hdfs dfs -cat " + path + "/* | wc",
                                  cwd=config.work_dir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True,
                                  shell=True)
            numLines = int(proc.stdout.split()[0])
            proc = subprocess.run("hdfs dfs -cat " + path + "/part-00000 | head -1",
                                  cwd=config.work_dir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True,
                                  shell=True)
            header = proc.stdout.splitlines()[0]
        except:
            raise ConfigError("output not found or check fail")
        return (numFiles, numLines, header)

    def checkOutputFileHDFS(self, path):
        try:
            proc = subprocess.run("hdfs dfs -ls " + path + " | wc",
                                  cwd=config.work_dir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True,
                                  shell=True)
            numFiles = int(proc.stdout.split()[0])
            proc = subprocess.run("hdfs dfs -cat " + path + " | wc",
                                  cwd=config.work_dir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True,
                                  shell=True)
            numLines = int(proc.stdout.split()[0])
            proc = subprocess.run("hdfs dfs -cat " + path + " | head -1",
                                  cwd=config.work_dir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True,
                                  shell=True)
            header = proc.stdout.splitlines()[0]
        except:
            raise ConfigError("output not found or check fail")
        return (numFiles, numLines, header)

    def checkOutputDir(self, output_path, output_fs):
        if output_fs == OS:
            return self.checkOutputDirOS(output_path)
        elif output_fs == HDFS:
            return self.checkOutputDirHDFS(output_path)

    def checkOutputFile(self, output_path, output_fs):
        if output_fs == OS:
            return self.checkOutputFileOS(output_path)
        elif output_fs == HDFS:
            return self.checkOutputFileHDFS(output_path)

    def cleanOutput(self, output_path, output_fs):
        if output_fs == OS:
            self.cleanOutputOS(output_path)
        elif output_fs == HDFS:
            self.checkAvailHDFS()
            self.cleanOutputHDFS(output_path)

    def callApiDriver(self, args):
       
        commandline = [config.mpirun_path] + config.mpirun_opts + \
                      [config.apidriver_path, self.algorithmName] + args
#        print(commandline)

        try:
            proc = subprocess.run(commandline,
                                  cwd = config.work_dir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True)
        except:
            raise ConfigError("failed to mpirun apidriver")
        
        try:
#            print(proc.stdout)
            result = json.loads(proc.stdout.splitlines()[0])
            rval = int(result['Status'])
        except:
            raise ConfigError("unexpected stop of apidriver")

        if rval != 0:
            raise ScaleGraphError("apidriver status " + str(result['Status']))

        return result

class GenerateGraph(GraphAlgorithm):

    def __init__(self):

        super(GenerateGraph, self).__init__()
        self.algorithmName = 'gen'

    def run(self,
            input=RMAT,
            input_rmat_scale=8,
            output_path=None, output_fs=OS,
            extra_options=[]):

        args = []
        if type(input_rmat_scale) == int:
            args.append("--input-data-rmat-scale=" + str(input_rmat_scale))
        else:
            raise ArgumentError("invalid input_rmat_scale")
        args += self.checkOutputArgument(output_path, output_fs)
        args += self.checkExtraArgument(extra_options)

        self.cleanOutput(output_path, output_fs)
        self.callApiDriver(args)
        self.outputSummary = self.checkOutputDir(output_path, output_fs)
        (self.outputNumFiles, self.outputNumLines, self.outputHeader) = self.outputSummary           
        
class PageRank(GraphAlgorithm):

    def __init__(self):

        super(PageRank, self).__init__()
        self.algorithmName = 'pr'

    def run(self,
            input=None,
            input_path=None, input_fs=OS,
            input_rmat_scale=8,
            output_path=None, output_fs=OS,
            extra_options=[]):

        args = []
        args += self.checkInputArgument(input,
                                        input_path, input_fs,
                                        input_rmat_scale)
        args += self.checkOutputArgument(output_path, output_fs)
        args += self.checkExtraArgument(extra_options)

        self.cleanOutput(output_path, output_fs)
        self.callApiDriver(args)
        self.outputSummary = self.checkOutputDir(output_path, output_fs)
        (self.outputNumFiles, self.outputNumLines, self.outputHeader) = self.outputSummary       

class DegreeDistribution(GraphAlgorithm):

    def __init__(self):

        super(DegreeDistribution, self).__init__()
        self.algorithmName = 'dd'

    def run(self,
            input=None,
            input_path=None, input_fs=OS,
            input_rmat_scale=8,
            output_path=None, output_fs=OS,
            extra_options=[]):

        args = []
        args += self.checkInputArgument(input,
                                        input_path, input_fs,
                                        input_rmat_scale)
        args += self.checkOutputArgument(output_path, output_fs)
        args += self.checkExtraArgument(extra_options)

        self.cleanOutput(output_path, output_fs)
        self.callApiDriver(args)
        self.outputSummary = self.checkOutputDir(output_path, output_fs)
        (self.outputNumFiles, self.outputNumLines, self.outputHeader) = self.outputSummary   

        
class BetweennessCentrality(GraphAlgorithm):

    def __init__(self):

        super(BetweennessCentrality, self).__init__()
        self.algorithmName = 'bc'

    def run(self,
            input=None,
            input_path=None, input_fs=OS,
            input_rmat_scale=8,
            output_path=None, output_fs=OS,
            extra_options=[]):

        args = []
        args += self.checkInputArgument(input,
                                        input_path, input_fs,
                                        input_rmat_scale)
        args += self.checkOutputArgument(output_path, output_fs)
        args += self.checkExtraArgument(extra_options)

        self.cleanOutput(output_path, output_fs)
        self.callApiDriver(args)
        self.checkOutputDir(output_path, output_fs)
        self.outputSummary = self.checkOutputDir(output_path, output_fs)
        (self.outputNumFiles, self.outputNumLines, self.outputHeader) = self.outputSummary   

        
class HyperANF(GraphAlgorithm):

    def __init__(self):

        super(HyperANF, self).__init__()
        self.algorithmName = 'hanf'

    def run(self,
            input=None,
            input_path=None, input_fs=OS,
            input_rmat_scale=8,
            output_path=None, output_fs=OS,
            extra_options=[]):

        args = []
        args += self.checkInputArgument(input,
                                        input_path, input_fs,
                                        input_rmat_scale)
        args += self.checkOutputArgument(output_path, output_fs)
        args += self.checkExtraArgument(extra_options)

        self.cleanOutput(output_path, output_fs)
        self.callApiDriver(args)
        self.outputSummary = self.checkOutputFile(output_path, output_fs)
        (self.outputNumFiles, self.outputNumLines, self.outputHeader) = self.outputSummary   


class StronglyConnectedComponent(GraphAlgorithm):
    
    def __init__(self):

        super(StronglyConnectedComponent, self).__init__()
        self.algorithmName = 'scc'

    def run(self,
            input=None,
            input_path=None, input_fs=OS,
            input_rmat_scale=8,
            output1_path=None, output1_fs=OS,
            output2_path=None, output2_fs=OS,
            extra_options=[]):

        args = []
        args += self.checkInputArgument(input,
                                        input_path, input_fs,
                                        input_rmat_scale)
        args += self.checkOutput1Argument(output1_path, output1_fs)
        args += self.checkOutput2Argument(output2_path, output2_fs)
        args += self.checkExtraArgument(extra_options)

        self.cleanOutput(output1_path, output1_fs)
        self.cleanOutput(output2_path, output2_fs)
        self.callApiDriver(args)
        self.output1Summary = self.checkOutputDir(output1_path, output1_fs)
        (self.output1NumFiles, self.output1NumLines, self.output1Header) = self.output1Summary   
        self.output2Summary = self.checkOutputDir(output2_path, output2_fs)
        (self.output2NumFiles, self.output2NumLines, self.output2Header) = self.output2Summary   

class MinimumSpanningTree(GraphAlgorithm):

    def __init__(self):

        super(MinimumSpanningTree, self).__init__()
        self.algorithmName = 'mst'

    def run(self,
            input=None,
            input_path=None, input_fs=OS,
            input_rmat_scale=8,
            output_path=None, output_fs=OS,
            extra_options=[]):

        args = []
        args += self.checkInputArgument(input,
                                        input_path, input_fs,
                                        input_rmat_scale)
        args += self.checkOutputArgument(output_path, output_fs)
        args += self.checkExtraArgument(extra_options)

        self.cleanOutput(output_path, output_fs)
        self.callApiDriver(args)
        self.outputSummary = self.checkOutputFile(output_path, output_fs)
        (self.outputNumFiles, self.outputNumLines, self.outputHeader) = self.outputSummary   

class MaxFlow(GraphAlgorithm):

    def __init__(self):

        super(MaxFlow, self).__init__()
        self.algorithmName = 'mf'

    def run(self,
            input=None,
            input_path=None, input_fs=OS,
            input_rmat_scale=8,
            source_id=None, sink_id=None,
            extra_options=[]):

        args = []
        args += self.checkInputArgument(input,
                                        input_path, input_fs,
                                        input_rmat_scale)
        args += self.checkSourceSinkArgument(source_id, sink_id)
        args += self.checkExtraArgument(extra_options)

        result = self.callApiDriver(args)
        try:
            maxFlow = float(result['MaxFlow'])
        except:
            raise ScaleGraphError("apidriver didn't return result")

        return maxFlow
        
    def checkSourceSinkArgument(self, source_id, sink_id):
        args = []
        if source_id is None:
            raise ArgumentError("source_id must be specified")
        if sink_id is None:
            raise ArgumentError("sink_id must be specified")
        try:
            source_id = int(source_id)
        except:
            raise ArgumentError("invalid source_id")
        try:
            sink_id = int(sink_id)
        except:
            raise ArgumentError("invalid sink_id")
        if source_id == sink_id:
            raise ArgumentError("source_id must not equal to sink_id")
        args.append("--mf-source-id=" + str(source_id))
        args.append("--mf-sink-id=" + str(sink_id))
        return args
