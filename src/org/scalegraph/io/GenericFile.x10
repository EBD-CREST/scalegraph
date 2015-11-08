/* 
 *  This file is part of the ScaleGraph project (http://scalegraph.org).
 * 
 *  This file is licensed to You under the Eclipse Public License (EPL);
 *  You may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *      http://www.opensource.org/licenses/eclipse-1.0.php
 * 
 *  (C) Copyright ScaleGraph Team 2011-2012.
 */

package org.scalegraph.io;

import x10.io.File;
import x10.io.IOException;

import org.scalegraph.util.MemoryChunk;
import org.scalegraph.util.SString;

public class GenericFile {
	public static val BEGIN: Int = 0n;
	public static val CURRENT: Int = 1n;
	public static val END: Int = 2n;

	private transient val nativeFile: NativeFile;
	
	public def this(path: SString, fileMode :Int, fileAccess :Int) {
		nativeFile = new NativeFile(path, fileMode, fileAccess);
	}

	public def close(): void {
		nativeFile.close();
	}

	public def read(buffer: MemoryChunk[Byte]): Long {
		return nativeFile.read(buffer);
	}

	public def write(buffer: MemoryChunk[Byte]): void {
		nativeFile.write(buffer);
	}

	public def seek(offset: Long, origin: Int): void {
		nativeFile.seek(offset, origin);
	}

	public def getpos(): Long {
		return nativeFile.getpos();
	}
 }
