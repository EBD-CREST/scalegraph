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

public class ReturnCode {
	public static val SUCCESS							= 0n;

	public static val ERROR_PATH_REQUIRED				= 30001n;
	public static val ERROR_INVALID_API_NAME			= 30002n;
	public static val ERROR_NO_OPTION_VALUE				= 30003n;
	public static val ERROR_INVALID_OPTION_VALUE		= 30004n;
	public static val ERROR_OPTION_REQUIRED				= 30005n;
	public static val ERROR_OPTION_STRING_FORMAT		= 30006n;

	public static val ERROR_INTERNAL					= 39999n;
}
