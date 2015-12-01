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
osRmCmd = ['rm', '-rf']
hdfsBaseCmd = ['hdfs', 'dfs']
hdfsRmCmd = hdfsBaseCmd + ['-rm', '-f', '-r']
hdfsLsCmd = hdfsBaseCmd + ['-ls']


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

class PageRank(GraphAlgorithm):

    algorithmName = 'pr'
    
    def __init__(self):
        super(PageRank, self).__init__()
        pass

    def run(self,
            input=None,
            input_path=None, input_fs=OS,
            input_rmat_scale=8,
            output_path=None, output_fs=OS,
            extra_options=[]):
        
        args = []
        self.outputNumFiles = 0
        self.outputNumLines = 0
        self.outputHeader = ''
        
        if input is None:
            raise ArgumentError("input must be specified")
        elif input == FILE:
            if input_path is None:
                raise ArgumentError("input_path must be specified")
            elif type(input_path) == str:
                args.append("--input-data-file=" + str)
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
        
        if output_path is None:
            raise ArgumentError("output_path must be specified")
        elif type(output_path) == str:
            args.append("--output-data-file" + output_path)
            if ouput_fs == OS:
                args.append("--ouput-fs-os")
            elif output_fs == HDFS:
                args.append("--output-fs-hdfs")
            else:
                raise ArgumentError("invalid output_fs")
        else:
            raise ArgumentError("ouput_path must be a string")
        
        if type(extra_options) == list:
            args.extend(extra_options)
        else:
            raise ArgumentError("extra_options must be a list")
        
        if output_fs == OS:
            self.cleanOutputOS(output_path)
        elif output_fs == HDFS:
            self.checkAvailHDFS()
            self.cleanOutputHDFS(output_path)

        commandline = [mpirunPath] + mpirunOpts + \
                      [apiDriverPath, algorithmName] + args
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

        if output_fs == OS:
            (self.outputNumFiles, self.outputNumLines, self.outputHeader) = \
                self.checkOutputOS(output_path)
        elif output_fs == HDFS:
            (self.outputNumFiles, self.outputNumLines, self.outputHeader) = \
                self.checkOutputHDFS(output_path)
        
        return rval

    def cleanOutputOS(self, path):
        try:
            subprocess.run(osRmCmd.append(path),
                           stderr=subprocess.DEVNULL,
                           cwd=self.workDir)
        except:
            raise ConfigError("config problem for os command")

    def cleanOutputHDFS(self, path):
        try:
            proc = subprocess.run(hdfsRmCmd.append(path),
                                  stderr=subprocess.DEVNULL)
        except:
            raise ConfigError("config problem for hdfs command")

    def checkAvailHDFS(self):
        try:
            proc = subprocess.run(hdfsLsCmd.append('.'),
                                  stderr=subprocess.DEVNULL)
        except:
            raise ConfigError("failed to run hdfs command")
        if proc.returncode != 0:
            raise ConfigError("no hdfs default dir")

    def checkOutputOS(self, path):
        try:
            proc = subprocess.run("ls -l " + path + "/* | wc",
                                  cwd=self.workDir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True,
                                  shell=True)
            numFiles = int(proc.stdout.split()[0])
            proc = subprocess.run("wc " + path + "/* | tail -1",
                                  cwd=self.workDir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True,
                                  shell=True)
            numLines = int(proc.stdout.split()[0])
            proc = subprocess.run("head -1 " + path + "/part-00000",
                                  cwd=self.workDir,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True,
                                  shell=True)
            header = proc.stdout.splitlines()[0]
        except:
            raise ConfigError("output not found or check fail")
        return (numFiles, numLines, header)
    
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
