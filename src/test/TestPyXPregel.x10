import x10.io.Console;
import org.scalegraph.util.MemoryChunk;
import org.scalegraph.util.SString;

import org.scalegraph.api.PyXPregel;

import org.scalegraph.python.NativePython;
import org.scalegraph.python.NativePyObject;
import org.scalegraph.python.NativePyException;
import org.scalegraph.util.Logger;
import org.scalegraph.io.FilePath;


class TestPyXPregel {

	public static def main(args :Rail[String]): void {
		Console.OUT.println("Hello, world");

		Logger.init(true,
					false,
					true,
					new FilePath(FilePath.FILEPATH_FS_OS, "test_%05d.log"),
					new FilePath(FilePath.FILEPATH_FS_OS, "test.log"));

		val test = new TestPyXPregel();
		test.run();
	}

	public def run() {

		val pyxpregel = new PyXPregel();

//		pyxpregel.test_memoryViewFromMemoryChunkDouble();
		pyxpregel.test();

		Console.OUT.flush();
	}

}
