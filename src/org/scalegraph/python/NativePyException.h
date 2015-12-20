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

#ifndef __ORG_SCALEGRAPH_PYTHON_NATIVEPYEXCEPTION_H
#define __ORG_SCALEGRAPH_PYTHON_NATIVEPYEXCEPTION_H

#include <Python.h>
#include <x10rt.h>
#include <org/scalegraph/python/NativePyObject.h>

#define X10_LANG_CHECKEDTHROWABLE_H_NODEPS
#include <x10/lang/CheckedThrowable.h>
#undef X10_LANG_CHECKEDTHROWABLE_H_NODEPS

namespace org { namespace scalegraph { namespace python {

class NativePyException : public ::x10::lang::CheckedThrowable {
  public:
    RTT_H_DECLS_CLASS;

    PyObject*   FMGL(pointer);

    static NativePyException* _make();
    void _constructor();

    void incref() {
        Py_INCREF(FMGL(pointer));
    }

    void xincref() {
        Py_XINCREF(FMGL(pointer));
    }

    void decref() {
        Py_DECREF(FMGL(pointer));
    }

    void xdecref() {
        Py_XDECREF(FMGL(pointer));
    }

    void clear() {
        Py_CLEAR(FMGL(pointer));
    }

	// Serialization
	static void _serialize(NativePyException this_, x10aux::serialization_buffer& buf) {
		assert (false);
	}
	static NativePyException _deserializer(x10aux::deserialization_buffer& buf) {
		assert (false);
	}
};
            
}}} // namespace org { namespace scalegraph { namespace python {

#endif // __ORG_SCALEGRAPH_PYTHON_NATIVEPYEXCEPTION_H
