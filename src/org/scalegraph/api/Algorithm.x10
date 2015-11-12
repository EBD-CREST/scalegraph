/* 
 *  This file is part of the ScaleGraph project (http://scalegraph.org).
 * 
 *  This file is licensed to You under the Eclipse Public License (EPL);
 *  You may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *      http://www.opensource.org/licenses/eclipse-1.0.php
 * 
 *  (C) Copyright ScaleGraph Team 2011-2016.
 */

package org.scalegraph.api;

import x10.util.HashMap;
import x10.io.Printer;
import x10.io.Console;

import org.scalegraph.Config;
import org.scalegraph.graph.Graph;
import org.scalegraph.graph.GraphGenerator;
import org.scalegraph.graph.EdgeList;
import org.scalegraph.io.NamedDistData;
import org.scalegraph.io.CSV;
import org.scalegraph.util.MemoryChunk;
import org.scalegraph.util.DistMemoryChunk;
import org.scalegraph.util.random.Random;
import org.scalegraph.id.Type;

public class Algorithm {

	public static val ALGORITHM_PASSTHROUGH	:Int = 0n;
	public static val ALGORITHM_PAGERANK	:Int = 3000n;
	
	public static val NAME_PASSTHROUGH		:String = "passthrough";
	public static val NAME_PAGERANK			:String = "pagerank";
	
	public static val OPT_INPUT_FS_OS		:Int = 1000n;
	public static val OPT_INPUT_FS_HDFS		:Int = 1001n;

	public static val OPT_INPUT_DATA_FILE				:Int = 1010n;
	public static val OPT_INPUT_DATA_FILE_RENUMBERING	:Int = 1011n;
	public static val OPT_INPUT_DATA_FILE_WEIGHT_CSV	:Int = 1012n;
	public static val OPT_INPUT_DATA_FILE_WEIGHT_RANDOM	:Int = 1013n;
	public static val OPT_INPUT_DATA_FILE_WEIGHT_CONSTANT :Int = 1014n;

	public static val OPT_INPUT_DATA_RMAT				:Int = 1020n;
	public static val OPT_INPUT_DATA_RMAT_SCALE			:Int = 1021n;
	public static val OPT_INPUT_DATA_RMAT_EDGEFACTOR	:Int = 1022n;
	public static val OPT_INPUT_DATA_RMAT_A				:Int = 1023n;
	public static val OPT_INPUT_DATA_RMAT_B				:Int = 1024n;
	public static val OPT_INPUT_DATA_RMAT_C				:Int = 1025n;
	
	public static val NAME_INPUT_FS_OS			:String = "--input-fs-os";
	public static val NAME_INPUT_FS_HDFS		:String = "--input-fs-hdfs";

	public static val NAME_INPUT_DATA_FILE		:String = "--input-data-file";
	public static val NAME_INPUT_DATA_FILE_RENUMBERING	:String = "--input-data-file-renumbering";
	public static val NAME_INPUT_DATA_FILE_WEIGHT_CSV		:String = "--input-data-file-weight-csv";
	public static val NAME_INPUT_DATA_FILE_WEIGHT_RANDOM	:String = "--input-data-file-weight-random";
	public static val NAME_INPUT_DATA_FILE_WEIGHT_CONSTANT	:String = "--input-data-file-weight-constant";

	public static val NAME_INPUT_DATA_RMAT				:String = "--input-data-rmat";
	public static val NAME_INPUT_DATA_RMAT_SCALE		:String = "--input-data-rmat-scale";
	public static val NAME_INPUT_DATA_RMAT_EDGEFACTOR	:String = "--input-data-rmat-edgefactor";
	public static val NAME_INPUT_DATA_RMAT_A			:String = "--input-data-rmat-A";
	public static val NAME_INPUT_DATA_RMAT_B			:String = "--input-data-rmat-B";
	public static val NAME_INPUT_DATA_RMAT_C			:String = "--input-data-rmat-C";

	
	public static val OPT_OUTPUT_FS_OS		:Int = 2000n;
	public static val OPT_OUTPUT_FS_HDFS	:Int = 2001n;
	public static val OPT_OUTPUT_DATA_FILE	:Int = 2010n;
	
