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

import org.scalegraph.util.Logger;

public class LoggerTest {
	public static def bar() {
		try {
			foo();
		} catch (e :CheckedThrowable) {
			Logger.printStacktrace(e);
		}
	}
	public static def foo() throws CheckedThrowable {
		if (here.id == 3) {
			throw new CheckedThrowable();
		}
//		assert(here.id != 2);
		Logger.println("abcdefg HIJKLMN " + here.id.toString());
	}

	public static def main(Rail[String]) {
		finish for (p in Place.places()) {
			at (p) async bar();
		}
	}

}
