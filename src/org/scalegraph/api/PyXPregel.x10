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

import x10.compiler.Ifdef;

import x10.xrx.Runtime;
import x10.util.ArrayList;
import x10.util.Team;
import org.scalegraph.Config;
import org.scalegraph.io.FilePath;
import org.scalegraph.io.FileAccess;
import org.scalegraph.io.FileMode;
import org.scalegraph.io.GenericFile;
import org.scalegraph.util.Logger;
import org.scalegraph.util.MemoryChunk;
import org.scalegraph.util.SString;
import org.scalegraph.util.Team2;
import org.scalegraph.util.MathAppend;
import org.scalegraph.graph.Graph;
import org.scalegraph.xpregel.PyXPregelGraph;
import org.scalegraph.xpregel.XPregelGraph;
import org.scalegraph.xpregel.VertexContext;
import org.scalegraph.blas.DistSparseMatrix;
import org.scalegraph.python.NativePython;
import org.scalegraph.python.NativePyObject;
import org.scalegraph.python.NativePyException;


import org.scalegraph.graph.GraphGenerator;
import org.scalegraph.util.random.Random;


final public class PyXPregel {

	private static val adapter = new NativePyXPregelAdapter();
	private static val python = new NativePython();
	public static val closures :Cell[MemoryChunk[Byte]] = new Cell[MemoryChunk[Byte]](MemoryChunk.getNull[Byte]());

	public def this() {}

	public def test_memoryViewFromMemoryChunkDouble() {
		Logger.print("hogehoge...");

		adapter.initialize();
		python.initialize();
		python.sysPathAppend("/Users/tosiyuki/EBD/scalegraph-dev/src/python/scalegraph");

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
			python.runString("print(mview.cast('d').tolist())\n" +
							 "sys.stdout.flush()\n",
							 globals, locals);
		} catch (exception :NativePyException) {
			exception.extractExcInfo();
			Console.OUT.println("catched exception");
			Console.OUT.println(exception.strValue);
			Console.OUT.println(exception.strTraceback);
			exception.DECREF();
		}
//		python.finalize();
	}

	public def loadClosures() {
		val path = FilePath(FilePath.FILEPATH_FS_OS, "/Users/tosiyuki/EBD/scalegraph-dev/build/" + "_xpregel_closure.bin");
		val file = new GenericFile(path, FileMode.Open, FileAccess.Read);

		val buffSize = 16;
		val buffArray = new ArrayList[MemoryChunk[Byte]]();
		var totalSize :Long = 0;

		for (;;) {
			val buff = MemoryChunk.make[Byte](buffSize);
			val sizeRead = file.read(buff);
			if (sizeRead == 0) {
				buff.del();
				break;
			} else {
				totalSize += sizeRead;
				buffArray.add(buff);
			}
		}

		val buffTotal = MemoryChunk.make[Byte](totalSize);
		var buffToCopy :Long = totalSize;
		var buffOffset :Long = 0;
		for (buff in buffArray) {
			val sizeCopy = Math.min(buffSize, buffToCopy);
			MemoryChunk.copy(buff, 0, buffTotal, buffOffset, sizeCopy);
			buffToCopy -= sizeCopy;
			buffOffset += sizeCopy;
			buff.del();
		}

		return buffTotal;
	}

	public def test_invokeClosure() {

		adapter.initialize();
		python.initialize();
		python.sysPathAppend("/Users/tosiyuki/EBD/scalegraph-dev/src/python/scalegraph");

//		val loadedClosures = loadClosures();
		val loadedClosures = closures();

//		val python = new NativePython();
		try {
			val main = python.importAddModule("__main__");
			val globals = python.moduleGetDict(main);
			val locals = python.dictNew();
			val pobj = python.memoryViewFromMemoryChunk(loadedClosures);
			python.dictSetItemString(locals, "closures", pobj);
			python.runString("import pickle\n" +
							 "import xpregel\n" +
							 "(pickled_compute, pickled_aggregator, pickled_terminator)=pickle.loads(closures.tobytes())\n" +
							 "compute=pickle.loads(pickled_compute)\n" +
							 "aggregator=pickle.loads(pickled_aggregator)\n" +
							 "terminator=pickle.loads(pickled_terminator)\n" +
							 "import xpregelcontext\n" +
							 "ctx = xpregelcontext.VertexContext()\n" +
							 "compute(ctx, [])\n" +
							 "print(aggregator([1,2,3,4,5,6,7,8,9,10]))\n" +
							 "sys.stdout.flush()\n",
							 globals, locals);
		} catch (exception :NativePyException) {
			exception.extractExcInfo();
			Console.OUT.println("catched exception");
			Console.OUT.println(exception.strValue);
			Console.OUT.println(exception.strTraceback);
			exception.DECREF();
		}
//		python.finalize();
		return true;
	}

	public def shareClosures(loadedClosures :MemoryChunk[Byte]) {

		Team.WORLD.placeGroup().broadcastFlat(() => {
			PyXPregel.closures() = loadedClosures;
		});

	}

	public def test_runpythonclosure() {

		val loadedClosures = loadClosures();
		shareClosures(loadedClosures);

		Team.WORLD.placeGroup().broadcastFlat(() => {
			test_invokeClosure();
		});

	}