	public static val NAME_OUTPUT_FS_OS			:String = "--output-fs-os";
	public static val NAME_OUTPUT_FS_HDFS		:String = "--output-fs-hdfs";
	public static val NAME_OUTPUT_DATA_FILE		:String = "--output-data-file";
	
	public static val OPT_PAGERANK_DAMPING			:Int = 3001n;
	public static val OPT_PAGERANK_EPS				:Int = 3002n;
	public static val OPT_PAGERANK_NITER			:Int = 3003n;
	
	public static val NAME_PAGERANK_DAMPING			:String = "--damping";
	public static val NAME_PAGERANK_EPS				:String = "--eps";
	public static val NAME_PAGERANK_NITER			:String = "--niter";


	public val dirArgKeywords :HashMap[String, Int] = new HashMap[String, Int](); 

	public var algorithm :Int = ALGORITHM_PASSTHROUGH;

	public var optInputFs :Int = OPT_INPUT_FS_OS;
	public var optInputData :Int = OPT_INPUT_DATA_RMAT;

	public var valueInputDataFile :String = "";
	public var optInputDataFileRenumbering :Boolean = false;
	public var optInputDataFileWeight :Int = OPT_INPUT_WEIGHT_RANDOM;
	public var valueInputDataFileWeightConstant :Double = 0.0;

	public var valueInputDataRmatScale		:Int = 8;
	public var valueInputDataRmatEdgefactor :Int = 16n;
	public var valueInputDataRmatA			:Double = 0.45;
	public var valueInputDataRmatB			:Double = 0.15;
	public var valueInputDataRmatC			:Double = 0.15;

	public var optOutputFs :Int = OPT_OUTPUT_FS_OS;
	public var valueOutputDataFile :String = "";

	public var valuePagerankDamping :Double = 0.05;
	public var valuePagerankEps :Double = 0.001;
	public var valuePagerankNiter :Int = 30n;

	public static def main(args: Rail[String]) {
		if (args.size < 1) {
			Console.ERR.println("Usage: <algorithm_name> [common_options] [algorithm_options]");
			return;
		}
		new Algorithm().execute(args);
	}

	public def this() {
		dirArgKeywords.put(NAME_PASSTHROUGH,		ALGORITHM_PASSTHROUGH);
		dirArgKeywords.put(NAME_PAGERANK,			ALGORITHM_PAGERANK);

		dirArgKeywords.put(NAME_INPUT_FS_OS,		OPT_INPUT_FS_OS);
		dirArgKeywords.put(NAME_INPUT_FS_HDFS,		OPT_INPUT_FS_HDFS);

		dirArgKeywords.put(NAME_INPUT_DATA_FILE,				OPT_INPUT_DATA_FILE);
		dirArgKeywords.put(NAME_INPUT_DATA_FILE_RENUMBERING,	OPT_INPUT_DATA_FILE_RENUMBERING);
		dirArgKeywords.put(NAME_INPUT_DATA_FILE_WEIGHT_CSV,		OPT_INPUT_DATA_FILE_WEIGHT_CSV);
		dirArgKeywords.put(NAME_INPUT_DATA_FILE_WEIGHT_RANDOM,	OPT_INPUT_DATA_FILE_WEIGHT_RANDOM);
		dirArgKeywords.put(NAME_INPUT_DATA_FILE_WEIGHT_CONSTANT,OPT_INPUT_DATA_FILE_WEIGHT_CONSTANT);

		dirArgKeywords.put(NAME_INPUT_DATA_RMAT,			OPT_INPUT_DATA_RMAT);
		dirArgKeywords.put(NAME_INPUT_DATA_RMAT_SCALE,		OPT_INPUT_DATA_RMAT_SCALE);
		dirArgKeywords.put(NAME_INPUT_DATA_RMAT_EDGEFACTOR,	OPT_INPUT_DATA_RMAT_EDGEFACTOR);
		dirArgKeywords.put(NAME_INPUT_DATA_RMAT_A,			OPT_INPUT_DATA_RMAT_A);
		dirArgKeywords.put(NAME_INPUT_DATA_RMAT_B,			OPT_INPUT_DATA_RMAT_B);
		dirArgKeywords.put(NAME_INPUT_DATA_RMAT_C,			OPT_INPUT_DATA_RMAT_C);

		dirArgKeywords.put(NAME_OUTPUT_FS_OS,		OPT_OUTPUT_FS_OS);
		dirArgKeywords.put(NAME_OUTPUT_FS_HDFS,		OPT_OUTPUT_FS_HDFS);
		dirArgKeywords.put(NAME_OUTPUT_DATA_FILE,	OPT_OUTPUT_DATA_FILE);

		dirArgKeywords.put(NAME_PAGERANK_DAMPING,	OPT_PAGERANK_DAMPING);
		dirArgKeywords.put(NAME_PAGERANK_EPS,		OPT_PAGERANK_EPS);
		dirArgKeywords.put(NAME_PAGERANK_NITER,		OPT_PAGERANK_NITER);
	}

