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

public class GenericFileSystem {
	public static val OS :Int = 0n;
	public static val HDFS :Int = 1n;

	public static val SEPARATOR = File.SEPARATOR;

	private val fileSystem: Int;
	private transient var osFileSystem: NativeOSFileSystem;
	private transient var hdfsFileSystem: NativeHDFSFileSystem;

	public def this(filePath: FilePath) {
		switch (filePath.fsType) {
			case FilePath.FILEPATH_FS_OS:
				fileSystem = OS;
				break;
			case FilePath.FILEPATH_FS_HDFS:
				fileSystem = HDFS;
				break;
			default:
				assert(false);
		}
		switch (fileSystem) {
			case OS:
				osFileSystem = new NativeOSFileSystem(filePath.pathString);
				break;
			case HDFS:
				hdfsFileSystem = new NativeHDFSFileSystem(filePath.pathString);
				break;
			default:
				assert(false);
		}
	}

	public def isFile() :Boolean {
		switch (fileSystem) {
			case OS:
				return osFileSystem.isFile();
			case HDFS:
				return hdfsFileSystem.isFile();
			default:
				assert(false);
		}
		return false;
	}

	public def isDirectory() :Boolean {
		switch (fileSystem) {
			case OS:
				return osFileSystem.isDirectory();
			case HDFS:
				return hdfsFileSystem.isDirectory();
			default:
				assert(false);
		}
		return false;
	}

	public def exists() :Boolean {
		switch (fileSystem) {
			case OS:
				return osFileSystem.exists();
			case HDFS:
				return hdfsFileSystem.exists();
			default:
				assert(false);
		}
		return false;
	}

	public def delete() :void {
		switch (fileSystem) {
			case OS:
				osFileSystem.delete();
				return;
			case HDFS:
				hdfsFileSystem.delete();
				return;
			default:
				assert(false);
		}
	}

	public def mkdirs() :void {
		switch (fileSystem) {
			case OS:
				osFileSystem.mkdirs();
				return;
			case HDFS:
				hdfsFileSystem.mkdirs();
				return;
			default:
				assert(false);
		}
	}

	public def size() :Long {
		switch (fileSystem) {
			case OS:
				return osFileSystem.size();
			case HDFS:
				return hdfsFileSystem.size();
			default:
				assert(false);
		}
		return -1;
	}

	public def list() :Rail[String] {
		switch (fileSystem) {
			case OS:
				return osFileSystem.list();
			case HDFS:
				return hdfsFileSystem.list();
			default:
				assert(false);
		}
		return new Rail[String]();
	}
}