/*
	public def test_forkprocess() {

		adapter.initialize();

		try {
			val pipe = adapter.fork(here.id, 0, 123, 0..1, (tid :Long, range :LongRange) => {
				Console.OUT.println("Oni no pants ha ii pants sugoizo tsuyoi zo--- " + tid);
				Console.OUT.println("from " + here.id);
				Console.OUT.flush();
			});
			val file = pipe.stdout;

			val buffSize = 16;
			val buffArray = new ArrayList[MemoryChunk[Byte]]();
			var totalSize :Long = 0;

			Console.OUT.println("read start");
			for (;;) {
				val buff = MemoryChunk.make[Byte](buffSize);
				val sizeRead = file.read(buff);
				if (sizeRead == 0) {
					buff.del();
					break;
				} else {
					totalSize += sizeRead;
					buffArray.add(buff);
					Console.OUT.println("read " + totalSize);
				}
			}
			Console.OUT.println("read done");
			
			val buffTotal = MemoryChunk.make[Byte](totalSize);
			var buffToCopy :Long = totalSize;
			var buffOffset :Long = 0;
			for (buff in buffArray) {
				val sizeCopy = Math.min(buffSize, buffToCopy);
				MemoryChunk.copy(buff, 0, buffTotal, buffOffset, sizeCopy);
				buffToCopy -= sizeCopy;
				buffOffset += sizeCopy;
				buff.del();
			}

			val str = SString(buffTotal);
			Console.OUT.println(str.toString());

		} catch (exception :CheckedThrowable) {
			exception.printStackTrace();
			return;
		}

	}

	public def test_forkprocess_binary() {

		adapter.initialize();

		try {
			val pipe = adapter.fork(here.id, 0, here.id, 0..1, (tid :Long, range :LongRange) => {

				val size = 80000;
				val writebuf = MemoryChunk.make[Long](size);

				for (var i :Long = 0; i < size; i++) {
					writebuf(i) = (tid + 1) * i;
				}

				val file = new GenericFile(GenericFile.STDOUT_FILENO);
				file.write(writebuf, size * NativePyXPregelAdapter.sizeofLong);
			});
			val file = pipe.stdout;

			val buffSize = 16;
			val buffArray = new ArrayList[MemoryChunk[Byte]]();
			var totalSize :Long = 0;

//			Console.OUT.println("read start");
			for (;;) {
				val buff = MemoryChunk.make[Byte](buffSize);
				val sizeRead = file.read(buff);
				if (sizeRead == 0) {
					buff.del();
					break;
				} else {
					totalSize += sizeRead;
					buffArray.add(buff);
//					Console.OUT.println("read " + totalSize);
				}
			}
//			Console.OUT.println("read done");
			
			val buffTotal = MemoryChunk.make[Byte](totalSize);
			var buffToCopy :Long = totalSize;
			var buffOffset :Long = 0;
			for (buff in buffArray) {
				val sizeCopy = Math.min(buffSize, buffToCopy);
				MemoryChunk.copy(buff, 0, buffTotal, buffOffset, sizeCopy);
				buffToCopy -= sizeCopy;
				buffOffset += sizeCopy;
				buff.del();
			}
			
			val receivedLongSize = totalSize / NativePyXPregelAdapter.sizeofLong;
			val receivedLongArray = MemoryChunk.make[Long](receivedLongSize);
			adapter.copyFromBuffer(buffTotal, 0, receivedLongSize * NativePyXPregelAdapter.sizeofLong, receivedLongArray);

			Console.OUT.println("[" + here.id + "] totalSize: " + totalSize +
								" receivedLongSize: " + receivedLongSize);
			var flagOK: Boolean = true;
			for (var i: Long = 0; i < receivedLongSize; i++) {
				if (receivedLongArray(i) != (here.id + 1) * i) {
					flagOK = false;
					break;
				}
			}
			if (flagOK == true) {
				Console.OUT.println("[" + here.id + "] Success");
			} else {
				Console.OUT.println("[" + here.id + "] Fail");
			}

		} catch (exception :CheckedThrowable) {
			exception.printStackTrace();
			return;
		}

	}

	public def redirectStderr(file: GenericFile) {

		val stderr = new GenericFile(GenericFile.STDERR_FILENO);

		val buffSize = 32;
		val buff = MemoryChunk.make[Byte](buffSize);
		for (;;) {
			val sizeRead = file.read(buff);
			if (sizeRead == 0) {
				break;
			} else {
				stderr.write(buff, sizeRead);
				stderr.flush();
			}
		}
	}

	public def test_fork_on_thread(tid :Long) :PyXPregelPipe {

		try {
			val pipe = adapter.fork(here.id, tid, tid, 0..1, (_tid :Long, range :LongRange) => {

				Console.ERR.println("I'm a child of " + here.id + ":" + _tid);

				val size = 80000;
				val writebuf = MemoryChunk.make[Long](size);

				for (var i :Long = 0; i < size; i++) {
					writebuf(i) = ((here.id + 1) * 32 + _tid) * i;
				}

				val file = new GenericFile(GenericFile.STDOUT_FILENO);
//				file.write(writebuf, size * NativePyXPregelAdapter.sizeofLong);
			});
			return pipe;

		} catch (exception :CheckedThrowable) {
			exception.printStackTrace();
			return PyXPregelPipe();
		}
	}

	public def test_read_on_thread(pipe :PyXPregelPipe, tid :Long) :Boolean {

			async redirectStderr(pipe.stderr);

			val file = pipe.stdout;

			val buffSize = 4096;
			val buffArray = new ArrayList[MemoryChunk[Byte]]();
			var totalSize :Long = 0;

			Console.OUT.println("#" + here.id + ":" + tid + " read start");
			for (;;) {
				val buff = MemoryChunk.make[Byte](buffSize);
				val sizeRead = file.read(buff);
				if (sizeRead == 0) {
					buff.del();
					break;
				} else {
					totalSize += sizeRead;
					buffArray.add(buff);
//					Console.OUT.println("#" + here.id + ":" + tid + " read " + totalSize);
				}
			}
			Console.OUT.println("#" + here.id + ":" + tid + " read done");
			
			val buffTotal = MemoryChunk.make[Byte](totalSize);
			var buffToCopy :Long = totalSize;
			var buffOffset :Long = 0;
			for (buff in buffArray) {
				val sizeCopy = Math.min(buffSize, buffToCopy);
				MemoryChunk.copy(buff, 0, buffTotal, buffOffset, sizeCopy);
				buffToCopy -= sizeCopy;
				buffOffset += sizeCopy;
				buff.del();
			}
			
			val receivedLongSize = totalSize / NativePyXPregelAdapter.sizeofLong;
			val receivedLongArray = MemoryChunk.make[Long](receivedLongSize);
			adapter.copyFromBuffer(buffTotal, 0, receivedLongSize * NativePyXPregelAdapter.sizeofLong, receivedLongArray);

//			Console.OUT.println("[" + here.id + "] totalSize: " + totalSize +
//								" receivedLongSize: " + receivedLongSize);
			var flagOK: Boolean = true;
			for (var i: Long = 0; i < receivedLongSize; i++) {
				if (receivedLongArray(i) != ((here.id + 1) * 32 + tid) * i) {
					flagOK = false;
					break;
				}
			}
			if (flagOK == true) {
				Console.OUT.println("#" + here.id + ":" + tid + "  Success");
			} else {
				Console.OUT.println("#" + here.id + ":" + tid + "  Fail");
			}
			
			return flagOK;
	}

	public def test_broadcast_forkprocess_binary() {

		Team.WORLD.placeGroup().broadcastFlat(() => {
			test_forkprocess_binary();
		});

	}

	public def test_call_fork_thread() {
		
		adapter.initialize();

		val nthreads = Runtime.NTHREADS;
		val pipe = new Rail[PyXPregelPipe](nthreads);
		val result = new Rail[Boolean](nthreads);

//		finish for(i in 0..(nthreads - 1)) {
//			async pipe(i) = test_fork_on_thread(i);
//		}
		for(i in 0..(nthreads - 1)) {
			pipe(i) = test_fork_on_thread(i);
		}

		finish for(i in 0..(nthreads - 1)) {
			async result(i) = test_read_on_thread(pipe(i), i);
		}

		for (i in 0..(nthreads - 1)) {
			if (result(i) == true) {
				Console.OUT.println("[" + here.id + ":" + i + "] Success");
			} else {
				Console.OUT.println("[" + here.id + ":" + i + "] Fail");
			}
		}

	}

	public def test_broadcast_call_fork_thread() {

		Team.WORLD.placeGroup().broadcastFlat(() => {
			test_call_fork_thread();
		});

	}

	public def test_write_shmem_on_place() {
		val size = 10000;
		val buffer = MemoryChunk.make[Long](size);

		for (i in 0..(size - 1)) {
			buffer(i) = (here.id + 1) * i;
		}

		val shmem = new GenericFile(FilePath(FilePath.FILEPATH_FS_SHM, "/pyxpregel." + here.id.toString()),
									FileMode.Create, FileAccess.ReadWrite);
		shmem.copyToShmem(buffer, size * NativePyXPregelAdapter.sizeofLong);
	}

	public def test_write_shmem() {

		Team.WORLD.placeGroup().broadcastFlat(() => {

			val nthreads = Runtime.NTHREADS;
			val pipe = new Rail[PyXPregelPipe](nthreads);
			val result = new Rail[Boolean](nthreads);

			test_write_shmem_on_place();
			try {
//				finish for(i in 0..(nthreads - 1)) {
//					async pipe(i) = adapter.fork(here.id, i, here.id, 0..1);
//				}
				for(i in 0..(nthreads - 1)) {
					pipe(i) = adapter.fork(here.id, i, here.id, 0..1);
				}
				finish for(i in 0..(nthreads - 1)) {
					async test_read_on_thread(pipe(i), 0);
				}
			} catch (exception :CheckedThrowable) {
				exception.printStackTrace();
				return;
			}
		});
	}
*/
 
	private def makeGraphFromRmat() {

		val valueInputDataRmatScale		:Int = 10n;
		val valueInputDataRmatEdgefactor :Int = 16n;
		val valueInputDataRmatA			:Double = 0.45;
		val valueInputDataRmatB			:Double = 0.15;
		val valueInputDataRmatC			:Double = 0.15;

		val rnd = new Random(2, 3);
		val edgeList = GraphGenerator.genRMAT(valueInputDataRmatScale,
											  valueInputDataRmatEdgefactor,
											  valueInputDataRmatA,
											  valueInputDataRmatB,
											  valueInputDataRmatC,
											  rnd);
		val rawWeight = GraphGenerator.genRandomEdgeValue(valueInputDataRmatScale,
														  valueInputDataRmatEdgefactor,
														  rnd);
		val g = Graph.make(edgeList);
		g.setEdgeAttribute[Double]("weight", rawWeight);
		return g;
	}

	public def test_xpregel() {

		val loadedClosures = loadClosures();
		shareClosures(loadedClosures);

		val graph = makeGraphFromRmat();
    	val matrix = graph.createDistSparseMatrix[Double](
    		Config.get().distXPregel(), "weight", true, false);
		graph.del();

		val xp = this;
//		val result = xp.execute(matrix);
		val result = xp.execute_x10xpregel(matrix);

//		CSV.write(getFilePathOutput(), new NamedDistData(["pagerank" as String], [result as Any]), true);
	}

	public def test() {
		// test_runpythonclosure();
		// test_forkprocess();
		// test_broadcast_forkprocess_binary();
		//test_broadcast_call_fork_thread();

		//test_write_shmem();

		test_xpregel();
	}

