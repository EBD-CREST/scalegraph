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
long long Shmem::threadId = -1;
long long Shmem::numThreads = -1;
Shmem::PyXPregelMapInfo Shmem::pyXPregelMapInfo = {};

void
Shmem::MMapShmemProperty() {

    size_t namelen = 128;
    char* name = new char[namelen];

    snprintf(name, namelen, "/pyxpregel.place.%lld", placeId);
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

    DISPLAYPROPLL(numGlobalVertices);
    DISPLAYPROPLL(numLocalVertices);
    DISPLAYPROPLL(outEdge_offsets_size);
    DISPLAYPROPLL(outEdge_vertices_size);
    DISPLAYPROPLL(inEdge_offsets_size);
    DISPLAYPROPLL(inEdge_vertices_size);
    DISPLAYPROPI(vertexValue_type);
    DISPLAYPROPLL(vertexActive_mc_size);
    DISPLAYPROPLL(vertexShouldBeActive_mc_size);
    DISPLAYPROPLL(message_values_size);
    DISPLAYPROPLL(message_offsets_size);
    DISPLAYPROPI(message_value_type);
}


#if 0
void
Shmem::ReadShmemProperty(PyObject* dict) {

    PyObject* obj;

    obj = PyLong_FromLongLong(placeId);
    PyDict_SetItemString(dict, "placeId", obj);
    obj = PyLong_FromLongLong(threadId);
    PyDict_SetItemString(dict, "threadId", obj);
    
#define READPROPLL(ID) \
    obj = PyLong_FromLongLong(shmemProperty->ID);\
    PyDict_SetItemString(dict, #ID, obj);
#define READPROPI(ID) \
    obj = PyLong_FromLong((long) shmemProperty->ID); \
    PyDict_SetItemString(dict, #ID, obj);
    
    READPROPLL(numGlobalVertices);
    READPROPLL(numLocalVertices);
    READPROPLL(outEdge_offsets_size);
    READPROPLL(outEdge_vertices_size);
    READPROPLL(inEdge_offsets_size);
    READPROPLL(inEdge_vertices_size);
    READPROPI(vertexValue_type);
    READPROPLL(vertexActive_mc_size);
    READPROPLL(vertexShouldBeActive_mc_size);
    READPROPLL(message_values_size);
    READPROPLL(message_offsets_size);
    READPROPI(message_value_type);
}
#endif


void*
Shmem::MMapShmem(const char* mc_name, size_t size, MapInfo* oldMap) {

    size_t namelen = 128;
    char* name = new char[namelen];

    if (oldMap->addr != NULL) {
        munmap(oldMap->addr, oldMap->size);
    }

    snprintf(name, namelen, "/pyxpregel.%s.%lld", mc_name, placeId);
    int shmfd = shm_open(name, O_RDWR, 0);
    if (shmfd < 0) {
        perror(name);
        exit(1);
    }
        
    struct stat fs;
    fstat(shmfd, &fs);
    assert (fs.st_size >= size);

    if (size == 0) {
        size = fs.st_size;
    }
    
    void* shmem = mmap(NULL, size, PROT_READ|PROT_WRITE, MAP_SHARED, shmfd, 0);
    close(shmfd);

    oldMap->addr = shmem;
    oldMap->size = size;

    return shmem;
}


PyObject*
Shmem::NewMemoryViewFromShmem(void* addr, size_t size) {

    PyObject* obj = PyMemoryView_FromMemory(static_cast<char*>(addr),
                                            size, PyBUF_WRITE);
    assert(PyErr_Occurred() == false);

    return obj;
}


/* Shmem::CreateShmemBuffer
 * Allocate new shared memory to return array to the parent process
 */
void*
Shmem::CreateShmemBuffer(const char* mc_name, size_t size)  {

    size_t namelen = 128;
    char* name = new char[namelen];

    snprintf(name, namelen, "/pyxpregel.%s.%lld.%lld", mc_name, placeId, threadId);

    shm_unlink(name);
    int shmfd = shm_open(name, O_RDWR|O_CREAT, 0664);
    if (shmfd < 0) {
        perror(name);
        exit(1);
    }
    if (ftruncate(shmfd, size) < 0) {
        perror(name);
        exit(1);
    }
    
    void* shmem = mmap(NULL, size, PROT_READ|PROT_WRITE, MAP_SHARED, shmfd, 0);
    close(shmfd);

    return shmem;
}

void*
Shmem::MMapShmemBuffer(const char* mc_name, size_t size, MapInfo* oldMap) {

    size_t namelen = 128;
    char* name = new char[namelen];

    if (oldMap->addr != NULL) {
        munmap(oldMap->addr, oldMap->size);
    }

    snprintf(name, namelen, "/pyxpregel.%s.%lld.%lld", mc_name, placeId, threadId);
    int shmfd = shm_open(name, O_RDONLY, 0);
    if (shmfd < 0) {
        perror(name);
        exit(1);
    }
        
    struct stat fs;
    fstat(shmfd, &fs);
    assert (fs.st_size >= size);

    if (size == 0) {
        size = fs.st_size;
    }
    
    void* shmem = mmap(NULL, fs.st_size, PROT_READ|PROT_WRITE, MAP_SHARED, shmfd, 0);
    close(shmfd);

    oldMap->addr = shmem;
    oldMap->size = size;

    return shmem;
}


void
Shmem::MUnMapShmem(void* addr, size_t size) {

    munmap(addr, size);
}
