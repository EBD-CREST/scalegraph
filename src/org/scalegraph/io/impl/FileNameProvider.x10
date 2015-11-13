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

import org.scalegraph.io.FileReader;
import org.scalegraph.io.FileWriter;
import org.scalegraph.io.FileMode;
import org.scalegraph.io.GenericFileSystem;
import org.scalegraph.io.FilePath;

public abstract class FileNameProvider implements Iterable[FilePath] {
	protected val filePath :FilePath;
	public def this(_filePath :FilePath) {
		this.filePath = _filePath;
	}
	public abstract def isScattered() : Boolean;
	public abstract def getIndexedFileName(index :Int) :String;
	public def getIndexedFilePath(index :Int) =
		new FilePath(filePath.fsType, getIndexedFileName(index));
	public def getFilePath(path :String) =
		new FilePath(filePath.fsType, path);
	public def mkdir() {
		// default method assumes the path pointing to the normal file
		val path = filePath.pathString;
		val last_sep = path.lastIndexOf(GenericFileSystem.SEPARATOR);
		if(last_sep > 0) {
			(new GenericFileSystem(getFilePath(path.substring(0n, last_sep)))).mkdirs();
		}
	}
	public abstract def deleteFile() :void;
	public abstract def openRead(index :Int) :FileReader;
	public abstract def openWrite(index :Int) :FileWriter;
	
	// End of FileNameProvider definition //
	
	private static class PathIterator implements Iterator[FilePath] {
		private val th :FileNameProvider;
		private var index :Int;
		public def this(th :FileNameProvider) { index = 0n; this.th = th; }
		public def hasNext() = 
			(new GenericFileSystem(th.getIndexedFilePath(index))).exists();
		public def next() = th.getIndexedFilePath(index++);
	}

	private static class SingleFileNameProvider extends FileNameProvider {
		public def this(_filePath : FilePath) {
			super(_filePath);
		}
		public def isScattered() = false;
		public def getIndexedFileName(index :Int) = filePath.pathString;
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
		public def getIndexedFileName(index :Int) :String {
			return String.format(filePath.pathString, [index as Any]);
		}
		public def deleteFile() {
			var index :Int = 0n;
			do {
				val file = new GenericFileSystem(getIndexedFilePath(index));
				if (!file.exists()) break;
				file.delete();
			} while(true);
		}
		public def openRead(index :Int) = 
			new FileReader(getIndexedFilePath(index));
		public def openWrite(index :Int) = 
			new FileWriter(getIndexedFilePath(index), FileMode.Create);
		public def iterator() = new PathIterator(this);
		
	}

	private static class DirectoryScatteredFileNameProvider extends FileNameProvider {
		public def this(_filePath : FilePath) {
			super(_filePath);
		}
		public def isScattered() = true;
		public def getIndexedFileName(index :Int) :String { 
			return String.format("%s/part-%05d" as String, [filePath.pathString, index]);
		}
		public def mkdir() {
			(new GenericFileSystem(filePath)).mkdirs();
		}
		public def deleteFile() {
			val dir = new GenericFileSystem(filePath);
			for(i in 0..(dir.list().size-1)) {
				new GenericFileSystem(getIndexedFilePath(i as Int)).delete();
			}
		}
		public def openRead(index :Int) = 
			new FileReader(getIndexedFilePath(index));
		public def openWrite(index :Int) = 
			new FileWriter(getIndexedFilePath(index), FileMode.Create);
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
			return new NumberScatteredFileNameProvider(filePath);
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
	public static def createForRead(filePath :FilePath)
			= create(filePath, true, false);
	
	/**
	 * Creates appropriate file manager instance.
	 * @param path filename passed by user
	 * @param scattered hint to choose file manager
	 */
	public static def createForWrite(filePath :FilePath, scattered :Boolean)
			= create(filePath, false, scattered);
}