	public def execute(args: Rail[String]) {
		algorithm = dirArgKeywords.getOrThrow(args(0));

		switch (algorithm) {
			case ALGORITHM_PASSTHROUGH:
			case ALGORITHM_PAGERANK:
				break;
			default:
				Console.ERR.println("Invalid algorithm name");
				return;
		}

		for (i in 1..(args.size - 1)) {
			val splits :Rail[String] = args(i).split("=");
			val option = dirArgKeywords.getOrThrow(splits(0));

			switch (option) {
				case OPT_INPUT_FS_OS:
					optInputFs = OPT_INPUT_FS_OS;
					break;
				case OPT_INPUT_FS_HDFS:
					optInputFs = OPT_INPUT_FS_HDFS;
					break;
				case OPT_INPUT_DATA_FILE:
					optInputData = OPT_INPUT_DATA_FILE;
					valueInputDataFile = splits(1);
					assert(valueInputDataFile.size > 0);
					break;
				case OPT_INPUT_DATA_FILE_RENUMBERING:
					optInputData = OPT_INPUT_DATA_FILE_RENUMBERING;
					optInputDataFileRenumbering = true;
					break;
				case OPT_INPUT_DATA_FILE_WEIGHT_CSV:
					optInputDataFileWeight = OPT_INPUT_DATA_FILE_WEIGHT_CSV;
					break;
				case OPT_INPUT_DATA_FILE_WEIGHT_RANDOM:
					optInputDataFileWeight = OPT_INPUT_DATA_FILE_WEIGHT_RANDOM;
					break;
				case OPT_INPUT_DATA_FILE_WEIGHT_CONSTANT:
					optInputDataFileWeight = OPT_INPUT_DATA_FILE_WEIGHT_CONSTANT;
					valueInputWeightConstant = Double.parse(splits(1));
					break;
				case OPT_INPUT_DATA_RMAT:
					optInputData = OPT_INPUT_DATA_RMAT;
					break;
				case OPT_INPUT_DATA_RMAT_SCALE:
					valueInputDataRmatScale = Int.parse(splits(1));
					break;
				case OPT_INPUT_DATA_RMAT_EDGEFACTOR:
					valueInputDataRmatEdgefactor = Int.parse(splits(1));
					break;
				case OPT_INPUT_DATA_RMAT_A:
					valueInputDataRmatA = Double.parse(splits(1));
					break;
				case OPT_INPUT_DATA_RMAT_B:
					valueInputDataRmatB = Double.parse(splits(1));
					break;
				case OPT_INPUT_DATA_RMAT_C:
					valueInputDataRmatC = Double.parse(splits(1));
					break;
				case OPT_OUTPUT_FS_OS:
					optOutputFs = OPT_OUTPUT_FS_OS;
					break;
				case OPT_OUTPUT_FS_HDFS:
					optOutputFs = OPT_OUTPUT_FS_HDFS;
					break;
				case OPT_OUTPUT_DATA_FILE:
					valueOutputDataFile = splits(1);
					break;
				case OPT_PAGERANK_DAMPING:
					valuePagerankDamping = Double.parse(splits(1));
					break;
				case OPT_PAGERANK_EPS:
					valuePagerankEps = Double.parse(splits(1));
					break;
				case OPT_PAGERANK_NITER:
					valuePagerankNiter = Int.parse(splits(1));
					break;
				default:
					Console.ERR.println("no implementation!");
					return;
			}
		}

		Console.ERR.printf("Algorithm: %d\n", algorithm);
		Console.ERR.printf("Options:\n");
		Console.ERR.printf("    optInputFs = %d\n", optInputFs);
		Console.ERR.printf("    optInputData = %d\n", optInputData);
		Console.ERR.printf("    valueInputDataFile = %s\n", valueInputDataFile);
		Console.ERR.printf("    optInputDataFileRenumbering = %s\n", optInputDataFileRenumbering ? "true" : "false");
		Console.ERR.printf("    optInputDataFileWeight = %d\n", optInputDataFileWeight);
		Console.ERR.printf("    valueInputWeightConstant = %f\n", valueInputWeightConstant);
		Console.ERR.printf("    valueInputDataRmatScale = %d\n", valueInputDataRmatScale);
		Console.ERR.printf("    valueInputDataRmatEdgefactor = %d\n", valueInputDataRmatEdgefactor);
		Console.ERR.printf("    valueInputDataRmatA = %f\n", valueInputDataRmatA);
		Console.ERR.printf("    valueInputDataRmatB = %f\n", valueInputDataRmatB);
		Console.ERR.printf("    valueInputDataRmatC = %f\n", valueInputDataRmatC);
		Console.ERR.printf("    optOutputFs = %d\n", optOutputFs);
		Console.ERR.printf("    valueOutputDataFile = %s\n", valueOutputDataFile);
		Console.ERR.printf("    valuePagerankDamping = %f\n", valuePagerankDamping);
		Console.ERR.printf("    valuePagerankEps = %f\n", valuePagerankEps);
		Console.ERR.printf("    valuePagerankNiter = %d\n", valuePagerankNiter);

		checkOptionValidity();

		// Call algorithm

		switch (algorithm) {
			case ALGORITHM_PASSTHROUGH:
				callPassThrough(makeGraph());
			case ALGORITHM_PAGERANK:
				callPagerank(makeGraph());
				break;
			default:
				assert(false);
				break;
		}

	}

