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

#from pprint import pprint

#global placeId
#print("importing")
#print(placeId)

import x10xpregeladapter

def run():
    print("hogehoge")
    prefix = "[" + str(x10xpregeladapter.placeId()) + ":" + str(x10xpregeladapter.threadId()) + "] "
    print(prefix + "outEdge_offsets_size = " + str(x10xpregeladapter.outEdge_offsets_size()))
    print(prefix + "outEdge_vertexes_size = " + str(x10xpregeladapter.outEdge_vertexes_size()))
    
#    global placeId
#    print(placeId)
#    print("-----globals----->>>")
#    pprint(globals())
#    print("-----locals----->>>")
#    pprint(locals())


    
