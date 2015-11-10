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

import x10.io.IOException;
import org.scalegraph.util.MemoryChunk;
import org.scalegraph.util.SString;

public class GenericFile {
	public static val OS: Int = 0n;
	public static val HDFS: Int = 1n;

	public static val BEGIN: Int = 0n;
	public static val CURRENT: Int = 1n;
	public static val END: Int = 2n;

	private val fileSystem: Int;
	private transient var osFile: NativeOSFile;
	private transient var hdfsFile: NativeHDFSFile;

	public def this(path: SString, fileMode :Int, fileAccess :Int) {
		fileSystem = HDFS;
		switch (fileSystem) {
			case OS:
				osFile = new NativeOSFile(path, fileMode, fileAccess);
				break;
			case HDFS:
				hdfsFile = new NativeHDFSFile(path, fileMode, fileAccess);
				break;
		}
	}

	public def close(): void {
		switch (fileSystem) {
			case OS:
				osFile.close();
				break;
			case HDFS:
				hdfsFile.close();
				break;
		}
	}

	public def read(buffer: MemoryChunk[Byte]): Long {
		switch (fileSystem) {
			case OS:
				return osFile.read(buffer);
			case HDFS:
				return hdfsFile.read(buffer);
		}
		return 0n;
	}

	public def write(buffer: MemoryChunk[Byte]): void {
		switch (fileSystem) {
			case OS:
				osFile.write(buffer);
				break;
			case HDFS:
				hdfsFile.write(buffer);
				break;
		}
	}

	public def seek(offset: Long, origin: Int): void {
		switch (fileSystem) {
			case OS:
				osFile.seek(offset, origin);
				break;
			case HDFS:
				hdfsFile.seek(offset, origin);
				break;
		}
	}

	public def getpos(): Long {
		switch (fileSystem) {
			case OS:
				return osFile.getpos();
			case HDFS:
				return hdfsFile.getpos();
		}
		return 0n;
	}
 }
