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

#ifndef __ORG_SCALEGRAPH_PYTHON_NATIVEPYTHON_H
#define __ORG_SCALEGRAPH_PYTHON_NATIVEPYTHON_H

#include <x10rt.h>

#define X10_LANG_STRING_H_NODEPS
#include <x10/lang/String.h>
#undef X10_LANG_STRING_H_NODEPS

#define X10_LANG_RAIL_H_NODEPS
#include <x10/lang/Rail.h>
#undef X10_LANG_RAIL_H_NODEPS

#define X10_UTIL_HASHMAP_H_NODEPS
#include <x10/util/HashMap.h>
#undef X10_UTIL_HASHMAP_H_NODEPS

#define ORG_SCALEGRAPH_PYTHON_NATIVEPYOBJECT_H_NODEPS
#include <org/scalegraph/python/NativePyObject.h>
#undef ORG_SCALEGRAPH_PYTHON_NATIVEPYOBJECT_H_NODEPS

#define ORG_SCALEGRAPH_PYTHON_NATIVEPYEXCEPTION_H_NODEPS
#include <org/scalegraph/python/NativePyException.h>
#undef ORG_SCALEGRAPH_PYTHON_NATIVEPYEXCEPTION_H_NODEPS

#define ORG_SCALEGRAPH_ID_TYPEHELPER_H_NODEPS
#include <org/scalegraph/id/TypeHelper.h>
#undef ORG_SCALEGRAPH_ID_TYPEHELPER_H_NODEPS


namespace org { namespace scalegraph { namespace util { 
template<class TPMGL(T)> class MemoryChunk;
} } } 

namespace org { namespace scalegraph { namespace python {

class NativePython : public ::x10::lang::X10Class {
  public:
    RTT_H_DECLS_CLASS;

    void initialize();
    void finalize();
    void osAfterFork();
    void sysPathAppend(::x10::lang::String* path);
    NativePyObject importImport(::x10::lang::String* name);
    NativePyObject importAddModule(::x10::lang::String* name);
    NativePyObject moduleGetDict(NativePyObject module);
    NativePyObject dictNew();
    x10_int dictSetItemString(NativePyObject dict, ::x10::lang::String* key, NativePyObject value);
    NativePyObject dictGetItemString(NativePyObject dict, ::x10::lang::String* key);
    NativePyObject dictFromHashMap(NativePyObject dict, ::x10::util::HashMap< ::x10::lang::String*, NativePyObject >* hashmap);
    ::x10::util::HashMap< ::x10::lang::String*, NativePyObject >* dictAsHashMap(NativePyObject dict);
    NativePyObject dictImportHashMap(NativePyObject dict, ::x10::util::HashMap< ::x10::lang::String*, NativePyObject >* hashmap);
    NativePyObject listNew(x10_long size);
    NativePyObject listFromRail(::x10::lang::Rail<NativePyObject >* rail);
    ::x10::lang::Rail<NativePyObject >* listAsRail(NativePyObject list);
    NativePyObject tupleNew(x10_long size);
    NativePyObject tupleFromRail(::x10::lang::Rail<NativePyObject >* rail);
    ::x10::lang::Rail<NativePyObject >* tupleAsRail(NativePyObject tuple);
    NativePyObject unicodeFromString(::x10::lang::String* str);
    ::x10::lang::String* unicodeAsASCIIString(NativePyObject obj);
    NativePyObject longFromLong(x10_long value);
    x10_long longAsLong(NativePyObject obj);
    x10_int runSimpleString(::x10::lang::String* command);
    NativePyObject runString(::x10::lang::String* command, NativePyObject global, NativePyObject local);
    NativePyObject objectCallObject(NativePyObject callable, ::x10::lang::Rail<NativePyObject > *args);
    ::x10::lang::String* objectStr(NativePyObject obj);
    ::org::scalegraph::util::MemoryChunk<x10_byte> bytesAsMemoryChunk(NativePyObject obj);
    /*
    NativePyObject memoryViewFromMemoryChunk(::org::scalegraph::util::MemoryChunk<x10_byte> mc);
    NativePyObject memoryViewFromMemoryChunk(::org::scalegraph::util::MemoryChunk<x10_long> mc);
    NativePyObject memoryViewFromMemoryChunk(::org::scalegraph::util::MemoryChunk<x10_double> mc);
    */
    template<class TPMGL(T)> NativePyObject memoryViewFromMemoryChunk(::org::scalegraph::util::MemoryChunk<TPMGL(T)> mc);
    template<class TPMGL(T)> ::org::scalegraph::util::MemoryChunk<TPMGL(T)> bufferAsMemoryChunk(NativePyObject obj);
    
