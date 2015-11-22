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
import x10.util.Team;
import x10.io.Console;
import x10.io.Printer;
import org.scalegraph.io.FilePath;
import org.scalegraph.io.FileMode;
import org.scalegraph.io.FileAccess;
import org.scalegraph.io.GenericFile;
import org.scalegraph.util.SString;


/*
 * Buffers log messages and flushes the messages.
 * 
 * A static ArrayList logLines keeps the buffered messages on each place.
 * StrinbBuilder buffer is used as a temprary buffer to construct stack trace message.
 */
public class Logger {
	private static val logLines = new ArrayList[LogLine]();
	private static val buffer = new StringBuilder();
	private static val linebreak = "\n";
	private static val sstrLinebreak = SString(linebreak);

/*
	private static val enablePlaceLocalLogFile = true;
	private static val enableGlobalLogFile = true;
	private static val enableGlobalLogPrinter = true;
	private static val placeLocalLogFilePath = FilePath(FilePath.FILEPATH_FS_OS, "logplace_%05ld");
	private static val globalLogFilePath = FilePath(FilePath.FILEPATH_FS_OS, "logglobal");
	private static val globalLogPrinter = Console.ERR;
	private static val placeLocalLogFile =
		new GenericFile(FilePath(placeLocalLogFilePath.fsType,
								 String.format(placeLocalLogFilePath.pathString, [here.id as Any])),
						FileMode.Append, FileAccess.Write);
	private static val globalLogFile =
		new GenericFile(globalLogFilePath, FileMode.Append, FileAccess.Write);
*/

	private static struct Config {
		public val initialized :Boolean;
		public val enablePlaceLocalLogFile :Boolean;
		public val enableGlobalLogFile :Boolean;
		public val enableGlobalLogPrinter :Boolean;
		public val placeLocalLogFilePath :FilePath;
		public val globalLogFilePath :FilePath;
		public val globalLogPrinter :Printer;
		public val placeLocalLogFile :GenericFile;
		public val globalLogFile :GenericFile;
		public def this() {
			initialized = false;
			enablePlaceLocalLogFile = false;
			enableGlobalLogFile = false;
			enableGlobalLogPrinter = false;
			placeLocalLogFilePath = FilePath(FilePath.FILEPATH_FS_OS, "");
			globalLogFilePath = FilePath(FilePath.FILEPATH_FS_OS, "");
			globalLogPrinter = Console.ERR;
			placeLocalLogFile = null;
			globalLogFile = null;
		}
		public def this(flagPlaceLocalLogFile :Boolean,
						flagGlobalLogFile :Boolean,
						flagGlobalLogPrinter :Boolean,
						localFilePath :FilePath,
						globalFilePath :FilePath) {
			initialized = true;
			enablePlaceLocalLogFile = flagPlaceLocalLogFile;
			enableGlobalLogFile = flagGlobalLogFile;
			enableGlobalLogPrinter = flagGlobalLogPrinter;
			placeLocalLogFilePath = localFilePath;
			globalLogFilePath = globalFilePath;
			globalLogPrinter = Console.ERR;
			if (enablePlaceLocalLogFile) {
				placeLocalLogFile =
					new GenericFile(FilePath(placeLocalLogFilePath.fsType,
											 String.format(placeLocalLogFilePath.pathString,
														   [here.id as Any])),
									FileMode.Append, FileAccess.Write);
			} else {
				placeLocalLogFile = null;
			}
			if (enableGlobalLogFile && here == Place.FIRST_PLACE) {
				globalLogFile =
					new GenericFile(globalLogFilePath, FileMode.Append, FileAccess.Write);
			} else {
				globalLogFile = null;
			}
		}
		public def release() {
			if (placeLocalLogFile != null) {
				placeLocalLogFile.close();
			}
			if (globalLogFile != null) {
				globalLogFile.close();
			}
		}
	}

	private static val config :Cell[Config] = new Cell[Config](Config());

	private static struct LogLine {
		public val placeId: Long;
		public val timestamp: Long;
		public val msg: String;
		public def this(s: String) {
			placeId = here.id;
			timestamp = System.nanoTime();
			msg = s;
		}
	}

	public static def init(flagPlaceLocalLogFile :Boolean,
						   flagGlobalLogFile :Boolean,
						   flagGlobalLogPrinter :Boolean,
						   localFilePath :FilePath,
						   globalFilePath :FilePath) {
		Team.WORLD.placeGroup().broadcastFlat(
			() => {
				config() = Config(
					flagPlaceLocalLogFile,
					flagGlobalLogFile,
					flagGlobalLogPrinter,
					localFilePath,
					globalFilePath);
			}
		);
	}

	public static def initialized() :Boolean {
		return config().initialized;
	}

	public static def closeAll() :void {
		if (here != Place.FIRST_PLACE) {
			return;
		}
		Team.WORLD.placeGroup().broadcastFlat(
			() => {
				if (config().initialized) {
					config().release();
					config() = new Config();
				}
			}
		);
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

	public static def recordLog(msg: String) {
		logLines.add(LogLine(msg));
	}

    public static def flush() {
		flushLocalRecords();
		GatherAndOutputRecords();
    }

	private atomic static def flushLocalRecords() {
		if (config().enablePlaceLocalLogFile) {
			for (line in logLines) {
				val timeinsec :Long = line.timestamp / 1000000000;
				val sec :Long = timeinsec % 60;
				val min :Long = (timeinsec / 60) % 60;
				val hour :Long = (timeinsec / 60 / 60) % 24;
				val sstr = SString(String.format("%02ld:%02ld:%02ld ", [hour as Any, min, sec]) +
								  line.msg);
				config().placeLocalLogFile.write(sstr.bytes());
				if (!line.msg.endsWith(linebreak)) {
					config().placeLocalLogFile.write(sstrLinebreak.bytes());
				}
			}
			config().placeLocalLogFile.flush();
		}
	}

	private atomic static def outputGatheredRecords(from: Long, logLinesReceived :ArrayList[LogLine]) {
//		x10.io.Console.ERR.println("======== Place: " + from + " ========");
		for (line in logLinesReceived) {
			val timeinsec :Long = line.timestamp / 1000000000;
			val sec :Long = timeinsec % 60;
			val min :Long = (timeinsec / 60) % 60;
			val hour :Long = (timeinsec / 60 / 60) % 24;
			val sstr = SString("[" + line.placeId + "] " +
							   String.format("%02ld:%02ld:%02ld ", [hour as Any, min, sec]) +
							   line.msg);
			if (config().enableGlobalLogFile) {
				config().globalLogFile.write(sstr.bytes());
				if (!line.msg.endsWith(linebreak)) {
					config().globalLogFile.write(sstrLinebreak.bytes());
				}
			}
			if (config().enableGlobalLogPrinter) {
				config().globalLogPrinter.print(sstr.toString());
				if (!line.msg.endsWith(linebreak)) {
					config().globalLogPrinter.print(linebreak);
				}
			}
		}
		if (config().enableGlobalLogFile) {
			config().globalLogFile.flush();
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
