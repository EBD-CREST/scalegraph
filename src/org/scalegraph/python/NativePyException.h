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
  private:
    
  public:
    RTT_H_DECLS_CLASS;

    ::x10::lang::String* FMGL(strType);
    ::x10::lang::String* FMGL(strValue);
    ::x10::lang::String* FMGL(strTraceback);
    
    NativePyObject   FMGL(pType);
    NativePyObject   FMGL(pValue);
    NativePyObject   FMGL(pTraceback);
    
    static NativePyException* _make();
    static NativePyException* _make(const char*);
    void _constructor();
    void _constructor(const char*);

    void extractExcInfo();

    void INCREF() {
        FMGL(pType)->INCREF();
        FMGL(pValue)->INCREF();
        FMGL(pTraceback)->INCREF();
    }

    void XINCREF() {
        FMGL(pType)->XINCREF();
        FMGL(pValue)->XINCREF();
        FMGL(pTraceback)->XINCREF();
    }

    void DECREF() {
        FMGL(pType)->DECREF();
        FMGL(pValue)->DECREF();
        FMGL(pTraceback)->DECREF();
    }

    void XDECREF() {
        FMGL(pType)->XDECREF();
        FMGL(pValue)->XDECREF();
        FMGL(pTraceback)->XDECREF();
    }

    void CLEAR() {
        FMGL(pType)->CLEAR();
        FMGL(pValue)->CLEAR();
        FMGL(pTraceback)->CLEAR();
    }

	// Serialization
    /*
	static void _serialize(NativePyException this_, x10aux::serialization_buffer& buf) {
		assert (false);
	}
	static NativePyException _deserializer(x10aux::deserialization_buffer& buf) {
		assert (false);
	}
    */

    virtual void __fieldInitializers_NativePyException();
    
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

#endif // __ORG_SCALEGRAPH_PYTHON_NATIVEPYEXCEPTION_H
