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

#define X10_LANG_ANY_H_NODEPS
#include <x10/lang/Any.h>
#undef X10_LANG_ANY_H_NODEPS

namespace org { namespace scalegraph { namespace python {

class NativePyObject;

class NativePyObject {
  private:
    PyObject* pyObject;
    
  public:
    RTT_H_DECLS_STRUCT;

    NativePyObject* operator->() { return this; }
    bool operator==(void* pointer) { return pyObject == pointer; }
    bool operator!=(void* pointer) { return pyObject != pointer; }
    NativePyObject(void* pointer) { pyObject = static_cast<PyObject*>(pointer); }
    NativePyObject() {}
    
    PyObject* getPyObject() { return pyObject; }
    
    static ::x10aux::itable_entry _itables[2];

    ::x10aux::itable_entry* _getITables() { return _itables; }
    
    static  ::x10::lang::Any::itable<  NativePyObject > _itable_0;
    
    static ::x10aux::itable_entry _iboxitables[2];
    
    ::x10aux::itable_entry* _getIBoxITables() { return _iboxitables; }
    
    static  NativePyObject _alloc(){ NativePyObject t; assert(false); return t; }

    void _constructor(PyObject* pyobj = NULL) {
        //        (*this) -> NativePyObject::__fieldInitializers_NativePyObject();
        pyObject = pyobj;
    }
    static  NativePyObject _make(PyObject* pyobj = NULL) {
        NativePyObject this_;
        this_->_constructor(pyobj);
        return this_;
    }
    
     ::x10::lang::String* typeName();
     ::x10::lang::String* toString();
    x10_int hashCode();
    x10_boolean equals( ::x10::lang::Any* other);
    x10_boolean equals( NativePyObject other) {
        return pyObject == other->getPyObject();
    }
    x10_boolean _struct_equals( ::x10::lang::Any* other);
    x10_boolean _struct_equals( NativePyObject other) {
        return pyObject == other->getPyObject();
    }
     NativePyObject NativePyObject____this__NativePyObject() {
        return (*this);
    }
    void __fieldInitializers_NativePyObject() {
    }
    
    static void _serialize( NativePyObject this_, ::x10aux::serialization_buffer& buf);
    
    static  NativePyObject _deserialize(::x10aux::deserialization_buffer& buf) {
         NativePyObject this_;
        this_->_deserialize_body(buf);
        return this_;
    }
    
    void _deserialize_body(::x10aux::deserialization_buffer& buf);
    
    void INCREF() {
        Py_INCREF(pyObject);
    }

    void XINCREF() {
        Py_XINCREF(pyObject);
    }

    void DECREF() {
        Py_DECREF(pyObject);
    }

    void XDECREF() {
        Py_XDECREF(pyObject);
    }

    void CLEAR() {
        Py_CLEAR(pyObject);
    }

};
            
}}} // namespace org { namespace scalegraph { namespace python {

#endif // __ORG_SCALEGRAPH_PYTHON_NATIVEPYOBJECT_H
