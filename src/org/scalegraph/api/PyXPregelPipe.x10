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

package org.scalegraph.api;

import org.scalegraph.io.GenericFile;

public struct PyXPregelPipe {

	public val stdin :GenericFile;
	public val stdout :GenericFile;
	public val stderr :GenericFile;

	public def this(stdin_fd :Int, stdout_fd :Int, stderr_fd :Int) {
		stdin = new GenericFile(stdin_fd);
		stdout = new GenericFile(stdout_fd);
		stderr = new GenericFile(stderr_fd);
	}

	public def this() {
		stdin = new GenericFile();
		stdout = new GenericFile();
		stderr = new GenericFile();
	}
}
