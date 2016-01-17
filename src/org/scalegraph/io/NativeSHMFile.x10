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

@NativeCPPInclude("NativeSHMFile.h")
@NativeCPPCompilationUnit("NativeSHMFile.cc")
@NativeRep("c++", "org::scalegraph::io::NativeSHMFile", "org::scalegraph::io::NativeSHMFile", null)
@Pinned public struct NativeSHMFile {

	public native def this(name: SString, fileMode :Int, fileAccess :Int);
	public native def close(): void;
	public native def flush(): void;
	public native def copyToShmem[T](buffer: T): void;
	public native def copyToShmem[T](buffer: T, size_to_copy: Long): void;
	public native def copyFromShmem[T](buffer: T): void;
	public native def copyFromShmem[T](buffer: T, size_to_copy: Long): void;
	public native static def unlink(name: String): void;
}
