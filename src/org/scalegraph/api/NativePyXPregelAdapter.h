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

#define ORG_SCALEGRAPH_UTIL_MEMORYCHUNK_H_NODEPS
#include <org/scalegraph/util/MemoryChunk.h>
#undef ORG_SCALEGRAPH_UTIL_MEMORYCHUNK_H_NODEPS

namespace x10 { namespace lang { 
class String;
} } 
namespace org { namespace scalegraph { namespace exception { 
class PyXPregelException;
} } } 
namespace org { namespace scalegraph { namespace api { 
class PyXPregelPipe;
} } } 
namespace x10 { namespace lang { 
class LongRange;
} } 
namespace x10 { namespace lang { 
template<class TPMGL(Z1), class TPMGL(Z2)> class VoidFun_0_2;
} } 

namespace org { namespace scalegraph { namespace api {

struct NativePyXPregelAdapterProperty {
    long long outEdge_offsets_size;
    long long outEdge_vertexes_size;
    long long inEdge_offsets_size;
    long long inEdge_vertexes_size;
    long long vertexValue_size;
    int vertexValue_type;
    long long vertexActive_mc_size;
    long long vertexShouldBeActive_mc_size;
    long long message_values_size;
    long long message_offsets_size;
    int message_value_type;
    long long vertex_range_min;
    long long vertex_range_max;
};

class NativePyXPregelAdapter : public ::x10::lang::X10Class {
  public:
    RTT_H_DECLS_CLASS;

    static NativePyXPregelAdapterProperty property;
    static void* shmemProperty;
    
    void initialize();
    ::org::scalegraph::api::PyXPregelPipe fork(x10_long place_id, x10_long thread_id,
                                               x10_long idx,  ::x10::lang::LongRange i_range);
    ::org::scalegraph::api::PyXPregelPipe fork(x10_long place_id, x10_long thread_id,
                                               x10_long idx,  ::x10::lang::LongRange i_range,
                                               ::x10::lang::VoidFun_0_2<x10_long,  ::x10::lang::LongRange>* func);
    template<class TPMGL(T)> void copyFromBuffer(::org::scalegraph::util::MemoryChunk< x10_byte> buffer, x10_long offset, x10_long size_to_copy, TPMGL(T) object);

    static void setProperty_outEdge_offsets_size(x10_long value) {
        property.outEdge_offsets_size = value;
    }

    static void setProperty_outEdge_vertexes_size(x10_long value) {
        property.outEdge_vertexes_size = value;
    }

    static void setProperty_inEdge_offsets_size(x10_long value) {
        property.inEdge_offsets_size = value;
    }

    static void setProperty_inEdge_vertexes_size(x10_long value) {
        property.inEdge_vertexes_size = value;
    }

    static void setProperty_vertexValue_size(x10_long value) {
        property.vertexValue_size = value;
    }

    static void setProperty_vertexValue_type(x10_int value) {
        property.vertexValue_type = value;
    }

    static void setProperty_vertexActive_mc_size(x10_long value) {
        property.vertexActive_mc_size = value;
    }

    static void setProperty_vertexShouldBeActive_mc_size(x10_long value) {
        property.vertexShouldBeActive_mc_size = value;
    }

    static void setProperty_message_values_size(x10_long value) {
        property.message_values_size = value;
    }

    static void setProperty_message_offsets_size(x10_long value) {
        property.message_offsets_size = value;
    }
    
    static void setProperty_message_value_type(x10_int value) {
        property.message_value_type = value;
    }

    static void setProperty_vertex_range_min(x10_long value) {
        property.vertex_range_min = value;
    }

    static void setProperty_vertex_range_max(x10_long value) {
        property.vertex_range_max = value;
    }
    
    static void createShmemProperty(x10_long place_id);
    static void updateShmemProperty();
    
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