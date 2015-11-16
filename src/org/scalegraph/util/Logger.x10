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

package org.scalegraph.util;

import x10.util.ArrayList;
import x10.util.StringBuilder;
import x10.io.Console;

/*
 * Buffers log messages and flushes the messages.
 * 
 * A static ArrayList logLines keeps the buffered messages on each place.
 * 
 */
public class Logger {
	private static val buffer = new StringBuilder();
	private static val linebreak = "\n";

	private static val logLines = new ArrayList[LogLine]();

	static private struct LogLine {
		public val placeId: Long;
		public val timestamp: Long;
		public val msg: String;
		public def this(s: String) {
			placeId = here.id;
			timestamp = System.nanoTime();
			msg = s;
		}
	}

    public static def printStackTrace(e :CheckedThrowable) {
		atomic {
    		printStackTrace(e, 0n);
			recordLog(buffer.toString());
			buffer.clear();
		}
		flush();
    }
    
    private static def printStackTrace(e :CheckedThrowable, nested :Int) {
    	var nested_prefix :String = "";
    	for(n in 0..(nested-1)) nested_prefix += "| ";

    	buffer.add(nested_prefix);
    	buffer.add(e.toString());
    	buffer.add(linebreak);
    	
    	val stackTrace = e.getStackTrace();
    	for (i in stackTrace.range()) {
    		buffer.add(nested_prefix);
    		buffer.add("        at ");
    		buffer.add(stackTrace(i));
    		buffer.add(linebreak);
    	}
    	
    	if(e instanceof MultipleExceptions) {
    		val me = e as MultipleExceptions;
    		val excs = me.exceptions();
    		buffer.add(nested_prefix);
    		buffer.add("Caused by ");
    		buffer.add(linebreak);
    		for(i in excs.range()) {
    			printStackTrace(excs(i), nested + 1n);
    		}
    	}
    }

    public static def print(obj :Any) {
    	recordLog(obj.toString());
    	flush();
    }
    
    public static def bufferedPrint(obj :Any) {
    	recordLog(obj.toString());
    }

	private static def recordLog(msg: String) {
		logLines.add(LogLine(msg));
	}

    public static def flush() {
		if (here == Place.FIRST_PLACE) {
			flushLocalRecords();
		}
		GatherAndOutputRecords();
    }

	private atomic static def flushLocalRecords() {
		for (line in logLines) {
			val timeinsec :Long = line.timestamp / 1000000000;
			val sec :Long = timeinsec % 60;
			val min :Long = (timeinsec / 60) % 60;
			val hour :Long = (timeinsec / 60 / 60) % 24;
			Console.ERR.print(String.format("%02ld:%02ld:%02ld ", [hour as Any, min, sec]) +
							  line.msg);
			if (!line.msg.endsWith(linebreak)) {
				Console.ERR.print(linebreak);
			}
		}
	}

	private atomic static def outputGatheredRecords(from: Long, logLinesReceived :ArrayList[LogLine]) {
		x10.io.Console.ERR.println("======== Place: " + from + " ========");
		for (line in logLinesReceived) {
			val timeinsec :Long = line.timestamp / 1000000000;
			val sec :Long = timeinsec % 60;
			val min :Long = (timeinsec / 60) % 60;
			val hour :Long = (timeinsec / 60 / 60) % 24;
			Console.ERR.print("[" + line.placeId + "] " +
							  String.format("%02ld:%02ld:%02ld ", [hour as Any, min, sec]) +
							  line.msg);
			if (!line.msg.endsWith(linebreak)) {
				Console.ERR.print(linebreak);
			}
		}
	}

	private static def GatherAndOutputRecords() {
		val _logLines :ArrayList[LogLine];
		val _placeId :Long;
		atomic {
			_logLines = logLines.clone();
			_placeId = here.id;
			logLines.clear();
		}
		if (here != Place.FIRST_PLACE) {
			finish at (Place.FIRST_PLACE) {
				outputGatheredRecords(_placeId, _logLines);
			};
		} else {
			outputGatheredRecords(_placeId, _logLines);
		}
	}

}
