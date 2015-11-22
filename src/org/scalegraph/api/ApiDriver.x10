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
import org.scalegraph.io.FilePath;
import org.scalegraph.util.MemoryChunk;
import org.scalegraph.util.DistMemoryChunk;
import org.scalegraph.util.random.Random;
import org.scalegraph.util.Parallel;
import org.scalegraph.util.Logger;
import org.scalegraph.id.Type;

import org.scalegraph.exception.ApiException;
import x10.util.NoSuchElementException;

public class ApiDriver {

	public static val API_PASSTHROUGH	:Int = 0n;
	public static val API_PAGERANK	:Int = 10000n;
	
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
	
	public static val OPT_LOG_LOCAL			:Int = 3000n;
	public static val OPT_LOG_GLOBAL		:Int = 3100n;
	public static val OPT_LOG_STDERR		:Int = 3200n;

	public static val OPT_LOG_LOCAL_FS_OS	:Int = 3010n;
	public static val OPT_LOG_LOCAL_FS_HDFS	:Int = 3011n;
	public static val OPT_LOG_LOCAL_FILE	:Int = 3020n;

	public static val OPT_LOG_GLOBAL_FS_OS		:Int = 3110n;
	public static val OPT_LOG_GLOBAL_FS_HDFS	:Int = 3111n;
	public static val OPT_LOG_GLOBAL_FILE		:Int = 3121n;

	public static val NAME_LOG_LOCAL				:String = "--enable-log-local";
	public static val NAME_LOG_GLOBAL				:String = "--enable-log-global";
	public static val NAME_LOG_STDERR				:String = "--enable-log-stderr";

	public static val NAME_LOG_LOCAL_FS_OS			:String = "--log-local-fs-os";
	public static val NAME_LOG_LOCAL_FS_HDFS		:String = "--log-local-fs-hdfs";
	public static val NAME_LOG_LOCAL_FILE			:String = "--log-local-file";

	public static val NAME_LOG_GLOBAL_FS_OS			:String = "--log-global-fs-os";
	public static val NAME_LOG_GLOBAL_FS_HDFS		:String = "--log-global-fs-hdfs";
	public static val NAME_LOG_GLOBAL_FILE			:String = "--log-global-file";

	public static val OPT_PAGERANK_DAMPING			:Int = 10001n;
	public static val OPT_PAGERANK_EPS				:Int = 10002n;
	public static val OPT_PAGERANK_NITER			:Int = 10003n;
	
	public static val NAME_PAGERANK_DAMPING			:String = "--damping";
	public static val NAME_PAGERANK_EPS				:String = "--eps";
	public static val NAME_PAGERANK_NITER			:String = "--niter";


	public val dirArgKeywords :HashMap[String, Int] = new HashMap[String, Int](); 

	public var apiType :Int = API_PASSTHROUGH;

	public var optInputFs :Int = OPT_INPUT_FS_OS;
	public var optInputData :Int = OPT_INPUT_DATA_RMAT;

	public var valueInputDataFile :String = "";
	public var optInputDataFileRenumbering :Boolean = false;
	public var optInputDataFileWeight :Int = OPT_INPUT_DATA_FILE_WEIGHT_RANDOM;
	public var valueInputDataFileWeightConstant :Double = 0.0;

	public var valueInputDataRmatScale		:Int = 8n;
	public var valueInputDataRmatEdgefactor :Int = 16n;
	public var valueInputDataRmatA			:Double = 0.45;
	public var valueInputDataRmatB			:Double = 0.15;
	public var valueInputDataRmatC			:Double = 0.15;

	public var optOutputFs :Int = OPT_OUTPUT_FS_OS;
	public var valueOutputDataFile :String = "";

	public var optEnableLogLocal :Boolean = false;
	public var optEnableLogGlobal :Boolean = false;
	public var optEnableLogStderr :Boolean = false;

	public var optLogLocalFs :Int = OPT_LOG_LOCAL_FS_OS;
	public var optLogGlobalFs :Int = OPT_LOG_GLOBAL_FS_OS;

