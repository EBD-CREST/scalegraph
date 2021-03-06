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

package org.scalegraph.api;

import x10.compiler.Native;
import x10.compiler.NativeRep;
import x10.compiler.NativeCPPInclude;
import x10.compiler.NativeCPPCompilationUnit;
import x10.compiler.Pinned;

import org.scalegraph.util.MemoryChunk;
import org.scalegraph.exception.PyXPregelException;
import org.scalegraph.api.PyXPregelPipe;

@NativeCPPInclude("NativePyXPregelAdapter.h")
@NativeCPPCompilationUnit("NativePyXPregelAdapter.cc")
@NativeRep("c++", "org::scalegraph::api::NativePyXPregelAdapter*", "org::scalegraph::api::NativePyXPregelAdapter", null)
@Pinned public class NativePyXPregelAdapter {

	@Native("c++", "sizeof(x10_byte)")
	public static val sizeofByte: Int = 1n;

	@Native("c++", "sizeof(x10_int)")
	public static val sizeofInt: Int = 4n;

	@Native("c++", "sizeof(x10_long)")
	public static val sizeofLong: Int = 4n;

	@Native("c++", "sizeof(x10_double)")
	public static val sizeofDouble: Int = 4n;

	public native def this();
	public native def initialize() :void;
	public static native def fork(place_id :Long, thread_id :Long, num_threads :Long) throws PyXPregelException :PyXPregelPipe;
	public static native def copyFromBuffer[T](buffer :MemoryChunk[Byte], offset :Long, size_to_copy :Long, object :T) :void;

	public static native def setProperty_numGlobalVertices(value :Long) :void;
	public static native def setProperty_numLocalVertices(value :Long) :void;
	public static native def setProperty_outEdge_offsets_size(value :Long) :void;
	public static native def setProperty_outEdge_vertices_size(value :Long) :void;
	public static native def setProperty_inEdge_offsets_size(value :Long) :void;
	public static native def setProperty_inEdge_vertices_size(value :Long) :void;
	public static native def setProperty_vertexValue_type(value :Int) :void;
	public static native def setProperty_vertexActive_mc_size(value :Long) :void;
	public static native def setProperty_vertexShouldBeActive_mc_size(value :Long) :void;
	public static native def setProperty_message_values_size(value :Long) :void;
	public static native def setProperty_message_offsets_size(value :Long) :void;
	public static native def setProperty_message_value_type(value :Int) :void;

	public static native def createShmemProperty(place_id :Long) :void;
	public static native def updateShmemProperty() :void;

}
