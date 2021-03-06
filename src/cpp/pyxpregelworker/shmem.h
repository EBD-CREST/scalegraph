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

public:
    struct NativePyXPregelAdapterProperty {
        long long numGlobalVertices;
        long long numLocalVertices;
        long long outEdge_offsets_size;
        long long outEdge_vertices_size;
        long long inEdge_offsets_size;
        long long inEdge_vertices_size;
        int vertexValue_type;
        long long vertexActive_mc_size;
        long long vertexShouldBeActive_mc_size;
        long long message_values_size;
        long long message_offsets_size;
        int message_value_type;
    };

    struct MapInfo {
        void* addr;
        size_t size;
    };

    struct PyXPregelMapInfo {
        MapInfo outEdge_offsets;
        MapInfo outEdge_vertices;
        MapInfo inEdge_offsets;
        MapInfo inEdge_vertices;
        MapInfo vertexValue;
        MapInfo vertexActive;
        MapInfo vertexShouldBeActive;
        MapInfo message_values;
        MapInfo message_offsets;
        MapInfo sendMsgN_values;
        MapInfo sendMsgN_flags;
    };

    static NativePyXPregelAdapterProperty* shmemProperty;
    static long long placeId;
    static long long threadId;
    static long long numThreads;

    static PyXPregelMapInfo pyXPregelMapInfo;
    
    static void MMapShmemProperty();
    //    static void ReadShmemProperty(PyObject*);
    static void DisplayShmemProperty();

    static void* MMapShmem(const char*, size_t, MapInfo*);
    static PyObject* NewMemoryViewFromShmem(void*, size_t);

    static void* CreateShmemBuffer(const char*, size_t);
    static void* MMapShmemBuffer(const char*, size_t, MapInfo*);
    static void MUnMapShmem(void*, size_t);
    
    //    static void ReadShmemOutEdge(PyObject*);
    //    static void ReadShmemInEdge(PyObject*);
    //    static void ReadShmemVertexValue(PyObject*);
};

#endif
