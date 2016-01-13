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

import org.scalegraph.util.MemoryChunk;

public class GenericFile {

	public static val OS: Int = 0n;
	public static val HDFS: Int = 1n;

	public static val STDIN_FILENO = NativeOSFile.STDIN_FILENO;
	public static val STDOUT_FILENO = NativeOSFile.STDOUT_FILENO;
	public static val STDERR_FILENO = NativeOSFile.STDERR_FILENO;

	public static val BEGIN: Int = 0n;
	public static val CURRENT: Int = 1n;
	public static val END: Int = 2n;

	private val fileSystem: Int;
	private transient var osFile: NativeOSFile;
	private transient var hdfsFile: NativeHDFSFile;

	public def this(fd: Int) {
		fileSystem = OS;
		osFile = new NativeOSFile(fd);
	}

	public def this(filePath: FilePath, fileMode :Int, fileAccess :Int) {
		switch (filePath.fsType) {
			case FilePath.FILEPATH_FS_OS:
				fileSystem = OS;
				break;
			case FilePath.FILEPATH_FS_HDFS:
				fileSystem = HDFS;
				break;
			default:
				assert(false);
				fileSystem = OS; // supress compile error
		}
		switch (fileSystem) {
			case OS:
				osFile = new NativeOSFile(filePath.pathString, fileMode, fileAccess);
				break;
			case HDFS:
				hdfsFile = new NativeHDFSFile(filePath.pathString, fileMode, fileAccess);
				break;
			default:
				assert(false);
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
			default:
				assert(false);
		}
	}

	public def read[T](buffer: T): Long {
		switch (fileSystem) {
			case OS:
				return osFile.read[T](buffer);
			case HDFS:
				return hdfsFile.read[T](buffer);
			default:
				assert(false);
		}
		return 0n;
	}

	public def write[T](buffer: T): void {
		switch (fileSystem) {
			case OS:
				osFile.write[T](buffer);
				break;
			case HDFS:
				hdfsFile.write[T](buffer);
				break;
			default:
				assert(false);
		}
	}

	public def write[T](buffer: T, size_to_write: Long): void {
		switch (fileSystem) {
			case OS:
				osFile.write[T](buffer, size_to_write);
				break;
			case HDFS:
				hdfsFile.write[T](buffer, size_to_write);
				break;
			default:
				assert(false);
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
			default:
				assert(false);
		}
	}

	public def getpos(): Long {
		switch (fileSystem) {
			case OS:
				return osFile.getpos();
			case HDFS:
				return hdfsFile.getpos();
			default:
				assert(false);
		}
		return 0n;
	}

	public def flush(): void {
		switch (fileSystem) {
			case OS:
				osFile.flush();
				break;
			case HDFS:
				hdfsFile.flush();
				break;
			default:
				assert(false);
		}
	}
 }