	private def checkOptionValidity() {
		switch(algorithm) {
			case ALGORITHM_PASSTHROUGH:
				assert(valueOutputDataFile.size > 0);
				break;
			case ALGORITHM_PAGERANK:
				assert(valueOutputDataFile.size > 0);
				break;
			default:
				break;
		}
	}

	private def makeGraph() :Graph {
		switch (optInputData) {
			case OPT_INPUT_DATA_RMAT:
				return makeGraphByRmat();
			case OPT_INPUT_DATA_FILE:
			case OPT_INPUT_DATA_FILE_RENUMBERING:
				return makeGraphByFile();
			default:
				assert(false);
				break;
		}
	}

	private def makeGraphByRmat() {
		val rnd = new Random(2, 3);
		val edgeList = GraphGenerator.genRMAT(valueInputDataRmatScale,
											  valueInputDataRmatEdgefactor,
											  valueInputDataRmatA,
											  valueInputDataRmatB,
											  valueInputDataRmatC,
											  rnd);
		val rawWeight = GraphGenerator.genRandomEdgeValue(valueInputDataRmatScale,
														  valueInputDataRmatEdgefactor,
														  rnd);
		val g = Graph.make(edgeList);
		g.setEdgeAttribute[Double]("weight", rawWeight);
		return g;
	}

