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
#include <org/scalegraph/python/NativePyObject.h>

namespace org { namespace scalegraph { namespace python {

class NativePyObject_ibox0 : public ::x10::lang::IBox< NativePyObject> {
public:
    static  ::x10::lang::Any::itable< NativePyObject_ibox0 > itable;
    x10_boolean equals( ::x10::lang::Any* arg0) {
        return this->value->equals(arg0);
    }
    x10_int hashCode() {
        return this->value->hashCode();
    }
     ::x10::lang::String* toString() {
        return this->value->toString();
    }
     ::x10::lang::String* typeName() {
        return this->value->typeName();
    }
    
};
 ::x10::lang::Any::itable< NativePyObject_ibox0 >  NativePyObject_ibox0::itable(&NativePyObject_ibox0::equals, &NativePyObject_ibox0::hashCode, &NativePyObject_ibox0::toString, &NativePyObject_ibox0::typeName);
 ::x10::lang::Any::itable<  NativePyObject >  NativePyObject::_itable_0(&NativePyObject::equals, &NativePyObject::hashCode, &NativePyObject::toString, &NativePyObject::typeName);
::x10aux::itable_entry NativePyObject::_itables[2] = {::x10aux::itable_entry(&::x10aux::getRTT< ::x10::lang::Any>, &NativePyObject::_itable_0), ::x10aux::itable_entry(NULL, (void*)" NativePyObject")};
::x10aux::itable_entry NativePyObject::_iboxitables[2] = {::x10aux::itable_entry(&::x10aux::getRTT< ::x10::lang::Any>, &NativePyObject_ibox0::itable), ::x10aux::itable_entry(NULL, (void*)" NativePyObject")};


 ::x10::lang::String* NativePyObject::typeName(){
    return ::x10aux::type_name((*this));
}
 ::x10::lang::String* NativePyObject::toString() {
     return ::x10::lang::String::_make("<NativePyObject>", false);
    
}
x10_int NativePyObject::hashCode() {
    x10_int result = ((x10_int)1);
    assert(false);
    return result;
    
}
x10_boolean NativePyObject::equals( ::x10::lang::Any* other) {
    if (!(::x10aux::instanceof< NativePyObject>(other))) {
        return false;
        
    }
    return (*this) -> NativePyObject::equals(::x10aux::class_cast< NativePyObject>(other));
    
}
x10_boolean NativePyObject::_struct_equals( ::x10::lang::Any* other) {
    if (!(::x10aux::instanceof< NativePyObject>(other))) {
        return false;
        
    }
    return (*this) -> NativePyObject::_struct_equals(::x10aux::class_cast< NativePyObject>(other));
    
}
void  NativePyObject::_serialize( NativePyObject this_, ::x10aux::serialization_buffer& buf) {
    
}

void  NativePyObject::_deserialize_body(::x10aux::deserialization_buffer& buf) {
    assert(false);
}


::x10aux::RuntimeType NativePyObject::rtt;
void NativePyObject::_initRTT() {
    if (rtt.initStageOne(&rtt)) return;
    const ::x10aux::RuntimeType* parents[1] = { ::x10aux::getRTT< ::x10::lang::Any>()};
    rtt.initStageTwo("NativePyObject",::x10aux::RuntimeType::struct_kind, 1, parents, 0, NULL, NULL);
}



}}} // namespace org { namespace scalegraph { namespace python {
