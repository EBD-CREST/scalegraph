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

import x10.util.StringBuilder;
import x10.io.Console;

public class Logger {
	private static val buffer = new StringBuilder();
	private static val linebreak = "\n";

    private atomic static def printStacktrace(e :CheckedThrowable, nested :Int) {
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
    			printStacktrace(excs(i), nested + 1n);
    		}
    	}
    }
    
    public static def flush() {
    	val out :String;
		val pid :Int;
    	atomic {
	    	out = buffer.toString();
	    	buffer.clear();
    	}
		pid = here.id as Int;
    	if(here != Place.FIRST_PLACE) {
    		finish at(Place.FIRST_PLACE) {
				x10.io.Console.ERR.println("======== Place: " + pid + " ========");
    			x10.io.Console.ERR.print(out);
    		}
    	}
    	else {
			x10.io.Console.ERR.println("======== Place: " + pid + " ========");
    		x10.io.Console.ERR.print(out);
    	}
    }
    
    public static def printStacktrace(e :CheckedThrowable) {
    	printStacktrace(e, 0n);
		flush();
    }
    
    public static def print(obj :Any) {
    	bufferedPrint(obj);
    	flush();
    }
    
    public static def println(obj :Any) {
    	bufferedPrintln(obj);
    	flush();
    }
    
    public atomic static def bufferedPrint(obj :Any) {
    	buffer.add(obj.toString());
    }
    
    public atomic static def bufferedPrintln(obj :Any) {
    	buffer.add(obj.toString());
    	buffer.add(linebreak);
    }

}
