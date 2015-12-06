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

import x10.io.Printer;


/* Wrappter class to switch x10.io.Printer and org.scalegraph.util.Logger
 *
 */
public class LogPrinter {

	var printer :Printer;

	public def this(_printer :Printer) {
		printer = _printer;
	}

	public def println(obj :Any) {
		Logger.print(obj);
		// printer.println(obj);
	}
}
