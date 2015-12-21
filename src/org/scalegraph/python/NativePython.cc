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

#include <x10aux/config.h>
#include <x10/lang/String.h>
#include <x10/lang/Rail.h>
#include <org/scalegraph/python/NativePython.h>
#include <org/scalegraph/python/NativePyObject.h>
#include <org/scalegraph/python/NativePyException.h>

namespace org { namespace scalegraph { namespace python {

NativePython* NativePython::_make() {
    NativePython* ret = new NativePython();
    ret->_constructor();
    return ret;
}

void NativePython::_constructor() {
    Py_Initialize();
    PyRun_SimpleString("import sys");
    PyRun_SimpleString("sys.path.append(\".\")");
}

NativePyObject* NativePython::importImport(::x10::lang::String* name) {
    PyObject *pName;
    PyObject *pModule;

    pName = PyUnicode_FromString(name->c_str());
    /* Error checking of pName left out */

    pModule = PyImport_Import(pName);
    Py_XDECREF(pName);

    if (pModule == NULL) {
        //        PyErr_Print();
        fprintf(stderr, "Failed to load \"%s\"\n", name->c_str());

        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }

    NativePyObject*  pyObject;
    pyObject = NativePyObject::_make();
    pyObject->FMGL(pointer) = pModule;
    return pyObject;
}

NativePyObject* importAddModule(::x10::lang::String* name) {
    return NULL;
}

NativePyObject* moduleGetDict(NativePyObject* module) {
    return NULL;
}

NativePyObject* dictNew() {
    return NULL;
}

x10_int dicSetItemString(NativePyObject* dict, ::x10::lang::String* key, NativePyObject* value) {
    return 0;
}

NativePyObject* dicGetItemString(NativePyObject* dict, ::x10::lang::String* key) {
    return NULL;
}

NativePyObject* unicodeFromString(::x10::lang::String* str) {
    return NULL;
}

::x10::lang::String* unicodeAsASCIIString(NativePyObject* obj) {
    return NULL;
}

NativePyObject* longFromLong(x10_long value) {
    return NULL;
}

x10_long longAsLong(NativePyObject* obj) {
    return 0;
}

x10_int runSimpleString(::x10::lang::String* command) {
    return 0;
}

NativePyObject* runString(::x10::lang::String* command, NativePyObject* global, NativePyObject* local) {
    return NULL;
}

NativePyObject* callObject(NativePyObject* callable, ::x10::lang::Rail<NativePyObject* > *args) {
    return NULL;
}

::x10::lang::String* objectStr(NativePyObject* obj) {
    return NULL;
}


void NativePython::test() {
    PyRun_SimpleString("from time import time,ctime\n"
                       "print('Today is', ctime(time()))\n"
                       "sys.stdout.flush()\n");
}

void NativePython::calltest(::org::scalegraph::python::NativePyObject* module) {
    PyObject *pValue;
    PyObject *pArgs;
    PyObject *pFunc;

    pArgs = Py_BuildValue("ii", 123L, 456L);
    pFunc = PyObject_GetAttrString(module->FMGL(pointer), "multiply");
    pValue = PyObject_CallObject(pFunc, pArgs);

    fprintf(stderr, "result = %ld\n", PyLong_AsLong(pValue));
}


RTT_CC_DECLS0(NativePython, "org.scalegraph.python.NativePython", x10aux::RuntimeType::class_kind)

}}} // namespace org { namespace scalegraph { namespace python {
