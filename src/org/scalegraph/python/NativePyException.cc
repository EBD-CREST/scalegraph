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
#include <org/scalegraph/python/NativePyException.h>

namespace org { namespace scalegraph { namespace python {


// Exception constructor that is used when PyErr_Occured() is true
NativePyException* NativePyException::_make() {
    NativePyException* this_ = new NativePyException();
    this_->_constructor();
    return this_;
}

// Exception constructor to raise an exception when something is happned but
// the python interpriter doesnot raise an exception
NativePyException* NativePyException::_make(const char* message) {
    NativePyException* this_ = new NativePyException();
    this_->_constructor(message);
    return this_;
}

void NativePyException::_constructor() {
    (this)->::x10::lang::CheckedThrowable::_constructor();

    PyObject *type;
    PyObject *value;
    PyObject *traceback;

    PyErr_Fetch(&type, &value, &traceback);
    PyErr_NormalizeException(&type, &value, &traceback);

    /*
    PyObject_Print(type, stdout, 0);
    PyObject_Print(value, stdout, 0);
    PyObject_Print(traceback, stdout, 0);
    */
    
    FMGL(pType) = NativePyObject::_make(type);
    FMGL(pValue) = NativePyObject::_make(value);
    FMGL(pTraceback) = NativePyObject::_make(traceback);
}

void NativePyException::_constructor(const char* message) {
    (this)->::x10::lang::CheckedThrowable::_constructor();

    FMGL(strValue) = ::x10::lang::String::_make(::x10aux::alloc_utils::strdup(message), true);
    FMGL(strTraceback) = ::x10::lang::String::_make("no traceback", false);
}


void NativePyException::extractExcInfo() {
    PyObject *ptype, *pvalue, *ptraceback;
    PyObject *pystr, *module_name, *pyth_module, *pyth_func;
    char *str;

    // Skip this method
    // when the object is constructed by the constructor with message.
    if (FMGL(strValue) != NULL) {
        return;
    }
    
    if (FMGL(pValue) == NULL) {
        FMGL(strValue) = ::x10::lang::String::_make("Something happened", false);
    } else {
    
        pvalue = FMGL(pValue)->getPyObject();

        pystr = PyObject_Str(pvalue);
        if (pystr && PyUnicode_Check(pystr)) {
            PyObject* tmp = PyUnicode_AsEncodedString(pystr, "ASCII", "strict");
            if (tmp != NULL) {
                str = PyBytes_AS_STRING(tmp);
                FMGL(strValue) = ::x10::lang::String::_make(::x10aux::alloc_utils::strdup(str), true);
                Py_DECREF(tmp);
            } else {
                FMGL(strValue) = ::x10::lang::String::_make("Something happened", false);
            }
            Py_DECREF(pystr);
        } else {
            FMGL(strValue) = ::x10::lang::String::_make("Something happened", false);
        }
    }

    if (FMGL(pTraceback) == NULL) {
        FMGL(strTraceback) = ::x10::lang::String::_make("no traceback", false);
        return;
    }
    
    ptraceback = FMGL(pTraceback)->getPyObject();

    module_name = PyUnicode_FromString("traceback");
    pyth_module = PyImport_Import(module_name);
    Py_DECREF(module_name);

    if (pyth_module == NULL) {
        FMGL(strTraceback) = ::x10::lang::String::_make("Failed to import traceback", false);
        return;
    }

    pyth_func = PyObject_GetAttrString(pyth_module, "format_exception");

    if (pyth_func && PyCallable_Check(pyth_func)) {
        PyObject *pyth_val;

        pyth_val = PyObject_CallFunctionObjArgs(pyth_func, ptype, pvalue, ptraceback, NULL);
        pystr = PyObject_Str(pyth_val);

        if (pystr && PyUnicode_Check(pystr)) {
            PyObject* tmp = PyUnicode_AsEncodedString(pystr, "ASCII", "strict");
            if (tmp != NULL) {
                str = PyBytes_AS_STRING(tmp);
                FMGL(strTraceback) = ::x10::lang::String::_make(::x10aux::alloc_utils::strdup(str), true);
                Py_DECREF(tmp);
            } else {
                FMGL(strTraceback) = ::x10::lang::String::_make("no traceback", false);
            }
            Py_DECREF(pystr);
        } else {
            FMGL(strTraceback) = ::x10::lang::String::_make("no traceback", false);
        }
        Py_XDECREF(pyth_val);
    } else {
        FMGL(strTraceback) = ::x10::lang::String::_make("no traceback", false);
    }
}


RTT_CC_DECLS0(NativePyException, "org.scalegraph.python.NativePyException", x10aux::RuntimeType::class_kind)

}}} // namespace org { namespace scalegraph { namespace python {
