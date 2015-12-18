import x10.io.Console;

import org.scalegraph.python.NativePythonIntegrate;
import org.scalegraph.python.NativePyObject;

class TestPython {

	private transient var pythonIntegrate :NativePythonIntegrate;

	public static def main(args :Rail[String]): void {
		Console.OUT.println("Hello, world");

		new TestPython().run();
	}

	public def this() {
		pythonIntegrate = new NativePythonIntegrate();
	}

	public def run() {
		val po = pythonIntegrate.importModule("multiply");
		pythonIntegrate.calltest(po);
	}
}
