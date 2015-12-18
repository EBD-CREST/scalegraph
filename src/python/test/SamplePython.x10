import x10.io.Console;

import org.scalegraph.python.NativePyObject;

class SamplePython {

	public static def main(args :Rail[String]): void {
		Console.OUT.println("Hello, world");
	}

	public def test() {
		return new NativePyObject();
	}
}
