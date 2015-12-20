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

NativePyException* NativePyException::_make() {
    NativePyException* this_ = new NativePyException();
    this_->_constructor();
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

void NativePyException::extractExcInfo() {
    PyObject *ptype, *pvalue, *ptraceback;
    PyObject *pystr, *module_name, *pyth_module, *pyth_func;
    char *str;

    ptype = FMGL(pType)->getPyObject();
    pvalue = FMGL(pValue)->getPyObject();
    ptraceback = FMGL(pTraceback)->getPyObject();

    pystr = PyObject_Str(pvalue);
    if (pystr && PyUnicode_Check(pystr)) {
        PyObject* tmp = PyUnicode_AsEncodedString(pystr, "ASCII", "strict");
        if (tmp != NULL) {
            str = PyBytes_AS_STRING(tmp);
            FMGL(strValue) = ::x10::lang::String::_make(::x10aux::alloc_utils::strdup(str), true);
            Py_DECREF(tmp);
        } else {
            FMGL(strValue) = ::x10::lang::String::_make("???", false);
        }
        Py_DECREF(pystr);
    } else {
        FMGL(strValue) = ::x10::lang::String::_make("???", false);
    }

    module_name = PyUnicode_FromString("traceback");
    pyth_module = PyImport_Import(module_name);
    Py_DECREF(module_name);

    if (pyth_module == NULL) {
        FMGL(strTraceback) = NULL;
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
                FMGL(strTraceback) = ::x10::lang::String::_make("???", false);
            }
            Py_DECREF(pystr);
        } else {
            FMGL(strTraceback) = ::x10::lang::String::_make("???", false);
        }

        Py_XDECREF(pyth_val);
    }
}


RTT_CC_DECLS0(NativePyException, "org.scalegraph.python.NativePyException", x10aux::RuntimeType::class_kind)

}}} // namespace org { namespace scalegraph { namespace python {
