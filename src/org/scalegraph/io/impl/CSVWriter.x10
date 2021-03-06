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

import x10.xrx.Runtime;
import x10.util.Team;
import x10.util.concurrent.Monitor;
import x10.compiler.Ifdef;

import org.scalegraph.Config;

import org.scalegraph.test.STest;
import org.scalegraph.util.SString;
import org.scalegraph.util.MemoryChunk;
import org.scalegraph.util.GrowableMemory;
import org.scalegraph.util.DistMemoryChunk;
import org.scalegraph.util.SStringBuilder;
import org.scalegraph.util.Parallel;
import org.scalegraph.util.MathAppend;
import org.scalegraph.io.NamedDistData;
import org.scalegraph.id.Type;
import org.scalegraph.io.FileWriter;
import org.scalegraph.io.FilePath;
import x10.util.ArrayList;

public class CSVWriter {
	private static type IO = org.scalegraph.id.ProfilingID.IO;
	/*hedder 1 line
	 * string with double quotation 
	 * "name1 <int>","name2 <.... namex : NamedDistData.name
	 * path :directory (make a directory  (hogenameprovider
	 * file num = place num ( each place writes files)
	 * */
	
	public static CHUNK_SIZE = 128*1024;

	private static class ParallelWriter {
		private var frontBuffer :MemoryChunk[SStringBuilder];
		private var backBuffer :MemoryChunk[SStringBuilder];
		private val fw :FileWriter;
//		private val strClousure :MemoryChunk[(sb :SStringBuilder, idx :Long) => void];
		private val strClousure :ArrayList[(sb :SStringBuilder, idx :Long) => void];
		private val monitor = new Monitor();
		private var numLauchTasks :Int = 0n;
		
		public def this(fw :FileWriter, strClousure :ArrayList/*MemoryChunk*/[(sb :SStringBuilder, idx :Long) => void]) {
			val nthreads = Runtime.NTHREADS;
			this.frontBuffer = MemoryChunk.make[SStringBuilder](nthreads, (i :Long) => new SStringBuilder());
			this.backBuffer = MemoryChunk.make[SStringBuilder](nthreads, (i :Long) => new SStringBuilder());
			for( i in 0n..(nthreads-1n)){
				frontBuffer(i).add("");
				backBuffer(i).add("");
			}
			this.fw = fw;
			this.strClousure = strClousure;
		}
		
		private def cycleBuffers(numTasksToLaunch :Int) {
			// wait for completion of sub tasks
			monitor.lock();
			while(numLauchTasks > 0) {
				monitor.await();
			}
			numLauchTasks = numTasksToLaunch;
			monitor.unlock();
			val tmp = backBuffer;
			backBuffer = frontBuffer;
			frontBuffer = tmp;
		}
		
		private def notifySubtaskCompletion() {
			monitor.lock();
			if(--numLauchTasks == 0n)
				monitor.release();
			else
				monitor.unlock();
		}
		
		private def makeString(range :LongRange) {
			Parallel.iter(range, (tid :Long, r :LongRange) => {
				@Ifdef("PROF_IO") val mtimer = Config.get().profIO().timer(IO.MAIN_TH_FRAME as Int, tid as Int);
				@Ifdef("PROF_IO") { mtimer.start(); }
				val buf = backBuffer(tid);
				val numColumns = strClousure.size();
				if(numColumns == 0) return ;
				for(i in r) {
					for(c in 0..(numColumns-2)) {
						strClousure(c)(buf, i);
						buf.add(',');
					}
					strClousure(numColumns-1)(buf, i);
					buf.add('\n');
				}
				@Ifdef("PROF_IO") { mtimer.lap(IO.MAIN_TH_MAKE_STRING as Int); }
			});
		}
		
		private def subtask() {
			try {
				@Ifdef("PROF_IO") val mtimer_ = Config.get().profIO().timer(IO.SUB_FRAME as Int, 0n);
				@Ifdef("PROF_IO") { mtimer_.start(); }
				for(tid in frontBuffer.range()) {
					val bytes = frontBuffer(tid).result().bytes();
					//	STest.println(here.id + " => Write " + bytes.size() + " bytes");
					fw.write(bytes);
					frontBuffer(tid).clear();
				}
				@Ifdef("PROF_IO") { mtimer_.lap(IO.SUB_WRITE as Int); }
			
				notifySubtaskCompletion();
			} catch (e :CheckedThrowable) {e.printStackTrace(); }
		}
		
