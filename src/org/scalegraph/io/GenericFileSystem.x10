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

public class GenericFileSystem {
	public static val OS :Int = 0n;
	public static val HDFS :Int = 1n;

	public static val SEPARATOR = File.SEPARATOR;

	private val fileSystem: Int;
	private transient var osFileSystem: NativeOSFileSystem;
	private transient var hdfsFileSystem: NativeHDFSFileSystem;

	public def this(path: String) {
		fileSystem = HDFS;
		switch (fileSystem) {
			case OS:
				osFileSystem = new NativeOSFileSystem(path);
				break;
			case HDFS:
				hdfsFileSystem = new NativeHDFSFileSystem(path);
				break;
		}
	}

	public def isFile() :Boolean {
		switch (fileSystem) {
			case OS:
				return osFileSystem.isFile();
			case HDFS:
				return hdfsFileSystem.isFile();
		}
		return false;
	}

	public def isDirectory() :Boolean {
		switch (fileSystem) {
			case OS:
				return osFileSystem.isDirectory();
			case HDFS:
				return hdfsFileSystem.isDirectory();
		}
		return false;
	}

	public def exists() :Boolean {
		switch (fileSystem) {
			case OS:
				return osFileSystem.exists();
			case HDFS:
				return hdfsFileSystem.exists();
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
		}
	}

	public def size() :Long {
		switch (fileSystem) {
			case OS:
				return osFileSystem.size();
			case HDFS:
				return hdfsFileSystem.size();
		}
		return -1;
	}

	public def list() :Rail[String] {
		switch (fileSystem) {
			case OS:
				return osFileSystem.list();
			case HDFS:
				return hdfsFileSystem.list();
		}
		return new Rail[String]();
	}
}
