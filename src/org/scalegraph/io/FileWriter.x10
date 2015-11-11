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

public class FileWriter {
	private transient val gf: GenericFile;
	private var fileOffset: Long;
	
	public def this(filePath :FilePath, fileMode :Int) {
		gf = new GenericFile(filePath, fileMode, FileAccess.Write);
		fileOffset = 0L;
	}
	
	public def reset():void {
		fileOffset = 0L;
		gf.seek(0L, GenericFile.BEGIN);
	}

	public def skip(n: Long):void {
		fileOffset += n;
		gf.seek(n, GenericFile.CURRENT);
	}

	public def close():void {
		fileOffset = 0L;
		gf.close();
	}
	
	public def currentOffset(): Long {
		return fileOffset;
	}
	
	public def write(b: MemoryChunk[Byte]) {
		gf.write(b);
	}

	/*
	public def write(str: SString) {
		write(str.bytes());
	}
	 */
}
