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

// Return value: New reference.
NativePyObject* NativePython::importImport(::x10::lang::String* name) {
    PyObject *pName;
    PyObject *pModule;

    pName = PyUnicode_FromString(name->c_str());
    /* Error checking of pName left out */

    pModule = PyImport_Import(pName);
    Py_XDECREF(pName);

    if (pModule == NULL) {
        //PyErr_Print();
        //fprintf(stderr, "Failed to load \"%s\"\n", name->c_str());
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }

    return NativePyObject::_make(pModule);
}

// Return value: Borrowed reference.
NativePyObject* importAddModule(::x10::lang::String* name) {
    PyObject *pModule;

    pModule = PyImport_AddModule(name->c_str());
    if (pModule == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }

    return NativePyObject::_make(pModule);
}

// Return value: Borrowed reference.
NativePyObject* moduleGetDict(NativePyObject* module) {
    PyObject *pObj;
    PyObject *pDict;

    if (module == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::moduleGetDict, bad NativePyObject")));
    }

    pObj = module->getPyObject();
    if (pObj == NULL || !PyModule_Check(pObj)) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::moduleGetDict, bad PyObject")));
    }

    pDict = PyModule_GetDict(pObj);

    return NativePyObject::_make(pDict);
}

// Return value: New reference.
NativePyObject* dictNew() {
    PyObject *pObj;
    pObj = PyDict_New();
    if (pObj == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }
    return NativePyObject::_make(pObj);
}

x10_int dictSetItemString(NativePyObject* dict, ::x10::lang::String* key, NativePyObject* value) {
    int ret;
    PyObject *pDict;
    PyObject *pValue;

    if (dict == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::dictSetItemString, bad NativePyObject for dict")));
    }

    pDict = dict->getPyObject();
    if (pDict == NULL || !PyDict_Check(pDict)) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::dictSetItemString, bad PyObject for dict")));
    }

    if (value == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::dictSetItemString, bad NativePyObject for value")));
    }

    pValue = value->getPyObject();
    if (pValue == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::dictSetItemString, bad PyObject for value")));
    }

    ret = PyDict_SetItemString(pDict, key->c_str(), pValue);
    if (ret != 0) {
        // This function does not raise an exception
        // ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return ret;
    }
    return ret; // return 0 on success, -1 on failure
}

// Return value: Borrowed reference.
NativePyObject* dictGetItemString(NativePyObject* dict, ::x10::lang::String* key) {
    PyObject *pObj;
    PyObject *pDict;

    if (dict == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::dictGetItemString, bad NativePyObject")));
    }

    pDict = dict->getPyObject();
    if (pDict == NULL || !PyDict_Check(pDict)) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::dictGetItemString, bad PyObject")));
    }

    pObj = PyDict_GetItemString(pDict, key->c_str());
    if (pObj == NULL) {
        // This function does not raise an exception
        // ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }
    return NativePyObject::_make(pObj);
}

NativePyObject* unicodeFromString(::x10::lang::String* str) {
    PyObject* ret;
    ret = PyUnicode_FromString(str->c_str());
    return NativePyObject::_make(ret);
}

::x10::lang::String* unicodeAsASCIIString(NativePyObject* obj) {
    ::x10::lang::String* ret;
    if (obj) {
        PyObject* pystr = obj->getPyObject();
        if (pystr && PyUnicode_Check(pystr)) {
            PyObject* tmp = PyUnicode_AsEncodedString(pystr, "ASCII", "strict");
            if (tmp != NULL) {
                char* str = PyBytes_AS_STRING(tmp);
                ret = ::x10::lang::String::_make(::x10aux::alloc_utils::strdup(str), true);
                Py_DECREF(tmp);
                Py_DECREF(pystr);
                return ret;
            } else {
                ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
                Py_DECREF(pystr);
                return NULL;
            }
        } else {
            ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::unicodeAsASCIIString, bad PyObject")));
            return NULL;
        }
    } else {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::unicodeAsASCIIString, bad NativePyObject")));
        return NULL;
    }
}

// Return value: New reference.
NativePyObject* longFromLong(x10_long value) {
    PyObject* ret;
    ret = PyLong_FromLong(value);
    if (ret == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }
    return NativePyObject::_make(ret);
}

x10_long longAsLong(NativePyObject* obj) {
    x10_long ret;
    if (obj != NULL) {
        ret = PyLong_AsLong(obj->getPyObject());
        if (PyErr_Occurred()) {
            ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
            return 0;
        }
        return ret;
    }
    return 0;
}

x10_int runSimpleString(::x10::lang::String* command) {
    int ret;

    ret = PyRun_SimpleString(command->c_str());
    return ret; // return 0 on success, -1 on failure
}

NativePyObject* runString(::x10::lang::String* command, NativePyObject* global, NativePyObject* local) {
    return NULL;
}

NativePyObject* callObject(NativePyObject* callable, ::x10::lang::Rail<NativePyObject* > *args) {
    return NULL;
}

::x10::lang::String* objectStr(NativePyObject* obj) {
    PyObject* pystr;
    ::x10::lang::String* ret;
    if (obj != NULL) {
        pystr = PyObject_Str(obj->getPyObject());
        if (pystr && PyUnicode_Check(pystr)) {
            PyObject* tmp = PyUnicode_AsEncodedString(pystr, "ASCII", "strict");
            if (tmp != NULL) {
                char* str = PyBytes_AS_STRING(tmp);
                ret = ::x10::lang::String::_make(::x10aux::alloc_utils::strdup(str), true);
                Py_DECREF(tmp);
                Py_DECREF(pystr);
                return ret;
            } else {
                Py_DECREF(pystr);
                return NULL;
            }
        } else {
            return NULL;
        }
    }
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
