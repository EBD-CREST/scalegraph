import x10.io.Console;

import org.scalegraph.python.NativePython;
import org.scalegraph.python.NativePyObject;

class TestPython {

	private transient var python :NativePython;

	public static def main(args :Rail[String]): void {
		Console.OUT.println("Hello, world");

		new TestPython().run();
	}

	public def this() {
		python = new NativePython();
	}

	public def run() {
		val po = python.importModule("multiply");
		python.calltest(po);
	}

}
