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
#include <org/scalegraph/python/NativePyException.h>

namespace org { namespace scalegraph { namespace python {

NativePyException* NativePyException::_make() {
    NativePyException* this_ = new NativePyException();
    this_->_constructor();
    return this_;
}

void NativePyException::_constructor() {
    (this)->::x10::lang::CheckedThrowable::_constructor();
}

RTT_CC_DECLS0(NativePyException, "org.scalegraph.python.NativePyException", x10aux::RuntimeType::class_kind)

}}} // namespace org { namespace scalegraph { namespace python {
