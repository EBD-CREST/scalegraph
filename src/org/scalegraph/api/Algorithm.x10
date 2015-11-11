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
	public static val OPT_INPUT_DATA_FILE	:Int = 1010n;
	public static val OPT_INPUT_DATA_FILE_RENUMBERING :Int = 1011n;
	public static val OPT_INPUT_DATA_RMAT	:Int = 1020n;
	public static val OPT_INPUT_WEIGHT_FILE	:Int = 1030n;
	public static val OPT_INPUT_WEIGHT_RANDOM :Int = 1031n;
	public static val OPT_INPUT_WEIGHT_CONSTANT :Int = 1032n;
	
	public static val NAME_INPUT_FS_OS			:String = "--input-fs-os";
	public static val NAME_INPUT_FS_HDFS		:String = "--input-fs-hdfs";
	public static val NAME_INPUT_DATA_FILE		:String = "--input-data-file";
	public static val NAME_INPUT_DATA_FILE_RENUMBERING	:String = "--input-data-file-renumbering";
	public static val NAME_INPUT_DATA_RMAT		:String = "--input-data-rmat";
	public static val NAME_INPUT_WEIGHT_FILE	:String = "--input-weight-file";
	public static val NAME_INPUT_WEIGHT_RANDOM	:String = "--input-weight-random";
	public static val NAME_INPUT_WEIGHT_CONSTANT	:String = "--input-weight-constant";
	
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
	public var valueInputDataRmat :Double = 0.0;
	public var optInputWeight :Int = OPT_INPUT_WEIGHT_RANDOM;
	public var valueInputWeightConstant :Double = 0.0;
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
		dirArgKeywords.put(NAME_INPUT_DATA_FILE,	OPT_INPUT_DATA_FILE);
		dirArgKeywords.put(NAME_INPUT_DATA_FILE_RENUMBERING, OPT_INPUT_DATA_FILE_RENUMBERING);
		dirArgKeywords.put(NAME_INPUT_DATA_RMAT,	OPT_INPUT_DATA_RMAT);
		dirArgKeywords.put(NAME_INPUT_WEIGHT_FILE,	OPT_INPUT_WEIGHT_FILE);
		dirArgKeywords.put(NAME_INPUT_WEIGHT_RANDOM, OPT_INPUT_WEIGHT_RANDOM);
		dirArgKeywords.put(NAME_INPUT_WEIGHT_CONSTANT, OPT_INPUT_WEIGHT_CONSTANT);
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
					break;
				case OPT_INPUT_DATA_FILE_RENUMBERING:
					optInputData = OPT_INPUT_DATA_FILE_RENUMBERING;
					valueInputDataFile = splits(1);
					break;
				case OPT_INPUT_DATA_RMAT:
					optInputData = OPT_INPUT_DATA_RMAT;
					valueInputDataRmat = Double.parse(splits(1));
					break;
				case OPT_INPUT_WEIGHT_FILE:
					optInputWeight = OPT_INPUT_WEIGHT_FILE;
					break;
				case OPT_INPUT_WEIGHT_RANDOM:
					optInputWeight = OPT_INPUT_WEIGHT_RANDOM;
					break;
				case OPT_INPUT_WEIGHT_CONSTANT:
					optInputWeight = OPT_INPUT_WEIGHT_CONSTANT;
					valueInputWeightConstant = Double.parse(splits(1));
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
		Console.ERR.printf("    valueInputDataRmat = %f\n", valueInputDataRmat);
		Console.ERR.printf("    optInputWeight = %d\n", optInputWeight);
		Console.ERR.printf("    valueInputWeightConstant = %f\n", valueInputWeightConstant);
		Console.ERR.printf("    optOutputFs = %d\n", optOutputFs);
		Console.ERR.printf("    valueOutputDataFile = %s\n", valueOutputDataFile);
		Console.ERR.printf("    valuePagerankDamping = %f\n", valuePagerankDamping);
		Console.ERR.printf("    valuePagerankEps = %f\n", valuePagerankEps);
		Console.ERR.printf("    valuePagerankNiter = %d\n", valuePagerankNiter);

		// call algorithm
	}

}
