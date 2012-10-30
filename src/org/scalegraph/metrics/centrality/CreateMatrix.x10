package org.scalegraph.metrics.centrality;

import x10.array.Array;
import x10.util.ArrayBuilder;
import x10.util.HashSet;
import x10.util.HashMap;
import x10.util.Timer;
import x10.util.ArrayList;
import x10.util.concurrent.AtomicDouble;
import x10.array.DistArray;
import x10.util.Pair;
import org.scalegraph.communities.LongToIntMap;
import org.scalegraph.graph.PlainGraph;
import org.scalegraph.communities.LongToIntMap;
import org.scalegraph.util.VertexInfo;

struct MatrixElement1 {
	public val x:Int;
	public val y:Long;
	public def this(x:Int, y:Long) {
		this.x = x;
		this.y = y;
	}
};

struct MatrixElement2 {
	public val x:Int;
	public val y:Int;
	public val value:Double;
	public def this(x:Int, y:Int, value:Double) {
		this.x = x;
		this.y = y;
		this.value = value;
	}
};

struct Elem {
	public val first:Int;
	public val second:Double;
	public def this(first:Int, second:Double) {
		this.first = first;
		this.second = second;
	}
};

struct Val {
	public val id:Long;
	public val value:Double;
	public def this(id:Long, value:Double) {
		this.id = id;
		this.value = value;
	}
};

public class CreateMatrix {
	private val nVertex:Int;
	private val vertexList:DistArray[Long];
	private val graph:PlainGraph;
	private val vertexInfo:VertexInfo;
	private val nNodePerPlace:Int;
	private val rem:Int;
	public var binLink:PlaceLocalHandle[Array[ArrayList[Element]]];
	private var offset:PlaceLocalHandle[Array[Int]];
	public var danglingList:PlaceLocalHandle[Array[Int]];
	
	private def getOffset() {
		val r = nVertex % Place.MAX_PLACES;
		val offset = new Array[Int](Place.MAX_PLACES + 1);
		for (i in 1..(Place.MAX_PLACES)) {
			offset(i) = offset(i - 1);
			if (i - 1 < r) {
				offset(i) = offset(i) + nVertex / Place.MAX_PLACES + 1;
			} else {
				offset(i) = offset(i) + nVertex / Place.MAX_PLACES;
			}
		}
		this.offset = PlaceLocalHandle.make[Array[Int]](
				Dist.makeUnique(),
				()=>{
					val arr = new Array[Int](Place.MAX_PLACES + 1);
					Array.copy(offset, arr);
					arr
				});
	}

	private def getPlace(x:Int) {
		if (x < (nNodePerPlace + 1) * rem) {
			return x / (nNodePerPlace + 1);
		}
		return (x - (nNodePerPlace + 1) * rem) / nNodePerPlace + rem;
	}

	private def getIdx(x:Int) {
		if (x < (nNodePerPlace + 1) * rem) {
			return x % (nNodePerPlace + 1);
		}
		return (x - (nNodePerPlace + 1) * rem) % nNodePerPlace;
	}

	
	private def print(o:Any) {
		Console.OUT.println(o);
		Console.OUT.flush();
	}
	
	public def this(graph:PlainGraph) {
		val funStart = Timer.milliTime();
		this.graph = graph;
		this.nVertex = graph.getVertexCount() as Int;
		this.vertexList = graph.getVertexList();
		{
			val start = Timer.milliTime();
			this.vertexInfo = VertexInfo.make(graph);
			Console.OUT.printf("vertex info = %f\n", (Timer.milliTime() - start) / 1000.0);
		}
		this.nNodePerPlace = nVertex / Place.MAX_PLACES;
		this.rem = nVertex % Place.MAX_PLACES;
		Console.OUT.printf("this = %f\n", (Timer.milliTime() - funStart) / 1000.0);
	}
	
