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

@NativeCPPInclude("NativePyException.h")
@NativeCPPCompilationUnit("NativePyException.cc")
@NativeRep("c++", "org::scalegraph::python::NativePyException*", "org::scalegraph::python::NativePyException", null)
@Pinned public class NativePyException extends CheckedThrowable {
	public var strType: String;
	public var strValue: String;
	public var strTraceback: String;
	var pType: NativePyObject;
	var pValue: NativePyObject;
	var pTraceback: NativePyObject;
	public native def extractExcInfo() :void;
	public native def INCREF() :void;
	public native def DECREF() :void;
	public native def XDECREF() :void;
	public native def CLEAR() :void;
}
