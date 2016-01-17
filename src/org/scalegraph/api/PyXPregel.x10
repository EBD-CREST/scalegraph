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

import x10.xrx.Runtime;
import x10.util.ArrayList;
import x10.util.Team;
import org.scalegraph.Config;
import org.scalegraph.graph.Graph;
import org.scalegraph.io.FilePath;
import org.scalegraph.io.FileAccess;
import org.scalegraph.io.FileMode;
import org.scalegraph.io.GenericFile;
import org.scalegraph.util.Logger;
import org.scalegraph.util.MemoryChunk;
import org.scalegraph.util.SString;
import org.scalegraph.util.Team2;
import org.scalegraph.python.NativePython;
import org.scalegraph.python.NativePyObject;
import org.scalegraph.python.NativePyException;

final public class PyXPregel {

	private static val adapter = new NativePyXPregelAdapter();
	private static val python = new NativePython();
	private static val closures :Cell[MemoryChunk[Byte]] = new Cell[MemoryChunk[Byte]](MemoryChunk.getNull[Byte]());

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

		finish for(i in 0..(nthreads - 1)) {
			async pipe(i) = test_fork_on_thread(i);
		}

		finish for(i in 0..(nthreads - 1)) {
//			async result(i) = test_read_on_thread(pipe(i), i);
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
			test_write_shmem_on_place();
			try {
				val pipe = adapter.fork(here.id, 0, here.id, 0..1, (_tid :Long, range :LongRange) => {});
				test_read_on_thread(pipe, 0);
			} catch (exception :CheckedThrowable) {
				exception.printStackTrace();
				return;
			}
		});
	}

	public def test() {
		// test_runpythonclosure();
		// test_forkprocess();
		// test_broadcast_forkprocess_binary();
		// test_broadcast_call_fork_thread();
		test_write_shmem();
	}

}
