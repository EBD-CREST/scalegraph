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

static PyObject* x10xpregeladapter_place_id(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":placeId")) {
        return NULL;
    }
    return PyLong_FromLongLong(Shmem::placeId);
}


static PyObject* x10xpregeladapter_thread_id(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":threadId")) {
        return NULL;
    }
    return PyLong_FromLongLong(Shmem::threadId);
}


#define DEFMEMBERPROPLL(ID) \
static PyObject* x10xpregeladapter_##ID(PyObject* self, PyObject* args) {\
\
    if (!PyArg_ParseTuple(args, ":" #ID)) {\
        return NULL;\
    }\
    return PyLong_FromLongLong(Shmem::shmemProperty->ID);\
}


#define DEFMEMBERPROPI(ID) \
static PyObject* x10xpregeladapter_##ID(PyObject* self, PyObject* args) {\
\
    if (!PyArg_ParseTuple(args, ":" #ID)) {\
        return NULL;\
    }\
    return PyLong_FromLong((long)Shmem::shmemProperty->ID); \
}


DEFMEMBERPROPLL(outEdge_offsets_size)
DEFMEMBERPROPLL(outEdge_vertexes_size)
DEFMEMBERPROPLL(inEdge_offsets_size)
DEFMEMBERPROPLL(inEdge_vertexes_size)
DEFMEMBERPROPLL(vertexValue_size)
DEFMEMBERPROPI(vertexValue_type)
DEFMEMBERPROPLL(vertexActive_mc_size)
DEFMEMBERPROPLL(vertexShouldBeActive_mc_size)
DEFMEMBERPROPLL(message_values_size)
DEFMEMBERPROPLL(message_offsets_size)
DEFMEMBERPROPI(message_value_type)
DEFMEMBERPROPLL(vertex_range_min)
DEFMEMBERPROPLL(vertex_range_max)


static PyObject* x10xpregeladapter_outEdge_offsets(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":outEdge_offsets")) {
        return NULL;
    }

    void* shmem = Shmem::MMapShmemMemoryChunk("outEdge.offsets");
    PyObject* obj = Shmem::NewMemoryViewFromMemoryChunk(shmem,
                                                        Shmem::shmemProperty->outEdge_offsets_size * sizeof(long long));
    return obj;
}


static PyObject* x10xpregeladapter_outEdge_vertexes(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":outEdge_vertexes")) {
        return NULL;
    }

    void* shmem = Shmem::MMapShmemMemoryChunk("outEdge.vertexes");
    PyObject* obj = Shmem::NewMemoryViewFromMemoryChunk(shmem,
                                                        Shmem::shmemProperty->outEdge_vertexes_size * sizeof(long long));
    return obj;
}


static PyObject* x10xpregeladapter_inEdge_offsets(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":inEdge_offsets")) {
        return NULL;
    }

    void* shmem = Shmem::MMapShmemMemoryChunk("inEdge.offsets");
    PyObject* obj = Shmem::NewMemoryViewFromMemoryChunk(shmem,
                                                        Shmem::shmemProperty->inEdge_offsets_size * sizeof(long long));
    return obj;
}


static PyObject* x10xpregeladapter_inEdge_vertexes(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":inEdge_vertexes")) {
        return NULL;
    }

    void* shmem = Shmem::MMapShmemMemoryChunk("inEdge.vertexes");
    PyObject* obj = Shmem::NewMemoryViewFromMemoryChunk(shmem,
                                                        Shmem::shmemProperty->inEdge_vertexes_size * sizeof(long long));
    return obj;
}


static PyObject* x10xpregeladapter_vertexValue(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":vertexValue")) {
        return NULL;
    }

    void* shmem = Shmem::MMapShmemMemoryChunk("vertexValue");
    PyObject* obj = Shmem::NewMemoryViewFromMemoryChunk(shmem,
                                                        Shmem::shmemProperty->vertexValue_size *
                                                        Type::SizeOf(Shmem::shmemProperty->vertexValue_type));
    return obj;
}


static PyObject* x10xpregeladapter_vertexActive(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":vertexActive")) {
        return NULL;
    }

    void* shmem = Shmem::MMapShmemMemoryChunk("vertexA");
    PyObject* obj = Shmem::NewMemoryViewFromMemoryChunk(shmem,
                                                        Shmem::shmemProperty->vertexActive_mc_size *
                                                        sizeof(unsigned long long));
    return obj;
}


