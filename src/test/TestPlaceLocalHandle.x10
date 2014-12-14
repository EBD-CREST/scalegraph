/* 
 *  This file is part of the ScaleGraph project (http://scalegraph.org).
 * 
 *  This file is licensed to You under the Eclipse Public License (EPL);
 *  You may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *      http://www.opensource.org/licenses/eclipse-1.0.php
 * 
 *  (C) Copyright ScaleGraph Team 2011-2012.
 */

package test;

import x10.util.Team;
import x10.util.Timer;
import x10.compiler.Pragma;

public class TestPlaceLocalHandle {
	private static def message (str:String) : void {
		Console.OUT.println("" + Timer.milliTime() + ":osc: " + here + "(" + Runtime.workerId() + ")" + str);
		Console.OUT.flush();
	}
	private static def message (str:String, start:Long) : void {
		Console.OUT.println("Elapsed: " + (Timer.nanoTime() - start) + ":osc: " + here + "(" + Runtime.workerId() + ")" + str);
		Console.OUT.flush();
	}
	
	static class MyInt {
		public var v:Int;
		public def this() { }
		public def this(i:Int) { v = i; }
		public operator this() = v;
		public operator this()=(value:Int) { v = value; return v; }
	}
	
	static def makeTest() {
		message("MAKE TEST");
		val placeGroup = Team.WORLD.placeGroup();
		for(i in 1..10) {
			val start = Timer.nanoTime();
			val plh = PlaceLocalHandle.make[MyInt](placeGroup, ()=>new MyInt());
			message("make complete " + i, start);
			finish for(place in placeGroup) at(place) async {
				plh()() = 0n;
			}
			message("write complete " + i, start);
		}
	}
	
	static def makeFlatTest() {
		message("MAKE FLAT TEST");
		val placeGroup = Team.WORLD.placeGroup();
		for(i in 1..10) {
			val start = Timer.nanoTime();
			val plh = PlaceLocalHandle.makeFlat[MyInt](placeGroup, ()=>new MyInt());
			message("make complete " + i, start);
			placeGroup.broadcastFlat(()=>{plh()()=0n;return;});
			message("write complete " + i, start);
		}
	}
	
	static def writeTest() {
		message("WRITE TEST");
		val placeGroup = Team.WORLD.placeGroup();
		val places = Team.WORLD.places();
		for(i in 1..10) {
			val start = Timer.nanoTime();
			val plh = PlaceLocalHandle.make[MyInt](placeGroup, ()=>new MyInt());
			message("make complete " + i, start);
			//@Pragma(Pragma.FINISH_SPMD) finish for([pi] in places) at(places(pi)) async {
			//	plh()() = pi;
			//}
			@Pragma(Pragma.FINISH_SPMD){
				var cnt : Int = 0n;
				finish for(pi in places){
					val cnt2 = cnt;
					at(pi) async {
						plh()() = cnt2;
					}
					cnt++;
				}
			}
			message("write complete " + i, start);
		}
	}
	
	static def writeFlatTest() {
		message("WRITE FLAT TEST");
		val placeGroup = Team.WORLD.placeGroup();
		val places = Team.WORLD.places();
		for(i in 1..10) {
			val start = Timer.nanoTime();
			val plh = PlaceLocalHandle.makeFlat[MyInt](placeGroup, ()=>new MyInt());
			message("make complete " + i, start);
			placeGroup.broadcastFlat(()=>{
				var cnt : Int = 0n;
				for(pi in places) {
					if(here == pi) {
						plh()() = cnt; break;
					}
					cnt++;
				}
				return;
			});
			message("write complete " + i, start);
		}
	}
	
	static def writeTeamTest() {
		message("WRITE TEAM TEST");
		val placeGroup = Team.WORLD.placeGroup();
		val size = Team.WORLD.places().size;
		for(i in 1..10) {
			val start = Timer.nanoTime();
			val plh = PlaceLocalHandle.makeFlat[MyInt](placeGroup, ()=>new MyInt());
			message("make complete " + i, start);
			finish for(pi in 0..(placeGroup.size()-1)) at(placeGroup(pi)) async {
				val array = new Rail[Int](size, (i:Long)=>i as Int);
				val recv = new Rail[Int](1);
				//Team.WORLD.scatter(Team.WORLD.id(), 0, array, 0, recv, 0, 1);
				Team.WORLD.scatter(0n, array, 0, recv, 0, 1);
				plh()() = recv(0);
			};
			message("write complete " + i, start);
		}
	}
	
	static def writeTestNew() {
		message("WRITE TEST NEW");
		val placeGroup = Team.WORLD.placeGroup();
		val places = Team.WORLD.places();
		for(i in 1..10) {
			val start = Timer.nanoTime();
			val plh = PlaceLocalHandle.make[MyInt, Int](placeGroup, (i:Int) => i, (i:Int)=>new MyInt(i));
			message("make and write complete " + i, start);
		}
	}
	
	static def writeFlatTestNew() {
		message("WRITE FLAT TEST NEW");
		val placeGroup = Team.WORLD.placeGroup();
		val places = Team.WORLD.places();
		for(i in 1..10) {
			val start = Timer.nanoTime();
			val plh = PlaceLocalHandle.makeFlat[MyInt, Int](placeGroup, (i:Int) => i, (i:Int)=>new MyInt(i));
			message("make and write complete " + i, start);
		}
	}
	
	public static def main(args:Rail[String]) : void{
		message("Team.WORLD: " + Team.WORLD);
		message("members of Team(0): " + Team.WORLD.places());
		
		makeTest();
		makeFlatTest();
		writeTest();
		writeFlatTest();
		writeTeamTest();
		writeTestNew();
		writeFlatTestNew();
	}
}
