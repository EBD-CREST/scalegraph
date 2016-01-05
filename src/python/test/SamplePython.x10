import x10.io.Console;

import org.scalegraph.util.MemoryChunk;

//import org.scalegraph.python.NativePyObject;
import SampleStruct;

class SamplePython {

	var	strtmp :String;
	var structValue :SampleStruct;
	var structValue0 :SampleStruct0;

	public static def main(args :Rail[String]): void {
		Console.OUT.println("Hello, world");
	}

	public def test() {
//		return new NativePyObject();
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

	public def testRail(param :Long, args :Rail[Long]) {
		var data :Long = 0;
		for (val i in args.range()) {
			data = data + args(i);
		}
		return param + data;
	}

	public def testRail2(param :Long) :Rail[Long] {
		val ret :Rail[Long] = new Rail[Long](param);

		for (var i :Long = 0; i < param; i++) {
			ret(i) = i;
		}

		return ret;
	}

	public def testMemoryChunk(param: MemoryChunk[Byte]) {
		return param.size();
	}

	public def testMemoryChunk(param: Rail[Byte]) {
		val mc = MemoryChunk.make[Byte](param, 0);
		return mc;
	}

	public def getMemoryChunk(size: Long) {
		val mc = MemoryChunk.make[Byte](size);
		return mc;
	}

}
