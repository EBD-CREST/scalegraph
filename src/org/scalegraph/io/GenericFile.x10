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

import x10.io.File;
import x10.io.IOException;

import org.scalegraph.util.MemoryChunk;
import org.scalegraph.util.SString;

public class GenericFile {
	public static val NATIVEFILE: Int = 0n;
	public static val HDFSFILE: Int = 1n;

	public static val BEGIN: Int = 0n;
	public static val CURRENT: Int = 1n;
	public static val END: Int = 2n;

	private val fileSystem: Int;
	private transient var nativeFile: NativeFile;
	private transient var hdfsFile: HDFSFile;

	public def this(path: SString, fileMode :Int, fileAccess :Int) {
		fileSystem = HDFSFILE;
		switch (fileSystem) {
			case NATIVEFILE:
				nativeFile = new NativeFile(path, fileMode, fileAccess);
				break;
			case HDFSFILE:
				hdfsFile = new HDFSFile(path, fileMode, fileAccess);
				break;
		}
	}

	public def close(): void {
		switch (fileSystem) {
			case NATIVEFILE:
				nativeFile.close();
				break;
			case HDFSFILE:
				hdfsFile.close();
				break;
		}
	}

	public def read(buffer: MemoryChunk[Byte]): Long {
		switch (fileSystem) {
			case NATIVEFILE:
				return nativeFile.read(buffer);
			case HDFSFILE:
				return hdfsFile.read(buffer);
		}
		return 0n;
	}

	public def write(buffer: MemoryChunk[Byte]): void {
		switch (fileSystem) {
			case NATIVEFILE:
				nativeFile.write(buffer);
				break;
			case HDFSFILE:
				hdfsFile.write(buffer);
				break;
		}
	}

	public def seek(offset: Long, origin: Int): void {
		switch (fileSystem) {
			case NATIVEFILE:
				nativeFile.seek(offset, origin);
				break;
			case HDFSFILE:
				hdfsFile.seek(offset, origin);
				break;
		}
	}

	public def getpos(): Long {
		switch (fileSystem) {
			case NATIVEFILE:
				return nativeFile.getpos();
			case HDFSFILE:
				return hdfsFile.getpos();
		}
		return 0n;
	}
 }