static PyObject* x10xpregeladapter_vertexShouldBeActive(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":vertexShouldBeActive")) {
        return NULL;
    }

    void* shmem = Shmem::MMapShmemMemoryChunk("vertexSBA");
    PyObject* obj = Shmem::NewMemoryViewFromMemoryChunk(shmem,
                                                        Shmem::shmemProperty->vertexShouldBeActive_mc_size *
                                                        sizeof(unsigned long long));
    return obj;
}


static PyObject* x10xpregeladapter_message_values(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":message_values")) {
        return NULL;
    }

    void* shmem = Shmem::MMapShmemMemoryChunk("message.values");
    PyObject* obj = Shmem::NewMemoryViewFromMemoryChunk(shmem,
                                                        Shmem::shmemProperty->message_values_size *
                                                        Type::SizeOf(Shmem::shmemProperty->message_value_type));
    return obj;
}


static PyObject* x10xpregeladapter_message_offsets(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":message_offsets")) {
        return NULL;
    }

    void* shmem = Shmem::MMapShmemMemoryChunk("message.offsets");
    PyObject* obj = Shmem::NewMemoryViewFromMemoryChunk(shmem,
                                                        Shmem::shmemProperty->message_offsets_size *
                                                        sizeof(long long));
    return obj;
}


static PyObject* x10xpregeladapter_get_format(PyObject* self, PyObject* args) {

    int tid;
    
    if (!PyArg_ParseTuple(args, "i:get_format", &tid)) {
        return NULL;
    }

    return Type::PyFormat(tid);
}


static PyMethodDef X10XPregelAdapterMethods[] = {
    {"place_id", x10xpregeladapter_place_id, METH_VARARGS,
     "Return the place id of the runnning process."},
    {"thread_id", x10xpregeladapter_thread_id, METH_VARARGS,
     "Return the thread id of the runnning process."},

#define ITEMPROPLL(ID) \
    {#ID, x10xpregeladapter_##ID, METH_VARARGS, \
     "Return the " #ID " of the runnning process."},

#define ITEMPROPI(ID) \
    {#ID, x10xpregeladapter_##ID, METH_VARARGS, \
     "Return the " #ID " of the runnning process."},

    ITEMPROPLL(outEdge_offsets_size)
    ITEMPROPLL(outEdge_vertexes_size)
    ITEMPROPLL(inEdge_offsets_size)
    ITEMPROPLL(inEdge_vertexes_size)
    ITEMPROPLL(vertexValue_size)
    ITEMPROPI(vertexValue_type)
    ITEMPROPLL(vertexActive_mc_size)
    ITEMPROPLL(vertexShouldBeActive_mc_size)
    ITEMPROPLL(message_values_size)
    ITEMPROPLL(message_offsets_size)
    ITEMPROPI(message_value_type)
    ITEMPROPLL(vertex_range_min)
    ITEMPROPLL(vertex_range_max)

    {"outEdge_offsets", x10xpregeladapter_outEdge_offsets, METH_VARARGS, NULL},
    {"outEdge_vertexes", x10xpregeladapter_outEdge_vertexes, METH_VARARGS, NULL},
    {"inEdge_offsets", x10xpregeladapter_inEdge_offsets, METH_VARARGS, NULL},
    {"inEdge_vertexes", x10xpregeladapter_inEdge_vertexes, METH_VARARGS, NULL},
    {"vertexValue", x10xpregeladapter_vertexValue, METH_VARARGS, NULL},
    {"vertexActive", x10xpregeladapter_vertexActive, METH_VARARGS, NULL},
    {"vertexShouldBeActive", x10xpregeladapter_vertexShouldBeActive, METH_VARARGS, NULL},
    {"message_values", x10xpregeladapter_message_values, METH_VARARGS, NULL},
    {"message_offsets", x10xpregeladapter_message_offsets, METH_VARARGS, NULL},

    {"get_format", x10xpregeladapter_get_format, METH_VARARGS, NULL},
    
    {NULL, NULL, 0, NULL}
};


static PyModuleDef X10XPregelAdapterModule = {
    PyModuleDef_HEAD_INIT, "x10xpregeladapter", NULL, -1, X10XPregelAdapterMethods,
    NULL, NULL, NULL, NULL
};


static PyObject* PyInit_x10xpregeladapter(void) {
    return PyModule_Create(&X10XPregelAdapterModule);
}


void X10XPregelAdapterInitialize() {
    PyImport_AppendInittab("x10xpregeladapter", &PyInit_x10xpregeladapter);
}

