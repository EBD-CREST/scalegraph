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
	public var algorithm: Int;

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
			val option = dirArgKeywords.getOrThrow(args(i));
			switch (option) {
				case OPT_INPUT_FS_OS:
					break;
				case OPT_INPUT_FS_HDFS:
					break;
				case OPT_INPUT_DATA_FILE:
					break;
				case OPT_INPUT_DATA_FILE_RENUMBERING:
					break;
				case OPT_INPUT_DATA_RMAT:
					break;
				case OPT_INPUT_WEIGHT_FILE:
					break;
				case OPT_INPUT_WEIGHT_RANDOM:
					break;
				case OPT_INPUT_WEIGHT_CONSTANT:
					break;
				case OPT_OUTPUT_FS_OS:
					break;
				case OPT_OUTPUT_FS_HDFS:
					break;
				case OPT_OUTPUT_DATA_FILE:
					break;
				case OPT_PAGERANK_DAMPING:
					break;
				case OPT_PAGERANK_EPS:
					break;
				case OPT_PAGERANK_NITER:
					break;
				default:
					Console.ERR.println("no implementation!");
					return;
			}
		}

		// call algorithm
	}

}