	public var valueLogLocalFile :String = "apiDriver_%05d.log";
	public var valueLogGlobalFile :String = "apiDriver.log";

	public var valuePagerankDamping :Double = 0.05;
	public var valuePagerankEps :Double = 0.001;
	public var valuePagerankNiter :Int = 30n;

	public static def main(args: Rail[String]) {
		if (args.size < 1) {
			Console.ERR.println("Usage: <api_name> [common_options] [api_options]");
			return;
		}
		try {
			new ApiDriver().execute(args);
		} catch (exception :ApiException) {
			if (Logger.initialized()) {
				Logger.recordLog(String.format("ERROR: %d", [exception.code as Any]));
				Logger.recordLog(exception.getErrorMsg());
				Logger.printStackTrace(exception);
			} else {
				exception.printError();
			}
			System.setExitCode(exception.code);
		} catch (exception :CheckedThrowable) {
			if (Logger.initialized()) {
				Logger.recordLog(String.format("ERROR: %d", [ReturnCode.ERROR_INTERNAL as Any]));
				Logger.printStackTrace(exception);
			} else {
				exception.printStackTrace();
			}
			System.setExitCode(ReturnCode.ERROR_INTERNAL);
		} finally {
			Logger.closeAll();
		}
	}

	public def this() {
		dirArgKeywords.put(NAME_PASSTHROUGH,		API_PASSTHROUGH);
		dirArgKeywords.put(NAME_PAGERANK,			API_PAGERANK);

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

		dirArgKeywords.put(NAME_LOG_LOCAL,			OPT_LOG_LOCAL);
		dirArgKeywords.put(NAME_LOG_GLOBAL,			OPT_LOG_GLOBAL);
		dirArgKeywords.put(NAME_LOG_STDERR,			OPT_LOG_STDERR);
		dirArgKeywords.put(NAME_LOG_LOCAL_FS_OS,	OPT_LOG_LOCAL_FS_OS);
		dirArgKeywords.put(NAME_LOG_LOCAL_FS_HDFS,	OPT_LOG_LOCAL_FS_HDFS);
		dirArgKeywords.put(NAME_LOG_LOCAL_FILE,		OPT_LOG_LOCAL_FILE);
		dirArgKeywords.put(NAME_LOG_GLOBAL_FS_OS,	OPT_LOG_GLOBAL_FS_OS);
		dirArgKeywords.put(NAME_LOG_GLOBAL_FS_HDFS,	OPT_LOG_GLOBAL_FS_HDFS);
		dirArgKeywords.put(NAME_LOG_GLOBAL_FILE,	OPT_LOG_GLOBAL_FILE);

		dirArgKeywords.put(NAME_PAGERANK_DAMPING,	OPT_PAGERANK_DAMPING);
		dirArgKeywords.put(NAME_PAGERANK_EPS,		OPT_PAGERANK_EPS);
		dirArgKeywords.put(NAME_PAGERANK_NITER,		OPT_PAGERANK_NITER);
	}

