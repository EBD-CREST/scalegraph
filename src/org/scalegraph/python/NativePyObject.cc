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

NativePyObject* NativePyObject::_make() {
    NativePyObject* ret = new NativePyObject();
    ret->_constructor();
    return ret;
}

void NativePyObject::_constructor() {
}

RTT_CC_DECLS0(NativePyObject, "org.scalegraph.python.NativePyObject", x10aux::RuntimeType::class_kind)

}}} // namespace org { namespace scalegraph { namespace python {
