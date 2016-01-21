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

#include <Python.h>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "shmem.h"
#include "type.h"

Shmem::NativePyXPregelAdapterProperty* Shmem::shmemProperty = NULL;
long long Shmem::placeId = -1;

void
Shmem::MMapShmemProperty(long long place_id) {

    size_t namelen = 128;
    char* name = new char[namelen];

    placeId = place_id;
    snprintf(name, namelen, "/pyxpregel.place.%lld", place_id);

    int shmfd = shm_open(name, O_RDONLY, 0);
    if (shmfd < 0) {
        perror(name);
        exit(1);
    }
        
    struct stat fs;
    fstat(shmfd, &fs);
    shmemProperty = static_cast<NativePyXPregelAdapterProperty*>(mmap(NULL, fs.st_size, PROT_READ, MAP_SHARED, shmfd, 0));

    close(shmfd);
}


void
Shmem::DisplayShmemProperty() {

    if (shmemProperty == NULL ||
        reinterpret_cast<long long>(shmemProperty) == -1) {
        fprintf(stderr, "[%lld] NONE\n", placeId);
        return;
    }

#define DISPLAYPROPLL(ID) \
    fprintf(stderr, "[%lld] " #ID " = %lld\n", placeId, shmemProperty->ID);
#define DISPLAYPROPI(ID) \
    fprintf(stderr, "[%lld] " #ID " = %d\n", placeId, shmemProperty->ID);

    DISPLAYPROPLL(outEdge_offsets_size);
    DISPLAYPROPLL(outEdge_vertexes_size);
    DISPLAYPROPLL(inEdge_offsets_size);
    DISPLAYPROPLL(inEdge_vertexes_size);
    DISPLAYPROPLL(vertexValue_size);
    DISPLAYPROPI(vertexValue_type);
    DISPLAYPROPLL(vertexActive_mc_size);
    DISPLAYPROPLL(vertexShouldBeActive_mc_size);
    DISPLAYPROPLL(message_values_size);
    DISPLAYPROPLL(message_offsets_size);
    DISPLAYPROPI(message_value_type);
    DISPLAYPROPLL(vertex_range_min);
    DISPLAYPROPLL(vertex_range_max);
}


void*
Shmem::MMapShmemMemoryChunk(const char* mc_name) {

    size_t namelen = 128;
    char* name = new char[namelen];

    //    placeId = place_id;
    snprintf(name, namelen, "/pyxpregel.%s.%lld", mc_name, placeId);

    int shmfd = shm_open(name, O_RDONLY, 0);
    if (shmfd < 0) {
        perror(name);
        exit(1);
    }
        
    struct stat fs;
    fstat(shmfd, &fs);
    void* shmem = static_cast<NativePyXPregelAdapterProperty*>(mmap(NULL, fs.st_size, PROT_READ, MAP_SHARED, shmfd, 0));
    close(shmfd);

    return shmem;
}


PyObject*
Shmem::NewMemoryViewFromMemoryChunk(void* addr, size_t size) {

    PyObject* obj = PyMemoryView_FromMemory(static_cast<char*>(addr),
                                            size, PyBUF_READ);
    assert(PyErr_Occurred() == false);

    return obj;
}


void
Shmem::ReadShmemOutEdge(PyObject* locals) {

    void* shmem_offsets = MMapShmemMemoryChunk("outEdge.offsets");
    void* shmem_vertexes = MMapShmemMemoryChunk("outEdge.vertexes");
    PyObject* obj_offsets = NewMemoryViewFromMemoryChunk(shmem_offsets,
                                                         shmemProperty->outEdge_offsets_size * sizeof(long long));
    PyObject* obj_vertexes = NewMemoryViewFromMemoryChunk(shmem_vertexes,
                                                          shmemProperty->outEdge_vertexes_size * sizeof(long long));

    PyDict_SetItemString(locals, "outEdge.offsets", obj_offsets);
    assert(PyErr_Occurred() == false);
    PyDict_SetItemString(locals, "outEdge.vertexes", obj_vertexes);
    assert(PyErr_Occurred() == false);
}


void
Shmem::ReadShmemInEdge(PyObject* locals) {
    
    void* shmem_offsets = MMapShmemMemoryChunk("inEdge.offsets");
    void* shmem_vertexes = MMapShmemMemoryChunk("inEdge.vertexes");
    PyObject* obj_offsets = NewMemoryViewFromMemoryChunk(shmem_offsets,
                                                         shmemProperty->inEdge_offsets_size * sizeof(long long));
    PyObject* obj_vertexes = NewMemoryViewFromMemoryChunk(shmem_vertexes,
                                                          shmemProperty->inEdge_vertexes_size * sizeof(long long));

    PyDict_SetItemString(locals, "inEdge.offsets", obj_offsets);
    assert(PyErr_Occurred() == false);
    PyDict_SetItemString(locals, "inEdge.vertexes", obj_vertexes);
    assert(PyErr_Occurred() == false);
}


void
Shmem::ReadShmemVertexValue(PyObject* locals) {

    void* shmem = MMapShmemMemoryChunk("vertexValue");
    PyObject* obj = NewMemoryViewFromMemoryChunk(shmem,
                                                 shmemProperty->vertexValue_size * Type::SizeOf(shmemProperty->vertexValue_type));
    
    PyDict_SetItemString(locals, "vertexValue", obj);
    assert(PyErr_Occurred() == false);
    PyDict_SetItemString(locals, "vertexValueFormat", Type::PyFormat(shmemProperty->vertexValue_type));
    assert(PyErr_Occurred() == false);

}
