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

public struct NativeOSFileSystem {
	public native def this(name: SString);
}
