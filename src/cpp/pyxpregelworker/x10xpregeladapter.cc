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

    if (!PyArg_ParseTuple(args, ":place_id")) {
        return NULL;
    }
    return PyLong_FromLongLong(Shmem::placeId);
}


static PyObject* x10xpregeladapter_thread_id(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":thread_id")) {
        return NULL;
    }
    return PyLong_FromLongLong(Shmem::threadId);
}


static PyObject* x10xpregeladapter_num_threads(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":num_threads")) {
        return NULL;
    }
    return PyLong_FromLongLong(Shmem::numThreads);
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


static PyObject* x10xpregeladapter_outEdge_offsets(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":outEdge_offsets")) {
        return NULL;
    }

    size_t size = Shmem::shmemProperty->outEdge_offsets_size * sizeof(long long);
    void* shmem = Shmem::MMapShmem("outEdge.offsets", size,
                                   &Shmem::pyXPregelMapInfo.outEdge_offsets);
    PyObject* obj = Shmem::NewMemoryViewFromShmem(shmem, size);
    return obj;
}

static PyObject* x10xpregeladapter_outEdge_vertexes(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":outEdge_vertexes")) {
        return NULL;
    }

    size_t size = Shmem::shmemProperty->outEdge_vertexes_size * sizeof(long long);
    void* shmem = Shmem::MMapShmem("outEdge.vertexes", size,
                                   &Shmem::pyXPregelMapInfo.outEdge_vertexes);
    PyObject* obj = Shmem::NewMemoryViewFromShmem(shmem, size);
    return obj;
}


static PyObject* x10xpregeladapter_inEdge_offsets(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":inEdge_offsets")) {
        return NULL;
    }

    size_t size = Shmem::shmemProperty->inEdge_offsets_size * sizeof(long long);
    void* shmem = Shmem::MMapShmem("inEdge.offsets", size,
                                   &Shmem::pyXPregelMapInfo.inEdge_offsets);
    PyObject* obj = Shmem::NewMemoryViewFromShmem(shmem, size);
    return obj;
}


static PyObject* x10xpregeladapter_inEdge_vertexes(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":inEdge_vertexes")) {
        return NULL;
    }

    size_t size = Shmem::shmemProperty->inEdge_vertexes_size * sizeof(long long);
    void* shmem = Shmem::MMapShmem("inEdge.vertexes", size,
                                   &Shmem::pyXPregelMapInfo.inEdge_vertexes);
    PyObject* obj = Shmem::NewMemoryViewFromShmem(shmem, size);
    return obj;
}


static PyObject* x10xpregeladapter_vertexValue(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":vertexValue")) {
        return NULL;
    }

    size_t size = Shmem::shmemProperty->vertexValue_size *
            Type::SizeOf(Shmem::shmemProperty->vertexValue_type);
    void* shmem = Shmem::MMapShmem("vertexValue", size,
                                   &Shmem::pyXPregelMapInfo.vertexValue);
    PyObject* obj = Shmem::NewMemoryViewFromShmem(shmem, size);
    return obj;
}


static PyObject* x10xpregeladapter_vertexActive(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":vertexActive")) {
        return NULL;
    }

    size_t size = Shmem::shmemProperty->vertexActive_mc_size *
            sizeof(unsigned long long);
    void* shmem = Shmem::MMapShmem("vertexA", size,
                                   &Shmem::pyXPregelMapInfo.vertexActive);
    PyObject* obj = Shmem::NewMemoryViewFromShmem(shmem, size);
    return obj;
}


static PyObject* x10xpregeladapter_vertexShouldBeActive(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":vertexShouldBeActive")) {
        return NULL;
    }

    size_t size = Shmem::shmemProperty->vertexShouldBeActive_mc_size *
            sizeof(unsigned long long);
    void* shmem = Shmem::MMapShmem("vertexSBA", size,
                                   &Shmem::pyXPregelMapInfo.vertexShouldBeActive);
    PyObject* obj = Shmem::NewMemoryViewFromShmem(shmem, size);
    return obj;
}


static PyObject* x10xpregeladapter_message_values(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":message_values")) {
        return NULL;
    }

    size_t size = Shmem::shmemProperty->message_values_size *
            Type::SizeOf(Shmem::shmemProperty->message_value_type);
    void* shmem = Shmem::MMapShmem("message.values", size,
                                   &Shmem::pyXPregelMapInfo.message_values);
    PyObject* obj = Shmem::NewMemoryViewFromShmem(shmem, size);
    return obj;
}


