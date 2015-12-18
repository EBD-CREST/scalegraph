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

package org.scalegraph.python;

import x10.compiler.Native;
import x10.compiler.NativeRep;
import x10.compiler.NativeCPPInclude;
import x10.compiler.NativeCPPCompilationUnit;
import x10.compiler.Pinned;

@NativeCPPInclude("NativePyObject.h")
@NativeCPPCompilationUnit("NativePyObject.cc")
@NativeRep("c++", "org::scalegraph::python::NativePyObject", "org::scalegraph::python::NativePyObject", null)
@Pinned public struct NativePyObject {
	public native def incref() :void;
	public native def xincref() :void;
	public native def decref() :void;
	public native def xdecref() :void;
	public native def clear() :void;
}
