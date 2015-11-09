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

import org.scalegraph.Config;
import org.scalegraph.test.AlgorithmTest;
import org.scalegraph.graph.Graph;
import org.scalegraph.graph.GraphGenerator;
import org.scalegraph.graph.EdgeList;
import org.scalegraph.io.NamedDistData;
import org.scalegraph.io.CSV;
import org.scalegraph.util.MemoryChunk;
import org.scalegraph.util.DistMemoryChunk;
import org.scalegraph.util.random.Random;
import org.scalegraph.id.Type;

final class HDFSTest extends AlgorithmTest {
	public static def main(args: Rail[String]) {
//		new HDFSTest().execute(args);
		generateTestCSV(args);
	}
    
    public def run(args :Rail[String], g :Graph): Boolean {
    	
    	if(args.size < 3) {
    		println("Usage: [high|low] [write|check] <path>");
    		return false;
    	}
		
    	val result :DistMemoryChunk[Double];
    	if(args(0).equals("high")) {
    		result = org.scalegraph.api.PageRank.run(g);
    	}
    	else if(args(0).equals("perf")) {
    		val matrix = g.createDistSparseMatrix[Double](
    				Config.get().distXPregel(), "weight", true, false);
    		// delete the graph object in order to reduce the memory consumption
    		g.del();
    		Config.get().stopWatch().lap("Graph construction: ");
    		val pg = new org.scalegraph.api.PageRank();
    		pg.niter = 30n;
    		pg.eps = 0.0;
    		result = pg.execute(matrix);
    	}
    	else if(args(0).equals("low")) {
    		val matrix = g.createDistSparseMatrix[Double](
    				Config.get().distXPregel(), "weight", true, false);
    		// delete the graph object in order to reduce the memory consumption
    		g.del();
    		Config.get().stopWatch().lap("Graph construction: ");
    		result = org.scalegraph.api.PageRank.run(matrix);
    	}
    	else {
    		throw new IllegalArgumentException("Unknown level parameter :" + args(0));
    	}
		
		if(args(1).equals("write")) {
			CSV.write(args(2), new NamedDistData(["pagerank" as String], [result as Any]), true);
			return true;
		}
		else if(args(1).equals("check")) {
			return checkResult(result, args(2), 0.0001);
		}
		else {
			throw new IllegalArgumentException("Unknown command :" + args(1));
		}
	}

	private static def generateTestCSV(args :Rail[String]) :void {
		if(args.size < 2) {
			throw new IllegalArgumentException("Too few arguments");
		}
		if (args(0).equals("rmat")) {
			val scale = Int.parse(args(1));
			val edgefactor = (args.size > 2) ? Int.parse(args(2)) : 16n;
			val A = (args.size > 3) ? Double.parse(args(3)) : 0.45;
			val B = (args.size > 4) ? Double.parse(args(4)) : 0.15;
			val C = (args.size > 5) ? Double.parse(args(5)) : 0.15;
			val rnd = new Random(2, 3);
			
//			val sw = Config.get().stopWatch();
			val edgeList = GraphGenerator.genRMAT(scale, edgefactor, A, B, C, rnd);
//			sw.lap("Generate RMAT[scale=" + scale + ",edgefactor=" + edgefactor + "]");
			val rawWeight = GraphGenerator.genRandomEdgeValue(scale, edgefactor, rnd);
/*
			sw.lap("Generate random edge value");
			val g = Graph.make(edgeList);
			g.setEdgeAttribute[Double]("weight", rawWeight);
			sw.lap("Complete making graph");
*/

			writeCSV(edgeList, rawWeight);
			
//			return g;
		}
		else if (args(0).equals("random")) {
			val scale = Int.parse(args(1));
			val edgefactor = (args.size > 2) ? Int.parse(args(2)) : 16n;
			val rnd = new Random(2, 3);

//			val sw = Config.get().stopWatch();
			val edgeList = GraphGenerator.genRandomGraph(scale, edgefactor, rnd);
//			sw.lap("Generate edos random graph[scale=" + scale + ",edgefactor=" + edgefactor + "]");
			val rawWeight = GraphGenerator.genRandomEdgeValue(scale, edgefactor, rnd);
/*
			sw.lap("Generate random edge value");
			val g = Graph.make(edgeList);
			g.setEdgeAttribute[Double]("weight", rawWeight);
			sw.lap("Complete making graph");
*/

//			return g;
		}
		else if (args(0).equals("circle")) {
			val scale = Int.parse(args(1));
			val A = (args.size > 2) ? Int.parse(args(2)) : 16n;
			val rnd = new Random(2, 3);

			val team = Config.get().worldTeam();
//			val sw = Config.get().stopWatch();
			val edgeList = GraphGenerator.genCircle(scale, A);
/*
			sw.lap("Generate circle[scale=" + scale + ",length=" + A + "]");
			val rawWeight = GraphGenerator.genRandomEdgeValue(() => (1L << scale) * A / team.size(), rnd);
			sw.lap("Generate random edge value");
			val g = Graph.make(edgeList);
			g.setEdgeAttribute[Double]("weight", rawWeight);
			sw.lap("Complete making graph");
*/

//			return g;
		}
		else if (args(0).equals("tree")) {
			val scale = Int.parse(args(1));
			val rnd = new Random(2, 3);
			val team = Config.get().worldTeam();
//			val sw = Config.get().stopWatch();
			val edgeList = GraphGenerator.genTree(scale);
//			sw.lap("Generate tree[scale=" + scale + "]");
			val rawWeight = GraphGenerator.genRandomEdgeValue(() => (1L << scale)/team.size() - (here.id == 0 ? 1 : 0), rnd);
/*
			sw.lap("Generate random edge value");
			val g = Graph.make(edgeList);
			g.setEdgeAttribute[Double]("weight", rawWeight);
			sw.lap("Complete making graph");
*/

//			return g;
		}
		else if (args(0).equals("file") || args(0).equals("file-renumbering")) {
			/*
			file format
			---input.txt---
			source, target
			1, 2
			1, 3
			2, 3
			---------------
			(double quote can be used)
			*/
			val randomEdge :Boolean = (args.size > 2) ? args(2).equals("random") : true;
			val edgeConstVal = randomEdge ? 0.0 : Double.parse(args(2));
			val colTypes = [Type.Long as Int, Type.Long];

			val renumbering = args(0).equals("file-renumbering");
//			val sw = Config.get().stopWatch();
			val g = Graph.make(CSV.read(args(1), colTypes, true), renumbering);
/*
			sw.lap("Read graph[path=" + args(1) + "]");
			@Ifdef("PROF_IO") { Config.get().dumpProfIO("Graph Load (AlgorithmTest):"); }
			val srcList = g.source();
			val getSize = ()=>srcList().size();
			val edgeList = randomEdge
					? GraphGenerator.genRandomEdgeValue(getSize, new Random(2, 3))
					: genConstanceValueEdges(getSize, edgeConstVal);
			g.setEdgeAttribute("weight", edgeList);
			sw.lap("Generate the edge weights");
*/

//			return g;
		}
		else {
			throw new IllegalArgumentException("Unknown graph type :" + args(0));
		}

	}

	private static def writeCSV(edgeList: EdgeList[Long], rawWeight: DistMemoryChunk[Double]): void {
		CSV.write("output",
				  new NamedDistData(["source" as String,
									 "target",
									 "weight"],
									[edgeList.src,
									 edgeList.dst,
									 rawWeight]),
				  true);
	}

}
