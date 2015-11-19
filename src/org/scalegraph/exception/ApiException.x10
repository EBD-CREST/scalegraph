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

import x10.io.Console;
import org.scalegraph.api.ReturnCode;
import org.scalegraph.util.Logger;

public abstract class ApiException extends CheckedThrowable {
	public val code :Int;
	public val name :String;
	protected abstract def getErrorMsg() :String;

	public def this(_code :Int, _name :String) {
		code = _code;
		name = _name;
	}

	public def printError() {
		Console.ERR.printf("ERROR: %s\n", getErrorMsg()); 
	}

	public static class PathRequiredException extends ApiException {
		protected def getErrorMsg() :String {
			return String.format("Option %s requires a path name (file or directory) on the filesystem.", [name as Any]);
		}
		public def this(name :String) = super(ERROR_PATH_REQUIRED, name);		
	}

	public static class InvalidOptionException extends ApiException {
		protected def getErrorMsg() :String {
			return String.format("Invalid option specified: %s", [name as Any]);
		}
		public def this(name :String) = super(ERROR_INVALID_OPTION, name);
	}

	public static class InvalidApiNameException extends ApiException {
		protected def getErrorMsg() :String {
			return String.format("Invalid API name specified: %s", [name as Any]);
		}
		public def this(name :String) = super(ERROR_INVALID_API_NAME, name);
	}

	public static class NoOptionValueException extends ApiException {
		protected def getErrorMsg() :String {
			return String.format("No option value specified for %s", [name as Any]);
		}
		public def this(name :String) = super(ERROR_NO_OPTION_VALUE, name);
	}

	public static class InvalidOptionValueException extends ApiException {
		protected def getErrorMsg() :String {
			return String.format("Invalid option value specified: %s", [name as Any]);
		}
		public def this(name :String) = super(ERROR_INVALID_OPTION_VALUE, name);
	}

	public static class OptionRequiredException extends ApiException {
		protected def getErrorMsg() :String {
			return String.format("Option %s should be specified", [name as Any]);
		}
		public def this(name :String) = super(ERROR_OPTION_REQUIRED, name);
	}

	public static class OptionStringFormatException extends ApiException {
		protected def getErrorMsg() :String {
			return String.format("Option %s requires format string", [name as Any]);
		}
		public def this(name :String) = super(ERROR_OPTION_STRING_FORMAT, name);
	}
}
