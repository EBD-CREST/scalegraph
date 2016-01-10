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
//#include <org/scalegraph/util/MemoryChunk.h>
#include <org/scalegraph/api/NativePyXPregelAdapter.h>

namespace org { namespace scalegraph { namespace api {


static PyObject* x10xpregeladapter_placeid(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":placeid")) {
        return NULL;
    }
    return PyLong_FromLong(12345678);
}


static PyMethodDef X10XPregelAdapterMethods[] = {
    {"placeid", x10xpregeladapter_placeid, METH_VARARGS,
     "Return the place id of the runnning process."},
    {NULL, NULL, 0, NULL}
};


static PyModuleDef X10XPregelAdapterModule = {
    PyModuleDef_HEAD_INIT, "x10xpregeladapter", NULL, -1, X10XPregelAdapterMethods,
    NULL, NULL, NULL, NULL
};


static PyObject* PyInit_x10xpregeladapter(void) {
    return PyModule_Create(&X10XPregelAdapterModule);
}


//-----------------------------------------

void NativePyXPregelAdapter::initialize() {
    PyImport_AppendInittab("x10xpregeladapter", &PyInit_x10xpregeladapter);
}


//-----------------------------------------

NativePyXPregelAdapter* NativePyXPregelAdapter::NativePyXPregelAdapter____this__NativePyXPregelAdapter() {
    return this;
}

void NativePyXPregelAdapter::_constructor() {
    this->NativePyXPregelAdapter::__fieldInitializers_NativePyXPregelAdapter();
}

NativePyXPregelAdapter* NativePyXPregelAdapter::_make() {
    NativePyXPregelAdapter* this_ = new (::x10aux::alloc_z< NativePyXPregelAdapter>())  NativePyXPregelAdapter();
    this_->_constructor();
    return this_;
}

void NativePyXPregelAdapter::__fieldInitializers_NativePyXPregelAdapter() {
    //    this->FMGL(strtmp) = (::x10aux::class_cast_unchecked< ::x10::lang::String*>(reinterpret_cast< ::x10::lang::NullType*>(X10_NULL)));
}
const ::x10aux::serialization_id_t NativePyXPregelAdapter::_serialization_id = 
    ::x10aux::DeserializationDispatcher::addDeserializer( NativePyXPregelAdapter::_deserializer);

void NativePyXPregelAdapter::_serialize_body(::x10aux::serialization_buffer& buf) {
    //    buf.write(this->FMGL(strtmp));
    
}

::x10::lang::Reference*  NativePyXPregelAdapter::_deserializer(::x10aux::deserialization_buffer& buf) {
     NativePyXPregelAdapter* this_ = new (::x10aux::alloc_z< NativePyXPregelAdapter>())  NativePyXPregelAdapter();
    buf.record_reference(this_);
    this_->_deserialize_body(buf);
    return this_;
}

void NativePyXPregelAdapter::_deserialize_body(::x10aux::deserialization_buffer& buf) {
    //    FMGL(strtmp) = buf.read< ::x10::lang::String*>();
}

::x10aux::RuntimeType NativePyXPregelAdapter::rtt;
void NativePyXPregelAdapter::_initRTT() {
    if (rtt.initStageOne(&rtt)) return;
    const ::x10aux::RuntimeType** parents = NULL; 
    rtt.initStageTwo("NativePyXPregelAdapter",::x10aux::RuntimeType::class_kind, 0, parents, 0, NULL, NULL);
}


}}} // namespace org { namespace scalegraph { namespace api {