static PyObject* x10xpregeladapter_message_offsets(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":message_offsets")) {
        return NULL;
    }

    size_t size = Shmem::shmemProperty->message_offsets_size *
            sizeof(long long);
    void* shmem = Shmem::MMapShmem("message.offsets", size,
                                   &Shmem::pyXPregelMapInfo.message_offsets);
    PyObject* obj = Shmem::NewMemoryViewFromShmem(shmem, size);
    return obj;
}


static PyObject* x10xpregeladapter_write_buffer_to_shmem(PyObject* self, PyObject* args) {

    const char* mc_name;
    PyObject* obj;
    
    if (!PyArg_ParseTuple(args, "sO:write_buffer_to_shmem", &mc_name, &obj)) {
        return NULL;
    }

    Py_buffer view;
    PyObject_GetBuffer(obj, &view, PyBUF_SIMPLE);
    if (view.obj == NULL) {
        return NULL;
    }

    size_t size = view.len;
    void* shmem = Shmem::CreateShmemBuffer(mc_name, size);
    memcpy(shmem, view.buf, size);
    Shmem::MUnMapShmem(shmem, size);
    PyBuffer_Release(&view);
    
    return PyLong_FromLongLong((long long)size);
}


static PyObject* x10xpregeladapter_new_memoryview_from_shmem_buffer(PyObject* self, PyObject* args) {

    const char* mc_name;
    Py_ssize_t size;

    if (!PyArg_ParseTuple(args, "sn:new_memoryview_from_shmem_buffer", &mc_name, &size)) {
        return NULL;
    }

    Shmem::MapInfo mapInfo;
    void* shmem = Shmem::MMapShmemBuffer(mc_name, (size_t)size, &mapInfo);
    return Shmem::NewMemoryViewFromShmem(shmem, mapInfo.size);
}


static PyObject* x10xpregeladapter_new_memoryview_from_shmem(PyObject* self, PyObject* args) {

    const char* mc_name;
    Py_ssize_t size;

    if (!PyArg_ParseTuple(args, "sn:new_memoryview_from_shmem", &mc_name, &size)) {
        return NULL;
    }

    Shmem::MapInfo mapInfo;
    void* shmem = Shmem::MMapShmem(mc_name, (size_t)size, &mapInfo);
    return Shmem::NewMemoryViewFromShmem(shmem, mapInfo.size);
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
     "Return the place id of the X10 process."},
    {"thread_id", x10xpregeladapter_thread_id, METH_VARARGS,
     "Return the thread id of the X10 process."},
    {"num_threads", x10xpregeladapter_num_threads, METH_VARARGS,
     "Return the number of thread of the X10 process."},

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

    {"outEdge_offsets", x10xpregeladapter_outEdge_offsets, METH_VARARGS, NULL},
    {"outEdge_vertexes", x10xpregeladapter_outEdge_vertexes, METH_VARARGS, NULL},
    {"inEdge_offsets", x10xpregeladapter_inEdge_offsets, METH_VARARGS, NULL},
    {"inEdge_vertexes", x10xpregeladapter_inEdge_vertexes, METH_VARARGS, NULL},
    {"vertexValue", x10xpregeladapter_vertexValue, METH_VARARGS, NULL},
    {"vertexActive", x10xpregeladapter_vertexActive, METH_VARARGS, NULL},
    {"vertexShouldBeActive", x10xpregeladapter_vertexShouldBeActive, METH_VARARGS, NULL},
    {"message_values", x10xpregeladapter_message_values, METH_VARARGS, NULL},
    {"message_offsets", x10xpregeladapter_message_offsets, METH_VARARGS, NULL},

    {"write_buffer_to_shmem", x10xpregeladapter_write_buffer_to_shmem, METH_VARARGS, NULL},
    {"new_memoryview_from_shmem_buffer", x10xpregeladapter_new_memoryview_from_shmem_buffer, METH_VARARGS, NULL},
    {"new_memoryview_from_shmem", x10xpregeladapter_new_memoryview_from_shmem, METH_VARARGS, NULL},
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