	public def createMatrix() {
		
		val funStart = Timer.milliTime();

		print("createMatrix start");

		val start1 = Timer.milliTime();

		// 1. move all node Id to local place
		val dstBuf = PlaceLocalHandle.make[Array[Array[Val]]](Dist.makeUnique(),
					()=>(new Array[Array[Val]](Place.MAX_PLACES)));
		val danglingIds = PlaceLocalHandle.make[Array[Array[Long]]](
				Dist.makeUnique(),
				()=>(new Array[Array[Long]](Place.MAX_PLACES)));

		finish for (p in Place.places()) async {
			val reg = (vertexList.dist | p).region;
			//print(p);
			at (p) {
				val nodeIdList =
					new Array[ArrayBuilder[Val]](Place.MAX_PLACES,
							(Int)=>(new ArrayBuilder[Val]()));
				val danglingIdList =
					new Array[ArrayBuilder[Long]](Place.MAX_PLACES,
							(Int)=>(new ArrayBuilder[Long]()));

				//print("B");
				for (i in reg) {
					val nodeId = vertexList(i);
					//print("C");
					if (nodeId != -1l) {
						//print("D");
						val pId = vertexInfo.getPlaceID(nodeId);
						val neighbours = graph.getOutNeighbours(nodeId);
						var value:Double;
						if (neighbours == null || neighbours.size == 0) {
							danglingIdList(pId).add(nodeId);
							value = 1.0 / nVertex;
						} else {
							value = 1.0 / neighbours.size;
						}
						//print("E");
						nodeIdList(pId).add(Val(nodeId, value));
						//print("F");
					}
				}

				finish for (p1 in Place.places()) async {
					//print(p1);
					//print("G");
					val nNodes = nodeIdList(p1.id).length();
					val recvBuf = at(p1) {
						dstBuf()(p.id) = new Array[Val](nNodes);
						new RemoteArray[Val](dstBuf()(p.id) as Array[Val](1){self!=null})
					};
					finish {
						Array.asyncCopy[Val](nodeIdList(p1.id).result(), 0,
								recvBuf, 0, nNodes);
					}
					//print("H");
				}

				finish for (p1 in Place.places()) async {
					val nNodes = danglingIdList(p1.id).length();
					val recvBuf = at(p1) {
						danglingIds()(p.id) = new Array[Long](nNodes);
						new RemoteArray[Long](danglingIds()(p.id) as Array[Long](1){self!=null})
					};
					finish {
						Array.asyncCopy[Long](danglingIdList(p1.id).result(), 0,
								recvBuf, 0, nNodes);
					}
				}
			}
		}
		Console.OUT.printf("1 end. time = %f\n", (Timer.milliTime() - start1) / 1000.0);

		val danglingIdxList = PlaceLocalHandle.make[Array[Array[Int]]](
				Dist.makeUnique(),
				()=>(new Array[Array[Int]](Place.MAX_PLACES)));

		finish for (p in Place.places()) async at (p) {
			val danglingIdxListHere = new ArrayBuilder[Int]();
			for (i in danglingIds()) {
				for (j in danglingIds()(i)) {
					val nodeId = danglingIds()(i)(j);
					val nodeIdx = vertexInfo.getIDXFromHere(nodeId)();
					danglingIdxListHere.add(nodeIdx);
				}
			}
			for (p1 in Place.places()) {
				val nNodes = danglingIdxListHere.length();
				val recvBuf = at (p1) {
					danglingIdxList()(p.id) = new Array[Int](nNodes);
					new RemoteArray[Int](danglingIdxList()(p.id) as Array[Int](1){self!=null})
				};
				finish {
					Array.asyncCopy[Int](danglingIdxListHere.result(), 0,
							recvBuf, 0, nNodes);
				}
			}
		}

		val init = ()=>{
			val idxList = new ArrayBuilder[Int]();
			for (i in danglingIdxList()) {
				for (j in danglingIdxList()(i)) {
					idxList.add(danglingIdxList()(i)(j));
				}
			}
			idxList.result()
		};

		danglingList = PlaceLocalHandle.make[Array[Int]](Dist.makeUnique(), init);

		// 2. move all in neighbours of the node to that place
		//print("I");
		val start2 = Timer.milliTime();
		val recvBuf = PlaceLocalHandle.make[Array[Array[MatrixElement1]]]
		(Dist.makeUnique(), ()=>(new Array[Array[MatrixElement1]](Place.MAX_PLACES)));
		val idToValueMap = PlaceLocalHandle.make[HashMap[Int, Double]](
				Dist.makeUnique(), ()=>(new HashMap[Int, Double]()));
		//print("J");
		finish for (p in Place.places()) async at (p) {
			//print(p);
			val nodeIdxList = new Array[ArrayBuilder[MatrixElement1]](
					Place.MAX_PLACES,
					(Int)=>(new ArrayBuilder[MatrixElement1]()));
			//print("K");
			for (i in dstBuf()) {
				for (j in dstBuf()(i)) {
					//print("L");
					val nodeId = dstBuf()(i)(j).id;
					val value = dstBuf()(i)(j).value;
					//assert(here.id == vertexInfo.getPlace(nodeId).id);
					//print("M");
					val nodeIdx = vertexInfo.getIDXFromHere(nodeId)();
					idToValueMap().put(nodeIdx, value);
					//print("N");
					val neighbours = graph.getInNeighbours(nodeId);
					//print("O");
					if (neighbours != null && neighbours.size != 0) {
						//print("P");
						for (nIdx in neighbours) {
							//print("Q");
							val nbId = neighbours(nIdx);
							//assert(nbOutNeighbours != null);
							nodeIdxList(vertexInfo.getPlaceID(nbId)).add(
									MatrixElement1(nodeIdx, nbId));
							//print("R");
						}
					}
				}
			}

			// remote array copy
			finish for (pl in Place.places()) async {
				//print(p);
				val nNodes = nodeIdxList(pl.id).length();
				//print("S");
				val dbuffer = at(pl) {
					recvBuf()(p.id) = new Array[MatrixElement1](nNodes);
					new RemoteArray[MatrixElement1](recvBuf()(p.id) as Array[MatrixElement1](1){self!=null})
				};
				//print("T");
				finish {
					Array.asyncCopy[MatrixElement1](nodeIdxList(pl.id).result(), 0, dbuffer, 0, nNodes);
				}
				//print("U");
			}
		}

		Console.OUT.printf("2 end. time = %f\n", (Timer.milliTime() - start2) / 1000.0);

		val start3 = Timer.milliTime();
		// 3. convert all in neighbour id to index;
		val mapArray = PlaceLocalHandle.make[Array[Array[MatrixElement2]]]
		(Dist.makeUnique(), ()=>(new Array[Array[MatrixElement2]](Place.MAX_PLACES)));
		//print("V");
		finish for (p in Place.places()) async at (p) {
			//print(p);
			val srcArray = new Array[ArrayBuilder[MatrixElement2]](
					Place.MAX_PLACES,
					(Int)=>(new ArrayBuilder[MatrixElement2]()));
			//print("W");
			for (i in recvBuf()) {
				for (j in recvBuf()(i)) {
					//print("X");
					val elem = recvBuf()(i)(j);
					//print("Y");
					val y = vertexInfo.getIDXFromHere(elem.y)();
					//print("Z");
					//val ar = grid.find(y, elem.x);
					//print("A1");
					val gridId = getPlace(elem.x);
					//assert(0 <= gridId && gridId < Place.MAX_PLACES);
					//print("B1");

					srcArray(gridId).add(MatrixElement2(elem.x, y, idToValueMap()(y)()));
					//print("C1");
				}
			}

			// remote array copy
			finish for (pl in Place.places()) async {
				//print("D1");
				val nNodes = srcArray(pl.id).length();
				//print("E1");
				val dbuffer = at(pl) {
					//print("F1");
					mapArray()(p.id) = new Array[MatrixElement2](nNodes);
					//print("G1");
					new RemoteArray[MatrixElement2](mapArray()(p.id) as Array[MatrixElement2](1){self!=null})
				};
				//print("H1");
				finish {
					Array.asyncCopy[MatrixElement2](srcArray(pl.id).result(), 0, dbuffer, 0, nNodes);
				}
				//print("I1");
			}
		}

		Console.OUT.printf("3 end. time = %f\n", (Timer.milliTime() - start3) / 1000.0);

		val arr = new Array[Int](Place.MAX_PLACES);

		val start4 = Timer.milliTime();

		val numNodes = PlaceLocalHandle.make[Cell[Int]](
				Dist.makeUnique(),
				()=>(Cell.make[Int](0)));

		val fun = ()=>{
			var size:Int;
			if (here.id < rem) {
				size = nNodePerPlace + 1;
			} else {
				size = nNodePerPlace;
			}
			val a = new Array[ArrayList[Element]](
					size, (Int)=>(new ArrayList[Element]()));
			for (i in 0..(mapArray().size - 1)) {
				for (j in 0..(mapArray()(i).size - 1)) {
					val v = mapArray()(i)(j);
					a(getIdx(v.x)).add(Element(v.y, v.value));
				}
			}
			a
		};

		val binLink = PlaceLocalHandle.make[Array[ArrayList[Element]]](
				Dist.makeUnique(),
				fun);
		Console.OUT.printf("4 end. time = %f\n", (Timer.milliTime() - start4) / 1000.0);
		Console.OUT.printf("createMatrix time = %f\n", (Timer.milliTime() - funStart) / 1000.0);
		this.binLink = binLink;
	}
}