    void test();
    void calltest(NativePyObject module);
    
    virtual NativePython* NativePython____this__NativePython();
    void _constructor();
    static NativePython* _make();

    virtual void __fieldInitializers_NativePython();
    
    // Serialization
    public: static const ::x10aux::serialization_id_t _serialization_id;
    
    public: virtual ::x10aux::serialization_id_t _get_serialization_id() {
         return _serialization_id;
    }
    
    public: virtual void _serialize_body(::x10aux::serialization_buffer& buf);
    
    public: static ::x10::lang::Reference* _deserializer(::x10aux::deserialization_buffer& buf);
    
    public: void _deserialize_body(::x10aux::deserialization_buffer& buf);
};


// Return value: New reference of memoryview object (pointed to memorychunk argument)
template <class TPMGL(T)>
        NativePyObject NativePython::memoryViewFromMemoryChunk(::org::scalegraph::util::MemoryChunk<TPMGL(T)> mc) {

    void* mcptr = mc.pointer();
    if (mcptr == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::memoryviewFromMemoryChunk, bad MemoryChunk")));
        return NULL;
    }
    long size = mc.size() * org::scalegraph::id::SizeOf<TPMGL(T)>::value;
    if (size < 0) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::memoryviewFromMemoryChunk, unsupported content type of MemoryChunk")));
        return NULL;
    }

    PyObject* pObj = PyMemoryView_FromMemory(static_cast<char*>(mcptr), size, PyBUF_READ);
    if (PyErr_Occurred()) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }
    return pObj;
}


// Return value: New MemoryChunk (memory is allocated)
template <class TPMGL(T)>
        ::org::scalegraph::util::MemoryChunk<TPMGL(T)> NativePython::bufferAsMemoryChunk(NativePyObject obj) {
    if (obj == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::bufferAsMemoryChunk, bad NativePyObject")));
        return ::org::scalegraph::util::MemoryChunk<TPMGL(T)>::_make();
    }

    PyObject* pObj = obj->getPyObject();
    Py_buffer pBuff;
    int ret = PyObject_GetBuffer(pObj, &pBuff, PyBUF_SIMPLE);
    if (ret != 0) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return ::org::scalegraph::util::MemoryChunk<TPMGL(T)>::_make();
    }

    long long itemSize = ::org::scalegraph::id::SizeOf<TPMGL(T)>::value;
    if (itemSize < 0) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::bufferAsMemoryChunk, unsupported content type of MemoryChunk")));
        return ::org::scalegraph::util::MemoryChunk<TPMGL(T)>::_make();
    }

    size_t numItem = pBuff.len / (size_t) itemSize;
    if (pBuff.len != numItem * (size_t) itemSize) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::bufferAsMemoryChunk, content type mismatch of MemoryChunk")));
        return ::org::scalegraph::util::MemoryChunk<TPMGL(T)>::_make();
    }

    ::org::scalegraph::util::MemoryChunk<TPMGL(T)> mc = ::org::scalegraph::util::MemoryChunk<TPMGL(T)>::_make(::org::scalegraph::util::MakeStruct<TPMGL(T) >::make(numItem, 0, false, (char*)(void*)__FILE__, __LINE__));
    void* mcptr = mc.pointer();
    
    if (mcptr != NULL) {
        memcpy(mcptr, pBuff.buf, pBuff.len);
    }
    PyBuffer_Release(&pBuff);

    return mc;
}


}}} // namespace org { namespace scalegraph { namespace python {

#endif // __ORG_SCALEGRAPH_PYTHON_NATIVEPYTHON_H
