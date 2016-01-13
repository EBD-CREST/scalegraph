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

#ifndef __ORG_SCALEGRAPH_API_NATIVEPYXPREGELADAPTER_H
#define __ORG_SCALEGRAPH_API_NATIVEPYXPREGELADAPTER_H

#include <string.h>
#include <x10rt.h>
#include <org/scalegraph/io/GenericFile.h>

namespace x10 { namespace lang { 
class String;
} } 
namespace org { namespace scalegraph { namespace io { 
class GenericFile;
} } } 
namespace org { namespace scalegraph { namespace exception { 
class PyXPregelException;
} } } 
namespace x10 { namespace lang { 
class LongRange;
} } 
namespace x10 { namespace lang { 
template<class TPMGL(Z1), class TPMGL(Z2)> class VoidFun_0_2;
} } 

namespace org { namespace scalegraph { namespace api {

            
class NativePyXPregelAdapter : public ::x10::lang::X10Class {
  public:
    RTT_H_DECLS_CLASS;

    void initialize();
    ::org::scalegraph::io::GenericFile* fork(x10_long idx,  ::x10::lang::LongRange i_range,
                                             ::x10::lang::VoidFun_0_2<x10_long,  ::x10::lang::LongRange>* func);
    template<class TPMGL(T)> void copyFromBuffer(::org::scalegraph::util::MemoryChunk< x10_byte> buffer, x10_long offset, x10_long size_to_copy, TPMGL(T) object);
    
    virtual NativePyXPregelAdapter* NativePyXPregelAdapter____this__NativePyXPregelAdapter();
    void _constructor();
    static NativePyXPregelAdapter* _make();

    virtual void __fieldInitializers_NativePyXPregelAdapter();
    
    // Serialization
    public: static const ::x10aux::serialization_id_t _serialization_id;
    
    public: virtual ::x10aux::serialization_id_t _get_serialization_id() {
         return _serialization_id;
    }
    
    public: virtual void _serialize_body(::x10aux::serialization_buffer& buf);
    
    public: static ::x10::lang::Reference* _deserializer(::x10aux::deserialization_buffer& buf);
    
    public: void _deserialize_body(::x10aux::deserialization_buffer& buf);
};


template<class TPMGL(T)>
void NativePyXPregelAdapter::copyFromBuffer(::org::scalegraph::util::MemoryChunk< x10_byte> buffer, x10_long offset, x10_long size_to_copy, TPMGL(T) object) {

    ::memmove(object->pointer() + offset, buffer->pointer(), (size_t) size_to_copy);
}



}}} // namespace org { namespace scalegraph { namespace api {

#endif // __ORG_SCALEGRAPH_API_NATIVEPYXPREGELADAPTER_H
