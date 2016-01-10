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

#include <x10rt.h>

namespace org { namespace scalegraph { namespace api {

class NativePyXPregelAdapter : public ::x10::lang::X10Class {
  public:
    RTT_H_DECLS_CLASS;

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
            
}}} // namespace org { namespace scalegraph { namespace api {

#endif // __ORG_SCALEGRAPH_API_NATIVEPYXPREGELADAPTER_H
