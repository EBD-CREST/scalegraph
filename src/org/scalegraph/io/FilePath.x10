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

public struct FilePath {

	public val FILEPATH_FS_OS		:Int = 0n;
	public val FILEPATH_FS_HDFS		:Int = 1000n;

	public val fsType		:Int;
	public val pathString	:String;

	public def this(_fsType: Int, _pathString: String) {
		fsType = _fsType;
		pathString = _pathString;
	}
}