	private def getFilePathInput() {
		val filePath :FilePath;
		assert(valueInputDataFile.size > 0);
		switch (optInputFs) {
			case OPT_INPUT_FS_OS:
				filePath = new FilePath(FilePath.FILEPATH_FS_OS, valueInputDataFile);
				break;
			case OPT_INPUT_FS_HDFS:
				filePath = new FilePath(FilePath.FILEPATH_FS_HDFS, valueInputDataFile);
				break;
			default:
				assert(false);
		}
		return filePath;
	}

	private def getFilePathOutput() {
		val filePath :FilePath;
		assert(valueOutputDataFile.size > 0);
		switch (optOutputFs) {
			case OPT_OUTPUT_FS_OS:
				filePath = new FilePath(FilePath.FILEPATH_FS_OS, valueOutputDataFile);
				break;
			case OPT_OUTPUT_FS_HDFS:
				filePath = new FilePath(FilePath.FILEPATH_FS_HDFS, valueOutputDataFile);
				break;
			default:
				assert(false);
		}
		return filePath;
	}

	private def makeGraphByFile() {
		val colTypes :Rail[Int];
		if (optInputDataFileWeight == OPT_INPUT_DATA_FILE_WEIGHT_CSV) {
			colTypes = [Type.Long as Int, Type.Long, Type.Long, Type.Double];
		} else {
			colTypes = [Type.Long as Int, Type.Long, Type.Long];
		}
		val edgeCSV = CSV.read(getFilePathInput(), colTypes, true);
		val g = Graph.make(edgeCSV, optInputDataFileRenumbering);
		val srcList = g.source();
		val getSize = ()=>srcList().size();
		val edgeWeight :DistMemoryChunk[Double];
		switch (optInputDataFileWeight) {
			case OPT_INPUT_DATA_FILE_WEIGHT_CSV:
				val weightIdx = edgeCSV.nameToIndex("weight");
				edgeWeight = edgeCSV.data()(weightIdx) as DistMemoryChunk[Double];
				break;
			case OPT_INPUT_DATA_FILE_WEIGHT_RANDOM:
				edgeWeight = GraphGenerator.genRandomEdgeValue(getSize, new Random(2, 3));
				break;
			case OPT_INPUT_DATA_FILE_WEIGHT_CONSTANT:
				edgeWeight = genConstanceValueEdges(getSize, valueInputDataFileWeightConstant);
				break;
				default:
				assert(false);
		}
		g.setEdgeAttribute("weight", edgeWeight);
		return g;
	}

	private static def genConstanceValueEdges(getSize :()=>Long, value :Double)
	{
		val team = Config.get().worldTeam();
		
		val edgeMemory = new DistMemoryChunk[Double](team.placeGroup(),
				() => MemoryChunk.make[Double](getSize()));
		
		team.placeGroup().broadcastFlat(() => {
			val role = team.role()(0);
			Parallel.iter(0..(getSize() - 1), (tid :Long, r :LongRange) => {
				val edgeMem_ = edgeMemory();
				for(i in r) {
					edgeMem_(i) = value;
				}
			});
		});
		
		return edgeMemory;
	}

	public def callPassThrough(graph :Graph) {
		CSV.write(getFilePathOutput(),
				  new NamedDistData(["source" as String,
									 "target",
									 "weight"],
									[graph.source(),
									 graph.target(),
									 graph.getEdgeAttribute[Double]("weight")]),
				  true);
	}

	public def callPagerank(graph :Graph) {
    	val matrix = graph.createDistSparseMatrix[Double](
    		Config.get().distXPregel(), "weight", true, false);
    	// delete the graph object in order to reduce the memory consumption
    	graph.del();
    	Config.get().stopWatch().lap("Graph construction: ");
    	val pg = new org.scalegraph.api.PageRank();
    	pg.niter = 30n;
    	pg.eps = 0.0;
    	result = pg.execute(matrix);
		CSV.write(getFilePathOutput(), new NamedDistData(["pagerank" as String], [result as Any]), true);
	}

}
