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

#ifndef __ORG_SCALEGRAPH_PYTHON_NATIVEPYTHONINTEGRATE_H
#define __ORG_SCALEGRAPH_PYTHON_NATIVEPYTHONINTEGRATE_H

#include <x10rt.h>

namespace org { namespace scalegraph { namespace python {

struct NativePythonIntegrate {
  public:
    RTT_H_DECLS_CLASS;

    NativePythonIntegrate() {}

    static NativePythonIntegrate _make();
    void _constructor();
    NativePythonIntegrate* operator->() { return this; }

    void test();
    
	// Serialization
	static void _serialize(NativePythonIntegrate this_, x10aux::serialization_buffer& buf) {
		assert (false);
	}
	static NativePythonIntegrate _deserializer(x10aux::deserialization_buffer& buf) {
		assert (false);
	}
    
};
            
}}} // namespace org { namespace scalegraph { namespace python {

#endif // __ORG_SCALEGRAPH_PYTHON_NATIVEPYTHONINTEGRATE_H
