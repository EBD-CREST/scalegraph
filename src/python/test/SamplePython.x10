import x10.io.Console;

import org.scalegraph.python.NativePyObject;

class SamplePython {

	var	strtmp :String;

	public static def main(args :Rail[String]): void {
		Console.OUT.println("Hello, world");
	}

	public def test() {
		return new NativePyObject();
	}

	public def test2() {
		strtmp = new String("hogehoge");
		return strtmp;
	}

	public def testLong() :Long {
		return 12345;
	}

	public def testInt() :Int {
		return 12345N;
	}

	public def testRail(param :Int, args :Rail[String]) {
		return param;
	}

}
