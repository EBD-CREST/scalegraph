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

package org.scalegraph.io;

import x10.compiler.Native;
import x10.compiler.NativeRep;
import x10.compiler.NativeCPPInclude;
import x10.compiler.NativeCPPCompilationUnit;

import x10.compiler.Pinned;

import org.scalegraph.util.MemoryChunk;
import org.scalegraph.util.SString;

@NativeCPPInclude("NativeHDFSFileSystem.h")
@NativeCPPCompilationUnit("NativeHDFSFileSystem.cc")
@NativeRep("c++", "org::scalegraph::io::NativeHDFSFileSystem", "org::scalegraph::io::NativeHDFSFileSystem", null)
@Pinned public struct NativeHDFSFileSystem {

	public native def this(name: String);
	public native def isFile() :Boolean;
	public native def isDirectory() :Boolean;
	public native def exists() :Boolean;
	public def delete() :void {
		// no implementation
		assert(false);
	}
	public def mkdirs() :void {
		// do nothing
	}
	public native def size() :Long;
	public def list() :Rail[String] {
		// no implementation
		assert(false);
		return new Rail[String]();
	}
}
