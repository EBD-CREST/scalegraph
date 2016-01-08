import x10.io.Console;
import org.scalegraph.util.MemoryChunk;
import org.scalegraph.util.SString;

import org.scalegraph.api.PyXPregel;

import org.scalegraph.python.NativePython;
import org.scalegraph.python.NativePyObject;
import org.scalegraph.python.NativePyException;

class TestPyXPregel {

	public static def main(args :Rail[String]): void {
		Console.OUT.println("Hello, world");

		val test = new TestPyXPregel();
		test.run();
	}

	public def run() {

		val pyxpregel = new PyXpregel();

		pyxpregel.test();
	}

}
