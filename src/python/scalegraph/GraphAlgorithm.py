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

class GraphAlgorithm:

    def __init__(self):
        print("GraphAlgorithm::init")
        self.mpirunPath = 'mpirun'
        self.mpirunOpts = ['-np', '4']
        self.scaleGraphDir = '/Users/tosiyuki/EBD/scalegraph-dev'
        self.apiDriverPath = './apidriver'

class PageRank(GraphAlgorithm):

    def __init__(self):
        print("PageRank::init")
        super(PageRank, self).__init__()
        self.algorithmName = 'pr'
        self.defaultArgs = ['--output-fs-os', '--output-data-file=output-pr']
        pass

    def run(self, args):
        proc = subprocess.run([self.mpirunPath] + self.mpirunOpts +
                              [self.apiDriverPath, self.algorithmName] + 
                              self.defaultArgs + args,
                              cwd=self.scaleGraphDir,
                              stdout=subprocess.PIPE,
                              stderr=subprocess.DEVNULL,
                              universal_newlines=True)
        result = json.loads(proc.stdout.splitlines()[0])
        return int(result['Status'])
        
    def cleanOutput(self):
        subprocess.run(['rm', '-rf', 'output-pr'],
                       cwd=self.scaleGraphDir)

    def checkOutput(self):
        proc = subprocess.run("ls -l output-pr/* | wc",
                              cwd=self.scaleGraphDir,
                              stdout=subprocess.PIPE,
                              stderr=subprocess.DEVNULL,
                              universal_newlines=True,
                              shell=True)
        numFiles = int(proc.stdout.split()[0])
        proc = subprocess.run("wc output-pr/* | tail -1",
                              cwd=self.scaleGraphDir,
                              stdout=subprocess.PIPE,
                              stderr=subprocess.DEVNULL,
                              universal_newlines=True,
                              shell=True)
        numLines = int(proc.stdout.split()[0])
        proc = subprocess.run("head -1 output-pr/part-00000",
                              cwd=self.scaleGraphDir,
                              stdout=subprocess.PIPE,
                              stderr=subprocess.DEVNULL,
                              universal_newlines=True,
                              shell=True)
        try:
            header = proc.stdout.splitlines()[0]
        except:
            header = ''
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
