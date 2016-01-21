/* 
 *  This file is part of the ScaleGraph project (http://scalegraph.org).
 * 
 *  This file is licensed to You under the Eclipse Public License (EPL);
 *  You may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *      http://www.opensource.org/licenses/eclipse-1.0.php
 * 
 *  (C) Copyright ScaleGraph Team 2011-2016.
 */

#ifndef __SHMEM_H
#define __SHMEM_H

class Shmem {

    struct NativePyXPregelAdapterProperty {
        long long outEdge_offsets_size;
        long long outEdge_vertexes_size;
        long long inEdge_offsets_size;
        long long inEdge_vertexes_size;
        long long vertexValue_size;
        int vertexValue_type;
        long long vertexActive_mc_size;
        long long vertexShouldBeActive_mc_size;
        long long message_values_size;
        long long message_offsets_size;
        int message_value_type;
        long long vertex_range_min;
        long long vertex_range_max;
    };

    static NativePyXPregelAdapterProperty* shmemProperty;
    static long long placeId;
    
public:
    static void MMapShmemProperty(long long);
    static void ReadShmemProperty();
    static void DisplayShmemProperty();
    
};

#endif