	public def execute(args: Rail[String]) throws ApiException {

		try {
			apiType = dirArgKeywords.getOrThrow(args(0));
		} catch(e :NoSuchElementException) {
			throw new ApiException.InvalidApiNameException(args(0));
		}

		switch (apiType) {
			case API_PASSTHROUGH:
			case API_PAGERANK:
				break;
			default:
				throw new ApiException.InvalidApiNameException(args(0));
		}

		for (i in 1..(args.size - 1)) {
			val splits :Rail[String] = args(i).split("=");
			val option :Int;

			try {
				option = dirArgKeywords.getOrThrow(splits(0));
			} catch(e: NoSuchElementException) {
				throw new ApiException.InvalidOptionException(splits(0));
			}

			try {
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
						if  (valueInputDataFile.length() == 0n) {
							throw new ApiException.PathRequiredException(NAME_INPUT_DATA_FILE);
						}
						assert(valueInputDataFile.length() > 0);
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
						valueInputDataFileWeightConstant = Double.parse(splits(1));
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
					case OPT_LOG_LOCAL:
						optEnableLogLocal = true;
						break;
					case OPT_LOG_GLOBAL:
						optEnableLogGlobal = true;
						break;
					case OPT_LOG_STDERR:
						optEnableLogStderr = true;
						break;
					case OPT_LOG_LOCAL_FS_OS:
						optLogLocalFs = OPT_LOG_LOCAL_FS_OS;
						break;
					case OPT_LOG_LOCAL_FS_HDFS:
						optLogLocalFs = OPT_LOG_LOCAL_FS_HDFS;
						break;
					case OPT_LOG_LOCAL_FILE:
						valueLogLocalFile = splits(1);
/*
						if (valueLogLocalFile.lastIndexOf("%") < 0) {
							throw new ApiException.OptionStringFormatException(splits(0));
						}
*/
						try {
							checkStringFormat(valueLogLocalFile);
						} catch (e :CheckedThrowable) {
							throw new ApiException.OptionStringFormatException(splits(0));
						}
						break;
					case OPT_LOG_GLOBAL_FS_OS:
						optLogGlobalFs = OPT_LOG_GLOBAL_FS_OS;
						break;
					case OPT_LOG_GLOBAL_FS_HDFS:
						optLogGlobalFs = OPT_LOG_GLOBAL_FS_HDFS;
						break;
					case OPT_LOG_GLOBAL_FILE:
						valueLogGlobalFile = splits(1);
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
						throw new ApiException.InvalidOptionException(splits(0));
				}
			} catch (e :ArrayIndexOutOfBoundsException) {
				throw new ApiException.NoOptionValueException(splits(0));
			} catch (e :NumberFormatException) {
				throw new ApiException.InvalidOptionValueException(args(i));
			}
		}

/*
		Console.ERR.printf("apiDriver: %d\n", apiType);
		Console.ERR.printf("Options:\n");
		Console.ERR.printf("    optInputFs = %d\n", optInputFs);
		Console.ERR.printf("    optInputData = %d\n", optInputData);
		Console.ERR.printf("    valueInputDataFile = %s\n", valueInputDataFile);
		Console.ERR.printf("    optInputDataFileRenumbering = %s\n", optInputDataFileRenumbering ? "true" : "false");
		Console.ERR.printf("    optInputDataFileWeight = %d\n", optInputDataFileWeight);
		Console.ERR.printf("    valueInputDataFileWeightConstant = %f\n", valueInputDataFileWeightConstant);
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
*/

		checkOptionValidity();
		Logger.init(optEnableLogLocal,
					optEnableLogGlobal,
					optEnableLogStderr,
					getFilePathLogLocal(),
					getFilePathLogGlobal());

		// Call API

