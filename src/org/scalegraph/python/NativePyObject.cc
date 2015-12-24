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
#include <org/scalegraph/python/NativePyObject.h>

namespace org { namespace scalegraph { namespace python {

NativePyObject* NativePyObject::_make(PyObject* po) {
    NativePyObject* ret = new NativePyObject();
    ret->_constructor(po);
    return ret;
}

void NativePyObject::_constructor(PyObject* po) {
    FMGL(pointer) = po;
}

//RTT_CC_DECLS0(NativePyObject, "org.scalegraph.python.NativePyObject", x10aux::RuntimeType::class_kind)

void NativePyObject::__fieldInitializers_NativePyObject() {
    //    this->FMGL(strtmp) = (::x10aux::class_cast_unchecked< ::x10::lang::String*>(reinterpret_cast< ::x10::lang::NullType*>(X10_NULL)));
}
const ::x10aux::serialization_id_t NativePyObject::_serialization_id = 
    ::x10aux::DeserializationDispatcher::addDeserializer( NativePyObject::_deserializer);

void NativePyObject::_serialize_body(::x10aux::serialization_buffer& buf) {
    //    buf.write(this->FMGL(strtmp));
}

::x10::lang::Reference*  NativePyObject::_deserializer(::x10aux::deserialization_buffer& buf) {
     NativePyObject* this_ = new (::x10aux::alloc_z< NativePyObject>())  NativePyObject();
    buf.record_reference(this_);
    this_->_deserialize_body(buf);
    return this_;
}

void NativePyObject::_deserialize_body(::x10aux::deserialization_buffer& buf) {
    //    FMGL(strtmp) = buf.read< ::x10::lang::String*>();
}

::x10aux::RuntimeType NativePyObject::rtt;
void NativePyObject::_initRTT() {
    if (rtt.initStageOne(&rtt)) return;
    const ::x10aux::RuntimeType** parents = NULL; 
    rtt.initStageTwo("NativePyObject",::x10aux::RuntimeType::class_kind, 0, parents, 0, NULL, NULL);
}


}}} // namespace org { namespace scalegraph { namespace python {