/////////////////////


	/** If directed is true, the graph is considered directed graph.
	 * Default: true
	 */
	public var directed :Boolean = true;
	
	/** The name of the attribute used to give edge weights for the calculation of weighted PageRank.
	 * Default: "weight"
	 */
	public var weights :String = "weight";


	// The algorithm interface needs two execute methods.
	// 1) Accept a Graph object.
	// 2) Accept a sparse matrix.

	/** Run the calculation of PageRank.
	 * @param g The graph object. 
	 */
	public def execute(g :Graph) {
		val matrix = g.createDistSparseMatrix[Double](
				Config.get().distXPregel(), weights, directed, false);
//		Config.get().stopWatch().lap("Graph construction");
		return execute(matrix);
	}
	
	/** Run the calculation of PageRank.
	 * This method is faster than run(Graph) method when it is called several times on the same graph.
	 * @param matrix 1D row distributed adjacency matrix with edge weights.
	 */
	public def execute(matrix :DistSparseMatrix[Double]) = execute(this, matrix);
	public def execute_x10xpregel(matrix :DistSparseMatrix[Double]) = execute_x10xpregel(this, matrix);

	// Algorithm implementations are defined as static methods to avoid
	// unexpected deep copy of 'this' object.
	
	private static def execute(param :PyXPregel, matrix :DistSparseMatrix[Double]) {

		val xpgraph = PyXPregelGraph.make[Double, Double](matrix);
		xpgraph.updateInEdge();
		xpgraph.iterate[Double, Double]();
		
		// compute PageRank
//		val xpgraph = XPregelGraph.make[Double, Double](matrix);
//		xpgraph.updateInEdge();
		
//		sw.lap("UpdateInEdge");
//		@Ifdef("PROF_XP") { Config.get().dumpProfXPregel("Update In Edge:"); }
		
//		xpgraph.iterate[Double,Double]((ctx :VertexContext[Double, Double, Double, Double], messages :MemoryChunk[Double]) => {
//			val value :Double;
//			if(ctx.superstep() == 0n)
//				value = 1.0 / ctx.numberOfVertices();
//			else
//				value = (1.0-damping) / ctx.numberOfVertices() + damping * MathAppend.sum(messages);

//			ctx.aggregate(Math.abs(value - ctx.value()));
//			ctx.setValue(value);
//			ctx.sendMessageToAllNeighbors(value / ctx.numberOfOutEdges());
//		},
//		(values :MemoryChunk[Double]) => MathAppend.sum(values),
//		(superstep :Int, aggVal :Double) => {
//			if (here.id == 0) {
//				sw.lap("PageRank at superstep " + superstep + " = " + aggVal + " ");
//			}
//			return (superstep >= niter || aggVal < eps);
//		});

//		@Ifdef("PROF_XP") { Config.get().dumpProfXPregel("PageRank Main Iterate:"); }
		
//		xpgraph.once((ctx :VertexContext[Double, Double, Byte, Byte]) => {
//			ctx.output(ctx.value());
//		});
		val result = xpgraph.stealOutput[Double]();
		
//		sw.lap("Retrieve output");
//		@Ifdef("PROF_XP") { Config.get().dumpProfXPregel("PageRank Retrieve Output:"); }
//		sw.flush();
		
		return result;
	}


	private static def execute_x10xpregel(param :PyXPregel, matrix :DistSparseMatrix[Double]) {

		// define parameters as local values
		val damping :Double = 0.85;
		val eps :Double = 0.001;
		val niter :Int = 30n;
		val sw = Config.get().stopWatch();

		// compute PageRank
		val xpgraph = XPregelGraph.make[Double, Double](matrix);
		xpgraph.updateInEdge();
		
		sw.lap("UpdateInEdge");
		@Ifdef("PROF_XP") { Config.get().dumpProfXPregel("Update In Edge:"); }
		
		xpgraph.iterate[Double,Double]((ctx :VertexContext[Double, Double, Double, Double], messages :MemoryChunk[Double]) => {
			val value :Double;
			if(ctx.superstep() == 0n)
				value = 1.0 / ctx.numberOfVertices();
			else
				value = (1.0-damping) / ctx.numberOfVertices() + damping * MathAppend.sum(messages);

			ctx.aggregate(Math.abs(value - ctx.value()));
			ctx.setValue(value);
			val numOutEdges = ctx.numberOfOutEdges();
			if (numOutEdges == 0) {
				Logger.print("divide by zero");
				Logger.print((value / numOutEdges).toString());
			}			
			ctx.sendMessageToAllNeighbors(value / numOutEdges);
		},
		(values :MemoryChunk[Double]) => MathAppend.sum(values),
		(superstep :Int, aggVal :Double) => {
			if (here.id == 0) {
				sw.lap("PageRank at superstep " + superstep + " = " + aggVal + " ");
			}
			return (superstep >= niter || aggVal < eps);
		});
		@Ifdef("PROF_XP") { Config.get().dumpProfXPregel("PageRank Main Iterate:"); }

		xpgraph.once((ctx :VertexContext[Double, Double, Byte, Byte]) => {
			ctx.output(ctx.value());
		});
		val result = xpgraph.stealOutput[Double]();
		
		sw.lap("Retrieve output");
		@Ifdef("PROF_XP") { Config.get().dumpProfXPregel("PageRank Retrieve Output:"); }
		sw.flush();
		
		return result;
	}

	// The algorithm interface also needs two helper methods like this.
	
	/** Run the calculation of XPregel with default parameters.
	 * @param g The graph object. 
	 */
	public static def run(g :Graph) = new PyXPregel().execute(g);

	/** Run the calculation of XPregel with default parameters.
	 * This method is faster than run(Graph) method when it is called several times on the same graph.
	 * @param matrix 1D row distributed adjacency matrix with edge weights.
	 */
	public static def run(matrix :DistSparseMatrix[Double]) = new PyXPregel().execute(matrix);

}
