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
#define ORG_SCALEGRAPH_PYTHON_NATIVEPYOBJECT_H_NODEPS
#include <org/scalegraph/python/NativePyObject.h>
#undef ORG_SCALEGRAPH_PYTHON_NATIVEPYOBJECT_H_NODEPS


namespace org { namespace scalegraph { namespace python {

struct NativePython {
  public:
    RTT_H_DECLS_CLASS;

    NativePython() {}

    static NativePython _make();
    void _constructor();
    NativePython* operator->() { return this; }

    void test();
    ::org::scalegraph::python::NativePyObject importModule(::x10::lang::String* name);
    void calltest(::org::scalegraph::python::NativePyObject module);
    
	// Serialization
	static void _serialize(NativePython this_, x10aux::serialization_buffer& buf) {
		assert (false);
	}
	static NativePython _deserializer(x10aux::deserialization_buffer& buf) {
		assert (false);
	}
    
};
            
}}} // namespace org { namespace scalegraph { namespace python {

#endif // __ORG_SCALEGRAPH_PYTHON_NATIVEPYTHON_H