		switch (apiType) {
			case API_PASSTHROUGH:
				callPassThrough(makeGraph());
				break;
			case API_PAGERANK:
				callPagerank(makeGraph());
				break;
			default:
				assert(false);
				break;
		}
	}

	/* Format string for local log file should contain %d so that
	 * the Logger outputs separated files for each place.
	 */
	private def checkStringFormat(fmt :String) throws CheckedThrowable {
		val tmp1 = String.format(fmt, [1234n as Any]).lastIndexOf("1234");
		val tmp2 = String.format(fmt, [5678n as Any]).lastIndexOf("5678");
/*
		Console.ERR.print(String.format("===> %d, %d\n", [tmp1 as Any, tmp2]) +
						  String.format(fmt, [1234n as Any]) + " " +
						  String.format(fmt, [5678n as Any]));
*/
		assert(tmp1 > 0 && tmp2 > 0 && tmp1 == tmp2);
	}

	private def checkOptionValidity() throws ApiException {
		if (optEnableLogLocal) {
			if (valueLogLocalFile.length() == 0n) {
				throw new ApiException.InvalidOptionValueException(NAME_LOG_LOCAL_FILE);
			}
		}
		if (optEnableLogGlobal) {
			if (valueLogGlobalFile.length() == 0n) {
				throw new ApiException.InvalidOptionValueException(NAME_LOG_GLOBAL_FILE);
			}
		}
		switch(apiType) {
			case API_PASSTHROUGH:
				if (valueOutputDataFile.length() == 0n) {
					throw new ApiException.OptionRequiredException(NAME_OUTPUT_DATA_FILE);
				}
				assert(valueOutputDataFile.length() > 0n);
				break;
			case API_PAGERANK:
				if (valueOutputDataFile.length() == 0n) {
					throw new ApiException.OptionRequiredException(NAME_OUTPUT_DATA_FILE);
				}
				assert(valueOutputDataFile.length() > 0n);
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
		return makeGraphByRmat();
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
		assert(valueInputDataFile.length() > 0);
		switch (optInputFs) {
			case OPT_INPUT_FS_OS:
				filePath = new FilePath(FilePath.FILEPATH_FS_OS, valueInputDataFile);
				break;
			case OPT_INPUT_FS_HDFS:
				filePath = new FilePath(FilePath.FILEPATH_FS_HDFS, valueInputDataFile);
				break;
			default:
				assert(false);
				filePath = new FilePath(FilePath.FILEPATH_FS_HDFS, valueInputDataFile);
		}
		return filePath;
	}

	private def getFilePathOutput() {
		val filePath :FilePath;
		assert(valueOutputDataFile.length() > 0);
		switch (optOutputFs) {
			case OPT_OUTPUT_FS_OS:
				filePath = new FilePath(FilePath.FILEPATH_FS_OS, valueOutputDataFile);
				break;
			case OPT_OUTPUT_FS_HDFS:
				filePath = new FilePath(FilePath.FILEPATH_FS_HDFS, valueOutputDataFile);
				break;
			default:
				assert(false);
				filePath = new FilePath(FilePath.FILEPATH_FS_OS, valueOutputDataFile);
		}
		return filePath;
	}

	private def getFilePathLogLocal() {
		val filePath :FilePath;
		assert(valueLogLocalFile.length() > 0);
		switch (optLogLocalFs) {
			case OPT_LOG_LOCAL_FS_OS:
				filePath = new FilePath(FilePath.FILEPATH_FS_OS, valueLogLocalFile);
				break;
			case OPT_LOG_LOCAL_FS_HDFS:
				filePath = new FilePath(FilePath.FILEPATH_FS_HDFS, valueLogLocalFile);
				break;
			default:
				assert(false);
				filePath = new FilePath(FilePath.FILEPATH_FS_OS, valueLogLocalFile);
		}
		return filePath;
	}

	private def getFilePathLogGlobal() {
		val filePath :FilePath;
		assert(valueLogGlobalFile.length() > 0);
		switch (optLogGlobalFs) {
			case OPT_LOG_GLOBAL_FS_OS:
				filePath = new FilePath(FilePath.FILEPATH_FS_OS, valueLogGlobalFile);
				break;
			case OPT_LOG_GLOBAL_FS_HDFS:
				filePath = new FilePath(FilePath.FILEPATH_FS_HDFS, valueLogGlobalFile);
				break;
			default:
				assert(false);
				filePath = new FilePath(FilePath.FILEPATH_FS_OS, valueLogGlobalFile);
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
				edgeWeight = genConstanceValueEdges(getSize, valueInputDataFileWeightConstant);
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

    protected static def reportResult(b: boolean): void = {
        if (b) success(); else failure();
    }

    public static def success(): void = {
	   at (Place.FIRST_PLACE) 
	     System.setExitCode(0n);
    }

    public static def failure(): void = {
        at (Place.FIRST_PLACE)
           System.setExitCode(1n);
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
    	pg.niter = valuePagerankNiter;
    	pg.eps = valuePagerankEps;
		pg.damping = valuePagerankDamping;
    	val result = pg.execute(matrix);
		CSV.write(getFilePathOutput(), new NamedDistData(["pagerank" as String], [result as Any]), true);
	}

}