		public def write(numLines :Long) {
			@Ifdef("PROF_IO") val mtimer = Config.get().profIO().timer(IO.MAIN_FRAME as Int, 0n);
			@Ifdef("PROF_IO") { mtimer.start(); }
			val nthreads = Runtime.NTHREADS;
			finish for(var start :Long = 0; start < numLines; start += CHUNK_SIZE * nthreads) {
				val end = MathAppend.min(start + CHUNK_SIZE * nthreads, numLines) - 1;
				makeString(start..end);
				@Ifdef("PROF_IO") { mtimer.lap(IO.MAIN_MAKE_STRING as Int); }
				cycleBuffers(1n);
				@Ifdef("PROF_IO") { mtimer.lap(IO.MAIN_WRITE_WAIT as Int); }
				async subtask();
			}
			@Ifdef("PROF_IO") { mtimer.lap(IO.MAIN_LAST_WRITE_WAIT as Int); }
		}
	}

	/* header
	 * "Name1 <Int>" ,"Name2...
	 */

	public static def write(team :Team, path :SString, data :NamedDistData, putIdFlag :Boolean) {
		val filePath :FilePath = new FilePath(FilePath.FILEPATH_FS_OS, path.toString());
		write(team, filePath, data, putIdFlag);
	}

	//data: all data
	public static def write(team :Team, filePath :FilePath, data :NamedDistData, putIdFlag :Boolean) {
		@Ifdef("PROF_IO") val mtimer_ = Config.get().profIO().timer(IO.MAIN_FRAME as Int, 0n);
		@Ifdef("PROF_IO") { mtimer_.start(); }
		val fman = FileNameProvider.createForWrite(filePath, true);
		// create directory if it is not exists.
		fman.mkdir();

		val typeId = data.typeId();
		val colNum = typeId.size;
		val atts = new Rail[CSVAttributeHandler](colNum,
				(i :Long) => CSVAttributeHandler.create(typeId(i), false));
		val dmc = data.data();
		@Ifdef("PROF_IO") { mtimer_.lap(IO.MAIN_PREPARE as Int); }
		
		team.placeGroup().broadcastFlat(() => {
			try {
				@Ifdef("PROF_IO") val mtimer = Config.get().profIO().timer(IO.MAIN_FRAME as Int, 0n);
				@Ifdef("PROF_IO") { mtimer.start(); }
				val teamRole = team.role()(0);
				val teamSize = team.size();
			
				//val makeStringClosures = new GrowableMemory[(sb :SStringBuilder, idx :Long) => void]();
				val makeStringClosures = new ArrayList[(sb :SStringBuilder, idx :Long) => void]();

				if(putIdFlag){
					makeStringClosures.add((sb :SStringBuilder, idx :Long) => {
						val id = idx * teamSize + teamRole;
						sb.add(id);
					});
				}
				for (i in 0..(colNum-1)) {
					makeStringClosures.add(atts(i as Int).makeStringClosure(dmc(i)));
				}
			
				val fw = fman.openWrite(teamRole);
			
				if (teamRole == 0n){
					// write header
					val ssb = new SStringBuilder();
					if(putIdFlag){
						ssb.add("ID<Long>,");
					}
					for (i in 0..(colNum-1)) {
						if( data.typeId()(i) == Type.String ){
							ssb.add("\"" + data.name()(i) + "<" + Type.typeNameStr(data.typeId()(i) ) + ">\"" + ( i != colNum-1 ?  "," : "\n"));
						}else{
							ssb.add("" + data.name()(i) + "<" + Type.typeNameStr(data.typeId()(i) ) + ">" + ( i != colNum-1 ?  "," : "\n"));
						}
					}
					fw.write(ssb.result().bytes());
				}
			
				//val writer = new ParallelWriter(fw, makeStringClosures.raw());
				//val writer = new ParallelWriter(fw, MemoryChunk.make[(sb :SStringBuilder, idx :Long) => void](makeStringClosures.toIndexedMemoryChunk(), 0, makeStringClosures.size()) );
				val writer = new ParallelWriter(fw, makeStringClosures);
				@Ifdef("PROF_IO") { mtimer.lap(IO.MAIN_PREPARE as Int); }
				writer.write(atts(0n).localSizeOf(dmc(0)));
				fw.close();
				@Ifdef("PROF_IO") { mtimer.lap(IO.MAIN_CLOSE as Int); }
			} catch (e :CheckedThrowable) {e.printStackTrace(); }
		});
	}

}	

