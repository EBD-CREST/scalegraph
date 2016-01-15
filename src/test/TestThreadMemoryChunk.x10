import x10.xrx.Runtime;
import x10.io.Console;
import x10.util.Team;
import x10.util.ArrayList;

import org.scalegraph.util.MemoryChunk;

public final class TestThreadMemoryChunk {

	public static def main(args :Rail[String]): void {
		val test = new TestThreadMemoryChunk();
		test.run();
	}

	public def run() {

		Team.WORLD.placeGroup().broadcastFlat(() => {
			run_on_place();
		});

	}

	public def run_on_place() {
		Console.OUT.println("[" + here.id + "] run");

		val nthreads = Runtime.NTHREADS;
		finish for (i in 0..(nthreads - 1)) {
			async run_on_thread(i);
		}
	}

	public def run_on_thread(tid :Long) {
		Console.OUT.println("[" + here.id + ":" + tid + "] run");

		val ba = new ArrayList[MemoryChunk[Byte]]();

		for (i in 0..9999) {
			val mc = MemoryChunk.make[Byte](16);
			ba.add(mc);
		}

		for (b in ba) {
			b.del();
		}

	}

}
