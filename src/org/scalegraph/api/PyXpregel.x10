/* 
 *  This file is part of the ScaleGraph project (http://scalegraph.org).
 * 
 *  This file is licensed to You under the Eclipse Public License (EPL);
 *  You may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *      http://www.opensource.org/licenses/eclipse-1.0.php
 * 
 *  (C) Copyright ScaleGraph Team 2011-2012.
 */

package org.scalegraph.api;

import org.scalegraph.Config;
import org.scalegraph.graph.Graph;
import org.scalegraph.blas.DistSparseMatrix;
import org.scalegraph.community.SpectralClusteringImpl;
import org.scalegraph.io.ID;
import org.scalegraph.util.DistMemoryChunk;
import org.scalegraph.util.Logger;
import org.scalegraph.util.MemoryChunk;
import org.scalegraph.util.SString;
import org.scalegraph.python.NativePython;
import org.scalegraph.python.NativePyObject;
import org.scalegraph.python.NativePyException;

final public class PyXpregel {

	public def this() {}

	public def test() {
		Logger.print("hogehoge...");

		val python = new NativePython();
		try {
			val main = python.importAddModule("__main__");
			val globals = python.moduleGetDict(main);
			val locals = python.dictNew();
			val mc = MemoryChunk.make[Double](5);
			mc(0) = 3.14159265;
			mc(1) = 1.41421356;
			mc(2) = 2.43620679;
			mc(3) = 0.4342944819;
			mc(4) = 65536.0 * 65536.0;
			val pobj = python.memoryViewFromMemoryChunk(mc);
			python.dictSetItemString(locals, "mview", pobj);
			python.runString("print(mview.cast('d').tolist())", globals, locals);
		} catch (exception :NativePyException) {
			exception.extractExcInfo();
			Console.OUT.println("catched exception");
			Console.OUT.println(exception.strValue);
			Console.OUT.println(exception.strTraceback);
			exception.DECREF();
		}
		python.finalize();
	}

}
