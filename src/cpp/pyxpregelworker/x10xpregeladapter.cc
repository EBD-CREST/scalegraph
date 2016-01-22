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


static PyObject* x10xpregeladapter_placeId(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":placeId")) {
        return NULL;
    }
    return PyLong_FromLongLong(Shmem::placeId);
}


static PyObject* x10xpregeladapter_threadId(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":threadId")) {
        return NULL;
    }
    return PyLong_FromLongLong(Shmem::threadId);
}


static PyMethodDef X10XPregelAdapterMethods[] = {
    {"placeId", x10xpregeladapter_placeId, METH_VARARGS,
     "Return the place id of the runnning process."},
    {"threadId", x10xpregeladapter_threadId, METH_VARARGS,
     "Return the thread id of the runnning process."},
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

