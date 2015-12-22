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

@NativeCPPInclude("NativePython.h")
@NativeCPPCompilationUnit("NativePython.cc")
@NativeRep("c++", "org::scalegraph::python::NativePython*", "org::scalegraph::python::NativePython", null)
@Pinned public class NativePython {
	public native def this();
	public native def importImport(name: String) throws NativePyException :NativePyObject;
	public native def importAddModule(name: String) throws NativePyException :NativePyObject;
	public native def moduleGetDict(module: NativePyObject) throws NativePyException :NativePyObject;
	public native def dictNew() throws NativePyException :NativePyObject;
	public native def dictSetItemString(dict: NativePyObject, key: String, value: NativePyObject)  throws NativePyException :Int;
	public native def dictGetItemString(dict: NativePyObject, key: String) throws NativePyException :NativePyObject;
	public native def unicodeFromString(str: String) :NativePyObject; 
	public native def unicodeAsASCIIString(obj: NativePyObject) throws NativePyException :String;
	public native def longFromLong(value: Long) throws NativePyException :NativePyObject;
	public native def longAsLong(obj: NativePyObject) throws NativePyException :Long;
	public native def runSimpleString(command: String) :Int;
	public native def runString(command: String, global: NativePyObject, local: NativePyObject) :NativePyObject;
	public native def callObject(callable :NativePyObject, args :Rail[NativePyObject]) throws NativePyException :NativePyObject;
	public native def objectStr(obj: NativePyObject) :String;
//
	public native def test(): void;
	public native def calltest(module :NativePyObject): void;
}
