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
package org.scalegraph.io.impl;

import org.scalegraph.util.SString;
import org.scalegraph.io.FileReader;
import org.scalegraph.io.FileWriter;
import org.scalegraph.io.FileMode;
import org.scalegraph.io.GenericFileSystem;

public abstract class FileNameProvider implements Iterable[SString] {
	protected val filePath :FilePath;
	public def this(_filePath :FilePath) {
		this.filePath = _filePath;
	}
	public abstract def isScattered() : Boolean;
	public abstract def fileName(index :Int) :String;
	public def mkdir() {
		// default method assumes the path pointing to the normal file
		val last_sep = filePath.pathString.lastIndexOf(GenericFileSystem.SEPARATOR);
		if(last_sep > 0) {
			(new GenericFileSystem(filePath.pathString.substring(0n, last_sep).toString())).mkdirs();
		}
	}
	public abstract def deleteFile() :void;
	public abstract def openRead(index :Int) :FileReader;
	public abstract def openWrite(index :Int) :FileWriter;
	
	// End of FileNameProvider definition //
	
	private static class PathIterator implements Iterator[SString] {
		private val th :FileNameProvider;
		private var index :Int;
		public def this(th :FileNameProvider) { index = 0n; this.th = th; }
		public def hasNext() = 
			new GenericFileSystem(new FilePath(th.filePath.fsType,
											   th.fileName(index))).exists();
		public def next() = th.fileName(index++);
	}

	private static class SingleFileNameProvider extends FileNameProvider {
		public def this(_filePath : FilePath) {
			super(_filePath);
		}
		public def isScattered() = false;
		public def fileName(index :Int) = filePath.pathString;
		public def deleteFile() {
			(new GenericFileSystem(filePath)).delete();
		}
		public def openRead(index :Int) = 
			new FileReader(filePath);
		public def openWrite(index :Int) = 
			new FileWriter(filePath, FileMode.Create);
		
		private static class SinglePathIterator extends PathIterator {
			public def this(th :FileNameProvider) { super(th); }
			public def hasNext() = (index == 0n);
		}
		public def iterator() = new SinglePathIterator(this);
	}

	private static class NumberScatteredFileNameProvider extends FileNameProvider {
		public def this(_filePath : FilePath) {
			super(_filePath);
		}
		public def isScattered() = true;
		public def fileName(index :Int) = 
			String.format(filePath.pathString, index);
		public def deleteFile() {
			var index :Int = 0n;
			do {
				val file = new GenericFileSystem(new FilePath(filePath.fsType,
															  fileName(index).toString()));
				if (!file.exists()) break;
				file.delete();
			} while(true);
		}
		public def openRead(index :Int) = 
			new FileReader(new FilePath(filePath.fsType, fileName(index));
		public def openWrite(index :Int) = 
			new FileWriter(new FilePath(filePath.fsType, fileName(index)), FileMode.Create);
		public def iterator() = new PathIterator(this);
		
	}

	private static class DirectoryScatteredFileNameProvider extends FileNameProvider {
		public def this(_filePath : FilePath) {
			super(_filePath);
		}
		public def isScattered() = true;
		public def fileName(index :Int) = 
			String.format("%s/part-%05d" as String, filePath.pathString, index);
		public def mkdir() {
			(new GenericFileSystem(filePath).mkdirs();
		}
		public def deleteFile() {
			val dir = new GenericFileSystem(filePath);
			for(i in 0..(dir.list().size-1)) {
				new GenericFileSystem(new FilePath(filePath.fsType, 
												   fileName(i as Int))).delete();
			}
		}
		public def openRead(index :Int) = 
				new FileReader(new FilePath(filePath.fsType, fileName(index)));
		public def openWrite(index :Int) = 
			new FileWriter(new FilePath(filePath.fsType, fileName(index)), FileMode.Create);
		public def iterator() = new PathIterator(this);
		
	}
	
	/**
	 * Creates appropriate file manager instance.
	 * @param path filename passed by user
	 * @param scattered hint to choose file manager
	 */
	private static def create(filePath :FilePath, isRead :Boolean, scattered :Boolean) {
		val path = filePath.pathString;
		val num_pos = path.indexOf("%d");
		if(num_pos != -1n) {
			val last_sep = path.lastIndexOf(GenericFileSystem.SEPARATOR);
			if(last_sep > num_pos) {
				throw new IllegalArgumentException("Number position may not be on a directory name.");
			}
			return new NumberScatteredFileNameProvider(path);
		}
		if(isRead) {
			val file = new GenericFileSystem(filePath);
			if(file.isFile()) {
				return new SingleFileNameProvider(filePath);
			}
			if(file.isDirectory()) {
				return new DirectoryScatteredFileNameProvider(filePath);
			}
			throw new IllegalArgumentException("Provided path does not name a file nor a directory.");
		}
		else {
			if(scattered) {
				return new DirectoryScatteredFileNameProvider(filePath);
			}
			return new SingleFileNameProvider(filePath);
		}
	}
	
	/**
	 * Creates appropriate file manager instance.
	 * @param path filename passed by user
	 * @param scattered hint to choose file manager
	 */
	public static def createForRead(filePath :filePath)
			= create(filePath, true, false);
	
	/**
	 * Creates appropriate file manager instance.
	 * @param path filename passed by user
	 * @param scattered hint to choose file manager
	 */
	public static def createForWrite(filePath :filePath, scattered :Boolean)
			= create(filePath, false, scattered);
}
