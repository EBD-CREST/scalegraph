import x10.io.Console;

import org.scalegraph.python.NativePython;
import org.scalegraph.python.NativePyObject;
import org.scalegraph.python.NativePyException;

class TestPython {

	public static def main(args :Rail[String]): void {
		Console.OUT.println("Hello, world");

		val test = new TestPython();
		test.run();
		test.test_runSimpleString();
		test.test_runString();
	}

	public def this() {
	}

	public def run() {
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

}
