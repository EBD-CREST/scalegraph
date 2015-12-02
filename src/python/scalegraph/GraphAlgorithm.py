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


mpirunPath = 'mpirun'
mpirunOpts = ['-np', '4']
workDir = '/Users/tosiyuki/EBD/scalegraph-dev'
apiDriverPath = '/Users/tosiyuki/EBD/scalegraph-dev/apidriver'


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
        pass
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
                           cwd=workDir)
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

    def checkOutputOS(self, path):
        try:
            proc = subprocess.run("ls -l " + path + "/* | wc",
                                  cwd=workDir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True,
                                  shell=True)
            numFiles = int(proc.stdout.split()[0])
            proc = subprocess.run("wc " + path + "/* | tail -1",
                                  cwd=workDir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True,
                                  shell=True)
            numLines = int(proc.stdout.split()[0])
            proc = subprocess.run("head -1 " + path + "/part-00000",
                                  cwd=workDir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True,
                                  shell=True)
            header = proc.stdout.splitlines()[0]
        except:
            raise ConfigError("output not found or check fail")
        return (numFiles, numLines, header)

    def checkOutputHDFS(self, path):
        try:
            proc = subprocess.run("hdfs dfs -ls " + path + "/* | wc",
                                  cwd=workDir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True,
                                  shell=True)
            numFiles = int(proc.stdout.split()[0])
            proc = subprocess.run("hdfs dfs -cat " + path + "/* | wc",
                                  cwd=workDir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True,
                                  shell=True)
            numLines = int(proc.stdout.split()[0])
            proc = subprocess.run("hdfs dfs -cat " + path + "/part-00000 | head -1",
                                  cwd=workDir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True,
                                  shell=True)
            header = proc.stdout.splitlines()[0]
        except:
            raise ConfigError("output not found or check fail")
        return (numFiles, numLines, header)

    def cleanOutput(self, output_path, output_fs):
        if output_fs == OS:
            self.cleanOutputOS(output_path)
        elif output_fs == HDFS:
            self.checkAvailHDFS()
            self.cleanOutputHDFS(output_path)

    def callApiDriver(self, args, output_path, output_fs):
        self.cleanOutput(output_path, output_fs)
        self.outputNumFiles = 0
        self.outputNumLines = 0
        self.outputHeader = ''
        self.outputSummary = (self.outputNumFiles, self.outputNumLines, self.outputHeader)

        commandline = [mpirunPath] + mpirunOpts + \
                      [apiDriverPath, self.algorithmName] + args
#        print(commandline)

        try:
            proc = subprocess.run(commandline,
                                  cwd = workDir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True)
        except:
            raise ConfigError("failed to mpirun apidriver")
        
        try:
            result = json.loads(proc.stdout.splitlines()[0])
            rval = int(result['Status'])
        except:
            raise ConfigError("unexpected stop of apidriver")

        if rval == 0:
            if output_fs == OS:
                (self.outputNumFiles, self.outputNumLines, self.outputHeader) = \
                    self.checkOutputOS(output_path)
            elif output_fs == HDFS:
                (self.outputNumFiles, self.outputNumLines, self.outputHeader) = \
                    self.checkOutputHDFS(output_path)
            self.outputSummary = (self.outputNumFiles, self.outputNumLines, self.outputHeader)
        else:
            raise ScaleGraphError("apidriver status " + str(result['Status']))
        

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

        self.callApiDriver(args, output_path, output_fs)

        
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

        self.callApiDriver(args, output_path, output_fs)
    
    def doTest(self):

        for pattern in PageRank.testPatterns:
            args = pattern["args"]
            self.cleanOutput()
            status = self.run(args)
            print(status)
            output = self.checkOutput()
            print(output)

    testPatterns = [
        {"args":
         []
         },
        {"args":
         ["--input-data-rmat-scale=12"]
         },
        {"args":
         ["--damping=0.95", "--eps=0.002", "--niter=50"]
         }
        ]


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

        self.callApiDriver(args, output_path, output_fs)

        
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

        self.callApiDriver(args, output_path, output_fs)
    

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

        self.callApiDriver(args, output_path, output_fs)
    
        
