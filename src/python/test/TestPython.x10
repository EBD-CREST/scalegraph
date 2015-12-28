import x10.io.Console;

import org.scalegraph.python.NativePython;
import org.scalegraph.python.NativePyObject;
import org.scalegraph.python.NativePyException;

class TestPython {

	public static def main(args :Rail[String]): void {
		Console.OUT.println("Hello, world");

		val test = new TestPython();
		test.run();
	}

	public def this() {
	}

	public def run() {
		test_importFile();
		test_runSimpleString();
		test_runString();
		test_dictLong();
		test_dictString();
		test_dictString();
		test_dictString();
		test_dictString();
		test_dictString();
		test_dictString();
		test_dictString();
		test_dictString();
		test_dictString();
		test_dictString();

		test_listNew();
		test_listNew();
		test_listNew();
		test_listNew();
		test_listNew();
		test_listNew();
		test_listNew();
		test_listNew();
		test_listNew();
		test_listNew();

		test_listFromRail();
		test_listFromRail();
		test_listFromRail();
		test_listFromRail();
		test_listAsRail();
		test_listAsRail();
		test_listAsRail();
		test_listAsRail();

	}

	public def test_importFile() {
		val python = new NativePython();
		try {
			val po = python.importImport("multiply");
			python.calltest(po);
		} catch (exception :NativePyException) {
			exception.extractExcInfo();
			Console.OUT.println("catched exception");
			Console.OUT.println(exception.strValue);
			Console.OUT.println(exception.strTraceback);
			exception.DECREF();
		}
		python.finalize();
	}

	public def test_runSimpleString() {
		val python = new NativePython();
		python.runSimpleString("print('runSimpleString ok')");
		python.finalize();
		return true;
	}

	public def test_runString() {
		val python = new NativePython();
		try {
			val main = python.importAddModule("__main__");
			val globals = python.moduleGetDict(main);
			val locals = python.dictNew();
			python.runString("print('runString ok')", globals, locals);
		} catch (exception :NativePyException) {
			exception.extractExcInfo();
			Console.OUT.println("catched exception");
			Console.OUT.println(exception.strValue);
			Console.OUT.println(exception.strTraceback);
			exception.DECREF();
		}
		python.finalize();
		return true;
	}

	public def test_dictLong() {
		val python = new NativePython();
		try {
			val main = python.importAddModule("__main__");
			val globals = python.moduleGetDict(main);
			val locals = python.dictNew();
			python.dictSetItemString(locals, "multiplicand", python.longFromLong(123));
			python.dictSetItemString(locals, "multiplier", python.longFromLong(456));
			python.runString("result = multiplicand * multiplier", globals, locals);
			val result = python.longAsLong(python.dictGetItemString(locals, "result"));
			Console.OUT.println("result = " + result);
		} catch (exception :NativePyException) {
			exception.extractExcInfo();
			Console.OUT.println("catched exception");
			Console.OUT.println(exception.strValue);
			Console.OUT.println(exception.strTraceback);
			exception.DECREF();
		}
		python.finalize();
		return true;
	}

	public def test_dictString() {
		val python = new NativePython();
		try {
			val main = python.importAddModule("__main__");
			val globals = python.moduleGetDict(main);
			val locals = python.dictNew();
			python.dictSetItemString(locals, "strleft", python.unicodeFromString("123"));
			python.dictSetItemString(locals, "strright", python.unicodeFromString("456"));
			python.runString("result = strleft + strright", globals, locals);
			val result = python.unicodeAsASCIIString(python.dictGetItemString(locals, "result"));
			Console.OUT.println("result = " + result);
		} catch (exception :NativePyException) {
			exception.extractExcInfo();
			Console.OUT.println("catched exception");
			Console.OUT.println(exception.strValue);
			Console.OUT.println(exception.strTraceback);
			exception.DECREF();
		}
		python.finalize();
		return true;
	}

	public def test_listNew() {
		val python = new NativePython();
		try {
			val main = python.importAddModule("__main__");
			val globals = python.moduleGetDict(main);
			val locals = python.dictNew();
			val testlist = python.listNew(0);
			python.dictSetItemString(locals, "testlist", testlist);
			python.runString("result = str(testlist + [5, 4, 3, 2, 1])", globals, locals);
			val result = python.unicodeAsASCIIString(python.dictGetItemString(locals, "result"));
			Console.OUT.println("result = " + result);
		} catch (exception :NativePyException) {
			exception.extractExcInfo();
			Console.OUT.println("catched exception");
			Console.OUT.println(exception.strValue);
			Console.OUT.println(exception.strTraceback);
			exception.DECREF();
		}
		python.finalize();
		return true;
	}

	public def test_listFromRail() {
		val python = new NativePython();
		try {
			val main = python.importAddModule("__main__");
			val globals = python.moduleGetDict(main);
			val locals = python.dictNew();
			val testrail = new Rail[NativePyObject](3);
			testrail(0) = python.longFromLong(111);
			testrail(1) = python.longFromLong(222);
			testrail(2) = python.longFromLong(333);
			val testlist = python.listFromRail(testrail);
			python.dictSetItemString(locals, "testlist", testlist);
			python.runString("result = str(testlist + [5, 4, 3, 2, 1])", globals, locals);
			val result = python.unicodeAsASCIIString(python.dictGetItemString(locals, "result"));
			Console.OUT.println("result = " + result);
		} catch (exception :NativePyException) {
			exception.extractExcInfo();
			Console.OUT.println("catched exception");
			Console.OUT.println(exception.strValue);
			Console.OUT.println(exception.strTraceback);
			exception.DECREF();
		}
		python.finalize();
		return true;
	}

	public def test_listAsRail() {
		val python = new NativePython();
		try {
			val main = python.importAddModule("__main__");
			val globals = python.moduleGetDict(main);
			val locals = python.dictNew();
			python.runString("result = ['aaa', 'bbb', 'ccc']", globals, locals);
			val result = python.listAsRail(python.dictGetItemString(locals, "result"));
			for (i in result.range()) {
				Console.OUT.println("result(i) = " + python.unicodeAsASCIIString(result(i)));
			}
		} catch (exception :NativePyException) {
			exception.extractExcInfo();
			Console.OUT.println("catched exception");
			Console.OUT.println(exception.strValue);
			Console.OUT.println(exception.strTraceback);
			exception.DECREF();
		}
		python.finalize();
		return true;
	}

}
