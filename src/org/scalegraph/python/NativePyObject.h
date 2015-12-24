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

#ifndef __ORG_SCALEGRAPH_PYTHON_NATIVEPYOBJECT_H
#define __ORG_SCALEGRAPH_PYTHON_NATIVEPYOBJECT_H

#include <Python.h>
#include <x10rt.h>

namespace org { namespace scalegraph { namespace python {

class NativePyObject : public ::x10::lang::X10Class {
  public:
    RTT_H_DECLS_CLASS;

    PyObject*   FMGL(pointer);

    static NativePyObject* _make(PyObject* po = NULL);
    void _constructor(PyObject* po = NULL);

    PyObject* getPyObject() {
        return FMGL(pointer);
    }
    
    void INCREF() {
        Py_INCREF(FMGL(pointer));
    }

    void XINCREF() {
        Py_XINCREF(FMGL(pointer));
    }

    void DECREF() {
        Py_DECREF(FMGL(pointer));
    }

    void XDECREF() {
        Py_XDECREF(FMGL(pointer));
    }

    void CLEAR() {
        Py_CLEAR(FMGL(pointer));
    }

	// Serialization
    /*
	static void _serialize(NativePyObject* this_, x10aux::serialization_buffer& buf) {
		assert (false);
	}
	static NativePyObject* _deserializer(x10aux::deserialization_buffer& buf) {
		assert (false);
	}
    */

    virtual void __fieldInitializers_NativePyObject();
    
    // Serialization
    public: static const ::x10aux::serialization_id_t _serialization_id;
    
    public: virtual ::x10aux::serialization_id_t _get_serialization_id() {
         return _serialization_id;
    }
    
    public: virtual void _serialize_body(::x10aux::serialization_buffer& buf);
    
    public: static ::x10::lang::Reference* _deserializer(::x10aux::deserialization_buffer& buf);
    
    public: void _deserialize_body(::x10aux::deserialization_buffer& buf);

};
            
}}} // namespace org { namespace scalegraph { namespace python {

#endif // __ORG_SCALEGRAPH_PYTHON_NATIVEPYOBJECT_H
