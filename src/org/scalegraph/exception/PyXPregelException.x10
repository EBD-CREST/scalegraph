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

package org.scalegraph.exception;

public class PyXPregelException extends CheckedThrowable {
	public val code :Int;
	public val name :String;
//	public abstract def getErrorMsg() :String;

	public def this(_name: String) {
		code = 0N;
		name = _name;
	}

	public def this(_code :Int, _name :String) {
		code = _code;
		name = _name;
	}

	public def printError() {
		Console.ERR.printf("ERROR: %s\n", getErrorMsg()); 
	}

	public def getErrorMsg() :String {
		return String.format("XPregel Python Interface: %s", [name as Any]);
	}
}
