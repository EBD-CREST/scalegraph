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
import x10.util.StringBuilder;
import x10.io.Printer;
import x10.io.Console;

import org.scalegraph.Config;
import org.scalegraph.graph.Graph;
import org.scalegraph.graph.GraphGenerator;
import org.scalegraph.graph.EdgeList;
import org.scalegraph.io.NamedDistData;
import org.scalegraph.io.CSV;
import org.scalegraph.io.FilePath;
import org.scalegraph.io.FileWriter;
import org.scalegraph.io.FileMode;
import org.scalegraph.util.MemoryChunk;
import org.scalegraph.util.DistMemoryChunk;
import org.scalegraph.util.Dist2D;
import org.scalegraph.util.random.Random;
import org.scalegraph.util.Parallel;
import org.scalegraph.util.Logger;
import org.scalegraph.util.SString;
import org.scalegraph.util.SStringBuilder;
import org.scalegraph.id.Type;

import org.scalegraph.exception.ApiException;
import x10.util.NoSuchElementException;

public class ApiDriver {

	public static val API_PASSTHROUGH			:Int = 0n;
	public static val API_PAGERANK				:Int = 10000n;
	public static val API_MINIMUMSPANNINGTREE	:Int = 20000n;
	public static val API_DEGREEDISTRIBUTION	:Int = 30000n;
	public static val API_BETWEENNESSCENTRALITY	:Int = 40000n;
	public static val API_HYPERANF				:Int = 50000n;
	public static val API_STRONGLYCONNECTEDCOMPONENT	:Int = 60000n;
	public static val API_MAXFLOW				:Int = 70000n;
	public static val API_SPECTRALCLUSTERING	:Int = 80000n;
	public static val API_XPREGEL				:Int = 90000n;

	public static val NAME_PASSTHROUGH				:String = "gen";
	public static val NAME_PAGERANK					:String = "pr";
	public static val NAME_MINIMUMSPANNINGTREE		:String = "mst";
	public static val NAME_DEGREEDISTRIBUTION		:String = "dd";
	public static val NAME_BETWEENNESSCENTRALITY	:String = "bc";
	public static val NAME_HYPERANF					:String = "hanf";
	public static val NAME_STRONGLYCONNECTEDCOMPONENT	:String = "scc";
	public static val NAME_MAXFLOW					:String = "mf";
	public static val NAME_SPECTRALCLUSTERING		:String = "sc";
	public static val NAME_XPREGEL					:String = "xpregel";
	
	public static val OPT_INPUT_FS_OS		:Int = 1000n;
	public static val OPT_INPUT_FS_HDFS		:Int = 1001n;

	public static val OPT_INPUT_DATA_FILE				:Int = 1010n;
	public static val OPT_INPUT_DATA_FILE_RENUMBERING	:Int = 1011n;
	public static val OPT_INPUT_DATA_FILE_WEIGHT_CSV	:Int = 1012n;
	public static val OPT_INPUT_DATA_FILE_WEIGHT_RANDOM	:Int = 1013n;
	public static val OPT_INPUT_DATA_FILE_WEIGHT_CONSTANT :Int = 1014n;
	public static val OPT_INPUT_DATA_FILE_HEADER_SOURCE	:Int = 1015n;
	public static val OPT_INPUT_DATA_FILE_HEADER_TARGET	:Int = 1016n;
	public static val OPT_INPUT_DATA_FILE_HEADER_WEIGHT	:Int = 1017n;

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

	public static val NAME_INPUT_DATA_FILE_HEADER_SOURCE	:String = "--input-data-file-header-source";
	public static val NAME_INPUT_DATA_FILE_HEADER_TARGET	:String = "--input-data-file-header-target";
	public static val NAME_INPUT_DATA_FILE_HEADER_WEIGHT	:String = "--input-data-file-header-weight";

	public static val NAME_INPUT_DATA_RMAT				:String = "--input-data-rmat";
	public static val NAME_INPUT_DATA_RMAT_SCALE		:String = "--input-data-rmat-scale";
	public static val NAME_INPUT_DATA_RMAT_EDGEFACTOR	:String = "--input-data-rmat-edgefactor";
	public static val NAME_INPUT_DATA_RMAT_A			:String = "--input-data-rmat-A";
	public static val NAME_INPUT_DATA_RMAT_B			:String = "--input-data-rmat-B";
	public static val NAME_INPUT_DATA_RMAT_C			:String = "--input-data-rmat-C";

	
	public static val OPT_OUTPUT_FS_OS		:Int = 2000n;
	public static val OPT_OUTPUT_FS_HDFS	:Int = 2001n;
	public static val OPT_OUTPUT_DATA_FILE	:Int = 2002n;
	public static val OPT_OUTPUT_DATA_FILE_HEADER_SOURCE	:Int = 2003n;
	public static val OPT_OUTPUT_DATA_FILE_HEADER_TARGET	:Int = 2004n;
	public static val OPT_OUTPUT_DATA_FILE_HEADER_WEIGHT	:Int = 2005n;
	
	public static val OPT_OUTPUT1_FS_OS		:Int = 2010n;
	public static val OPT_OUTPUT1_FS_HDFS	:Int = 2011n;
	public static val OPT_OUTPUT1_DATA_FILE	:Int = 2012n;

	public static val OPT_OUTPUT2_FS_OS		:Int = 2020n;
	public static val OPT_OUTPUT2_FS_HDFS	:Int = 2021n;
	public static val OPT_OUTPUT2_DATA_FILE	:Int = 2022n;

	public static val NAME_OUTPUT_FS_OS			:String = "--output-fs-os";
	public static val NAME_OUTPUT_FS_HDFS		:String = "--output-fs-hdfs";
	public static val NAME_OUTPUT_DATA_FILE		:String = "--output-data-file";
	public static val NAME_OUTPUT_DATA_FILE_HEADER_SOURCE	:String = "--output-data-file-header-source";
	public static val NAME_OUTPUT_DATA_FILE_HEADER_TARGET	:String = "--output-data-file-header-target";
	public static val NAME_OUTPUT_DATA_FILE_HEADER_WEIGHT	:String = "--output-data-file-header-weight";

	public static val NAME_OUTPUT1_FS_OS		:String = "--output1-fs-os";
	public static val NAME_OUTPUT1_FS_HDFS		:String = "--output1-fs-hdfs";
	public static val NAME_OUTPUT1_DATA_FILE	:String = "--output1-data-file";

	public static val NAME_OUTPUT2_FS_OS		:String = "--output2-fs-os";
	public static val NAME_OUTPUT2_FS_HDFS		:String = "--output2-fs-hdfs";
	public static val NAME_OUTPUT2_DATA_FILE	:String = "--output2-data-file";
	
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
	
	public static val NAME_PAGERANK_DAMPING			:String = "--pr-damping";
	public static val NAME_PAGERANK_EPS				:String = "--pr-eps";
	public static val NAME_PAGERANK_NITER			:String = "--pr-niter";

	public static val OPT_BC_WEIGHTED				:Int = 40001n;
	public static val OPT_BC_DIRECTED				:Int = 40002n;
	public static val OPT_BC_SOURCE					:Int = 40003n;
	public static val OPT_BC_DELTA					:Int = 40004n;
	public static val OPT_BC_NORMALIZE				:Int = 40005n;
	public static val OPT_BC_LINEARSCALE			:Int = 40006n;
	public static val OPT_BC_EXACTBC				:Int = 40007n;

	public static val NAME_BC_WEIGHTED				:String = "--bc-weighted";
	public static val NAME_BC_DIRECTED				:String = "--bc-directed";
	public static val NAME_BC_SOURCE				:String = "--bc-source";
	public static val NAME_BC_DELTA					:String = "--bc-delta";
	public static val NAME_BC_NORMALIZE				:String = "--bc-normalize";
	public static val NAME_BC_LINEARSCALE			:String = "--bc-linearScale";
	public static val NAME_BC_EXACTBC				:String = "--bc-exactBC";

	public static val OPT_HANF_NITER				:Int = 50001n;
	public static val OPT_HANF_B					:Int = 50002n;

	public static val NAME_HANF_NITER				:String = "--hanf-niter";
	public static val NAME_HANF_B					:String = "--hanf-b";

	public static val OPT_SCC_DIRECTED				:Int = 60001n;
	public static val OPT_SCC_NITER					:Int = 60002n;

	public static val NAME_SCC_DIRECTED				:String = "--scc-directed";
	public static val NAME_SCC_NITER				:String = "--scc-niter";

	public static val OPT_MF_SOURCE_ID				:Int = 70001n;
	public static val OPT_MF_SINK_ID				:Int = 70002n;
	public static val OPT_MF_EPS					:Int = 70003n;
	public static val OPT_MF_RECURSIONLIMIT			:Int = 70004n;

	public static val NAME_MF_SOURCE_ID				:String = "--mf-source-id";
	public static val NAME_MF_SINK_ID				:String = "--mf-sink-id";
	public static val NAME_MF_EPS					:String = "--mf-eps";
	public static val NAME_MF_RECURSIONLIMIT		:String = "--mf-recursionLimit";

	public static val OPT_SC_NUM_CLUSTER			:Int = 80001n;
	public static val OPT_SC_TOLERANCE				:Int = 80002n;
	public static val OPT_SC_MAXITER				:Int = 80003n;
	public static val OPT_SC_THRESHOLD				:Int = 80004n;

	public static val NAME_SC_NUM_CLUSTER			:String = "--sc-num-cluster";
	public static val NAME_SC_TOLERANCE				:String = "--sc-tolerance";
	public static val NAME_SC_MAXITER				:String = "--sc-maxiter";
	public static val NAME_SC_THRESHOLD				:String = "--sc-threshold";

	public val dirArgKeywords :HashMap[String, Int] = new HashMap[String, Int](); 

	public var apiType :Int = API_PASSTHROUGH;

	public var optInputFs :Int = OPT_INPUT_FS_OS;
	public var optInputData :Int = OPT_INPUT_DATA_RMAT;

	public var valueInputDataFile :String = "";
	public var optInputDataFileRenumbering :Boolean = false;
	public var optInputDataFileWeight :Int = OPT_INPUT_DATA_FILE_WEIGHT_RANDOM; // This default value is changed depending on the alogithm selected.
	public var valueInputDataFileWeightConstant :Double = 0.0;
	public var valueInputDataFileHeaderSource	:String = "source";
	public var valueInputDataFileHeaderTarget	:String = "target";
	public var valueInputDataFileHeaderWeight	:String = "weight";

	public var valueInputDataRmatScale		:Int = 8n;
	public var valueInputDataRmatEdgefactor :Int = 16n;
	public var valueInputDataRmatA			:Double = 0.45;
	public var valueInputDataRmatB			:Double = 0.15;
	public var valueInputDataRmatC			:Double = 0.15;

	public var optOutputFs :Int = OPT_OUTPUT_FS_OS;
	public var valueOutputDataFile :String = "";
	public var valueOutputDataFileHeaderSource	:String = "source";
	public var valueOutputDataFileHeaderTarget	:String = "target";
	public var valueOutputDataFileHeaderWeight	:String = "weight";

	public var optOutput1Fs :Int = OPT_OUTPUT1_FS_OS;
	public var valueOutput1DataFile :String = "";

	public var optOutput2Fs :Int = OPT_OUTPUT2_FS_OS;
	public var valueOutput2DataFile :String = "";

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

	public var valueBCWeighted :Boolean = false;
	public var valueBCDirected :Boolean = true;
	public var valueBCSource :Long = 0;
	public var valueBCDelta :Int = 1n;
	public var valueBCNormalize :Boolean = false;
	public var valueBCLinearScale :Boolean = false;
	public var valueBCExactBC :Boolean = false;

	public var valueHANFNiter	:Int = 1000n;
	public var valueHANFB		:Int = 7n;

	public var valueSCCDirected			:Boolean = true;
	public var valueSCCNiter			:Int = 1000n;

	public var valueMFSourceId			:Long = -1n;
	public var valueMFSinkId			:Long = -1n;
	public var valueMFEPS				:Double = 1e-6;
	public var valueMFRecursionLimit	:Long = 1000000;

	public var valueSCNumCluster			:Int = 2n;
	public var valueSCTolerance				:Double = 0.01;
	public var valueSCMaxIter				:Int = 1000n;
	public var valueSCThreshold				:Double = 0.0001;

	public var apiResult :Result;

	public static class Result {
		val buffer = new StringBuilder();
		var status :Int = 0n;

		public def this() {
		}

		public def setStatus(_status :Int) {
			status = _status;
		}

		public def add(key :String, value :String) {
			buffer.add(key + ":" + value + ", ");
		}


		public def toString() {
			return String.format("\"Status\":%ld", [status as Any]);
		}

		public def write() {
			Console.OUT.println("{" + 
								buffer.toString() +
								String.format("\"Status\":%ld", [status as Any]) +
								"}");
		}
	}

	public def addResult(key :String, value :String) {
		apiResult.add(key, value);
	}

	public def setStatus(_status :Int) {
		apiResult.setStatus(_status);
	}

	public def writeResult() {
		apiResult.write();
	}

	public static def main(args: Rail[String]) {
		val apiDriver = new ApiDriver();
		apiDriver.apiResult = new Result();
		apiDriver.setStatus(ReturnCode.SUCCESS);
		if (args.size < 1) {
			Console.ERR.println("Usage: <api_name> [common_options] [api_options]");
			return;
		}
		try {
			apiDriver.execute(args);
			System.setExitCode(0n);
		} catch (exception :ApiException) {
			if (Logger.initialized()) {
				Logger.recordLog(String.format("ERROR: %d", [exception.code as Any]));
				Logger.recordLog(exception.getErrorMsg());
				Logger.printStackTrace(exception);
			} else {
				exception.printError();
			}
			apiDriver.setStatus(exception.code);
			System.setExitCode(1n);
		} catch (exception :CheckedThrowable) {
			if (Logger.initialized()) {
				Logger.recordLog(String.format("ERROR: %d", [ReturnCode.ERROR_INTERNAL as Any]));
				Logger.printStackTrace(exception);
			} else {
				exception.printStackTrace();
			}
			apiDriver.setStatus(ReturnCode.ERROR_INTERNAL);
			System.setExitCode(1n);
		} finally {
			Logger.closeAll();
			apiDriver.writeResult();
		}
	}

	public def this() {

		dirArgKeywords.put(NAME_PASSTHROUGH,			API_PASSTHROUGH);
		dirArgKeywords.put(NAME_PAGERANK,				API_PAGERANK);
		dirArgKeywords.put(NAME_MINIMUMSPANNINGTREE,	API_MINIMUMSPANNINGTREE);
		dirArgKeywords.put(NAME_DEGREEDISTRIBUTION,		API_DEGREEDISTRIBUTION);
		dirArgKeywords.put(NAME_BETWEENNESSCENTRALITY,	API_BETWEENNESSCENTRALITY);
		dirArgKeywords.put(NAME_HYPERANF,				API_HYPERANF);
		dirArgKeywords.put(NAME_STRONGLYCONNECTEDCOMPONENT,	API_STRONGLYCONNECTEDCOMPONENT);
		dirArgKeywords.put(NAME_MAXFLOW,				API_MAXFLOW);
		dirArgKeywords.put(NAME_SPECTRALCLUSTERING,		API_SPECTRALCLUSTERING);
		dirArgKeywords.put(NAME_XPREGEL,				API_XPREGEL);

		dirArgKeywords.put(NAME_INPUT_FS_OS,		OPT_INPUT_FS_OS);
		dirArgKeywords.put(NAME_INPUT_FS_HDFS,		OPT_INPUT_FS_HDFS);

		dirArgKeywords.put(NAME_INPUT_DATA_FILE,				OPT_INPUT_DATA_FILE);
		dirArgKeywords.put(NAME_INPUT_DATA_FILE_RENUMBERING,	OPT_INPUT_DATA_FILE_RENUMBERING);
		dirArgKeywords.put(NAME_INPUT_DATA_FILE_WEIGHT_CSV,		OPT_INPUT_DATA_FILE_WEIGHT_CSV);
		dirArgKeywords.put(NAME_INPUT_DATA_FILE_WEIGHT_RANDOM,	OPT_INPUT_DATA_FILE_WEIGHT_RANDOM);
		dirArgKeywords.put(NAME_INPUT_DATA_FILE_WEIGHT_CONSTANT,OPT_INPUT_DATA_FILE_WEIGHT_CONSTANT);

		dirArgKeywords.put(NAME_INPUT_DATA_FILE_HEADER_SOURCE, OPT_INPUT_DATA_FILE_HEADER_SOURCE);
		dirArgKeywords.put(NAME_INPUT_DATA_FILE_HEADER_TARGET, OPT_INPUT_DATA_FILE_HEADER_TARGET);
		dirArgKeywords.put(NAME_INPUT_DATA_FILE_HEADER_WEIGHT, OPT_INPUT_DATA_FILE_HEADER_WEIGHT);

		dirArgKeywords.put(NAME_INPUT_DATA_RMAT,			OPT_INPUT_DATA_RMAT);
		dirArgKeywords.put(NAME_INPUT_DATA_RMAT_SCALE,		OPT_INPUT_DATA_RMAT_SCALE);
		dirArgKeywords.put(NAME_INPUT_DATA_RMAT_EDGEFACTOR,	OPT_INPUT_DATA_RMAT_EDGEFACTOR);
		dirArgKeywords.put(NAME_INPUT_DATA_RMAT_A,			OPT_INPUT_DATA_RMAT_A);
		dirArgKeywords.put(NAME_INPUT_DATA_RMAT_B,			OPT_INPUT_DATA_RMAT_B);
		dirArgKeywords.put(NAME_INPUT_DATA_RMAT_C,			OPT_INPUT_DATA_RMAT_C);

		dirArgKeywords.put(NAME_OUTPUT_FS_OS,		OPT_OUTPUT_FS_OS);
		dirArgKeywords.put(NAME_OUTPUT_FS_HDFS,		OPT_OUTPUT_FS_HDFS);
		dirArgKeywords.put(NAME_OUTPUT_DATA_FILE,	OPT_OUTPUT_DATA_FILE);

		dirArgKeywords.put(NAME_OUTPUT_DATA_FILE_HEADER_SOURCE,	OPT_OUTPUT_DATA_FILE_HEADER_SOURCE);
		dirArgKeywords.put(NAME_OUTPUT_DATA_FILE_HEADER_TARGET,	OPT_OUTPUT_DATA_FILE_HEADER_TARGET);
		dirArgKeywords.put(NAME_OUTPUT_DATA_FILE_HEADER_WEIGHT,	OPT_OUTPUT_DATA_FILE_HEADER_WEIGHT);

		dirArgKeywords.put(NAME_OUTPUT1_FS_OS,		OPT_OUTPUT1_FS_OS);
		dirArgKeywords.put(NAME_OUTPUT1_FS_HDFS,	OPT_OUTPUT1_FS_HDFS);
		dirArgKeywords.put(NAME_OUTPUT1_DATA_FILE,	OPT_OUTPUT1_DATA_FILE);

		dirArgKeywords.put(NAME_OUTPUT2_FS_OS,		OPT_OUTPUT2_FS_OS);
		dirArgKeywords.put(NAME_OUTPUT2_FS_HDFS,	OPT_OUTPUT2_FS_HDFS);
		dirArgKeywords.put(NAME_OUTPUT2_DATA_FILE,	OPT_OUTPUT2_DATA_FILE);

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

		dirArgKeywords.put(NAME_BC_WEIGHTED,		OPT_BC_WEIGHTED);
		dirArgKeywords.put(NAME_BC_DIRECTED,		OPT_BC_DIRECTED);
		dirArgKeywords.put(NAME_BC_SOURCE,			OPT_BC_SOURCE);
		dirArgKeywords.put(NAME_BC_DELTA,			OPT_BC_DELTA);
		dirArgKeywords.put(NAME_BC_NORMALIZE,		OPT_BC_NORMALIZE);
		dirArgKeywords.put(NAME_BC_LINEARSCALE,		OPT_BC_LINEARSCALE);
		dirArgKeywords.put(NAME_BC_EXACTBC,			OPT_BC_EXACTBC);

		dirArgKeywords.put(NAME_HANF_NITER,			OPT_HANF_NITER);
		dirArgKeywords.put(NAME_HANF_B,				OPT_HANF_B);

		dirArgKeywords.put(NAME_SCC_DIRECTED,		OPT_SCC_DIRECTED);
		dirArgKeywords.put(NAME_SCC_NITER,			OPT_SCC_NITER);

		dirArgKeywords.put(NAME_MF_SOURCE_ID,		OPT_MF_SOURCE_ID);
		dirArgKeywords.put(NAME_MF_SINK_ID,			OPT_MF_SINK_ID);
		dirArgKeywords.put(NAME_MF_EPS,				OPT_MF_EPS);
		dirArgKeywords.put(NAME_MF_RECURSIONLIMIT,	OPT_MF_RECURSIONLIMIT);

		dirArgKeywords.put(NAME_SC_NUM_CLUSTER,		OPT_SC_NUM_CLUSTER);
		dirArgKeywords.put(NAME_SC_TOLERANCE,		OPT_SC_TOLERANCE);		
		dirArgKeywords.put(NAME_SC_MAXITER,			OPT_SC_MAXITER);
		dirArgKeywords.put(NAME_SC_THRESHOLD,		OPT_SC_THRESHOLD);
	}

	public def execute(args: Rail[String]) throws ApiException {

		try {
			apiType = dirArgKeywords.getOrThrow(args(0));
		} catch(e :NoSuchElementException) {
			throw new ApiException.InvalidApiNameException(args(0));
		}

		switch (apiType) {
			case API_PASSTHROUGH:
				optInputDataFileWeight = OPT_INPUT_DATA_FILE_WEIGHT_RANDOM;
				break;
			case API_PAGERANK:
				// "weight" is not needed.
				// However, the weight is used in the function createSparseMatrix
				optInputDataFileWeight = OPT_INPUT_DATA_FILE_WEIGHT_CONSTANT;
				valueInputDataFileWeightConstant = 0.0;
				break;
			case API_MINIMUMSPANNINGTREE:
				// This algorithm requires edge weights for the calculation
				// In case the input CSV doesn't have weight column,
				// The algorithm should be throw an Exception.
				// User may change optInputDataFileWeight
				optInputDataFileWeight = OPT_INPUT_DATA_FILE_WEIGHT_CSV;
				break;
			case API_DEGREEDISTRIBUTION:
				// "weight" is not needed.
				// However, the weight is used in the function createSparseMatrix
				optInputDataFileWeight = OPT_INPUT_DATA_FILE_WEIGHT_CONSTANT;
				valueInputDataFileWeightConstant = 0.0;
				break;
			case API_BETWEENNESSCENTRALITY:
				// "weight" is needed when "--bc-weighted=true"
				// "weight" is not needed when "--bc-weighted=false" (this is default)
				// The following assignment assumes "--bc-weighted=false"
				// The default will be overridden on getting "--bc-weighted=true"
				optInputDataFileWeight = OPT_INPUT_DATA_FILE_WEIGHT_CONSTANT;
				valueInputDataFileWeightConstant = 0.0;
				break;
			case API_HYPERANF:
				// "weight" is not needed.
				// However, the weight is used in the function createSparseMatrix
				optInputDataFileWeight = OPT_INPUT_DATA_FILE_WEIGHT_CONSTANT;
				valueInputDataFileWeightConstant = 0.0;
				break;
			case API_STRONGLYCONNECTEDCOMPONENT:
				// "weight" is not needed.
				// However, the weight is used in the function createSparseMatrix
				optInputDataFileWeight = OPT_INPUT_DATA_FILE_WEIGHT_CONSTANT;
				valueInputDataFileWeightConstant = 0.0;
				break;
			case API_MAXFLOW:
				// This algorithm requires edge weights for the calculation
				// In case the input CSV doesn't have weight column,
				// The algorithm should be throw an Exception
				// User may change optInputDataFileWeight
				optInputDataFileWeight = OPT_INPUT_DATA_FILE_WEIGHT_CSV;
				break;
			case API_SPECTRALCLUSTERING:
				// Specification is not fixed yet.
				optInputDataFileWeight = OPT_INPUT_DATA_FILE_WEIGHT_CSV;
				break;
			case API_XPREGEL:
				optInputDataFileWeight = OPT_INPUT_DATA_FILE_WEIGHT_CSV;
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
					case OPT_INPUT_DATA_FILE_HEADER_SOURCE:
						valueInputDataFileHeaderSource = splits(1);
						break;
					case OPT_INPUT_DATA_FILE_HEADER_TARGET:
						valueInputDataFileHeaderTarget = splits(1);
						break;
					case OPT_INPUT_DATA_FILE_HEADER_WEIGHT:
						valueInputDataFileHeaderWeight = splits(1);
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
					case OPT_OUTPUT_DATA_FILE_HEADER_SOURCE:
						valueOutputDataFileHeaderSource = splits(1);
						break;
					case OPT_OUTPUT_DATA_FILE_HEADER_TARGET:
						valueOutputDataFileHeaderTarget = splits(1);
						break;
					case OPT_OUTPUT_DATA_FILE_HEADER_WEIGHT:
						valueOutputDataFileHeaderWeight = splits(1);
						break;

					case OPT_OUTPUT1_FS_OS:
						optOutput1Fs = OPT_OUTPUT1_FS_OS;
						break;
					case OPT_OUTPUT1_FS_HDFS:
						optOutput1Fs = OPT_OUTPUT1_FS_HDFS;
						break;
					case OPT_OUTPUT1_DATA_FILE:
						valueOutput1DataFile = splits(1);
						break;

					case OPT_OUTPUT2_FS_OS:
						optOutput2Fs = OPT_OUTPUT2_FS_OS;
						break;
					case OPT_OUTPUT2_FS_HDFS:
						optOutput2Fs = OPT_OUTPUT2_FS_HDFS;
						break;
					case OPT_OUTPUT2_DATA_FILE:
						valueOutput2DataFile = splits(1);
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

					case OPT_BC_WEIGHTED:
						valueBCWeighted = Boolean.parse(splits(1));
						if (valueBCWeighted) {
							// "weight" default is constant 0.0 when --bc-weighted=false
							// "weight" default is CSV when --bc-weighted=true
							// optInputDataFileWeight is overriden here
							if (optInputDataFileWeight == OPT_INPUT_DATA_FILE_WEIGHT_CONSTANT &&
								valueInputDataFileWeightConstant == 0.0) {
								optInputDataFileWeight = OPT_INPUT_DATA_FILE_WEIGHT_CSV;
							}
						}
						break;
					case OPT_BC_DIRECTED:
						valueBCDirected = Boolean.parse(splits(1));
						break;
					case OPT_BC_SOURCE:
						valueBCSource = Long.parse(splits(1));
						break;
					case OPT_BC_DELTA:
						valueBCDelta = Int.parse(splits(1));
						break;
					case OPT_BC_NORMALIZE:
						valueBCNormalize = Boolean.parse(splits(1));
						break;
					case OPT_BC_LINEARSCALE:
						valueBCLinearScale = Boolean.parse(splits(1));
						break;
					case OPT_BC_EXACTBC:
						valueBCExactBC = Boolean.parse(splits(1));
						break;

					case OPT_HANF_NITER:
						valueHANFNiter = Int.parse(splits(1));
						break;
					case OPT_HANF_B:
						valueHANFB = Int.parse(splits(1));
						break;

					case OPT_SCC_DIRECTED:
						valueSCCDirected = Boolean.parse(splits(1));
						break;
					case OPT_SCC_NITER:
						valueSCCNiter = Int.parse(splits(1));
						break;

					case OPT_MF_SOURCE_ID:
						valueMFSourceId = Long.parse(splits(1));
						break;
					case OPT_MF_SINK_ID:
						valueMFSinkId = Long.parse(splits(1));
						break;
				    case OPT_MF_EPS:
						valueMFEPS = Double.parse(splits(1));
						break;
					case OPT_MF_RECURSIONLIMIT:
						valueMFRecursionLimit = Long.parse(splits(1));
						break;

					case OPT_SC_NUM_CLUSTER:
						valueSCNumCluster = Int.parse(splits(1));
						break;
					case OPT_SC_TOLERANCE:
						valueSCTolerance = Double.parse(splits(1));
						break;
					case OPT_SC_MAXITER:
						valueSCMaxIter = Int.parse(splits(1));
						break;
					case OPT_SC_THRESHOLD:
						valueSCThreshold = Double.parse(splits(1));
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
			case API_MINIMUMSPANNINGTREE:
				callMinimumSpanningTree(makeGraph());
				break;
			case API_DEGREEDISTRIBUTION:
				callDegreeDistribution(makeGraph());
				break;
			case API_BETWEENNESSCENTRALITY:
				callBetweennessCentrality(makeGraph());
				break;
			case API_HYPERANF:
				callHyperANF(makeGraph());
				break;
			case API_STRONGLYCONNECTEDCOMPONENT:
				callStronglyConnectedComponent(makeGraph());
				break;
			case API_MAXFLOW:
				callMaxFlow(makeGraph());
				break;
			case API_SPECTRALCLUSTERING:
				callSpectralClustering(makeGraph());
				break;
			case API_XPREGEL:
				callXpregel(makeGraph());
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
		    case API_MINIMUMSPANNINGTREE:
				if (valueOutputDataFile.length() == 0n) {
					throw new ApiException.OptionRequiredException(NAME_OUTPUT_DATA_FILE);
				}
				assert(valueOutputDataFile.length() > 0n);
				break;
			case API_BETWEENNESSCENTRALITY:
				if (valueOutputDataFile.length() == 0n) {
					throw new ApiException.OptionRequiredException(NAME_OUTPUT_DATA_FILE);
				}
				assert(valueOutputDataFile.length() > 0n);
				break;
			case API_HYPERANF:
				if (valueOutputDataFile.length() == 0n) {
					throw new ApiException.OptionRequiredException(NAME_OUTPUT_DATA_FILE);
				}
				assert(valueOutputDataFile.length() > 0n);
				break;
			case API_STRONGLYCONNECTEDCOMPONENT:
				if (valueOutput1DataFile.length() == 0n) {
					throw new ApiException.OptionRequiredException(NAME_OUTPUT1_DATA_FILE);
				}
				assert(valueOutput1DataFile.length() > 0n);
				if (valueOutput2DataFile.length() == 0n) {
					throw new ApiException.OptionRequiredException(NAME_OUTPUT2_DATA_FILE);
				}
				assert(valueOutput2DataFile.length() > 0n);
				break;
			case API_MAXFLOW:
				if (valueMFSourceId < 0) {
					throw new ApiException.OptionRequiredException(NAME_MF_SOURCE_ID);
				}
				if (valueMFSinkId < 0) {
					throw new ApiException.OptionRequiredException(NAME_MF_SINK_ID);
				}
				if (valueMFSourceId == valueMFSinkId) {
					throw new ApiException.InvalidOptionValueException(NAME_MF_SOURCE_ID + " and " + NAME_MF_SINK_ID);
				}
				break;
			case API_SPECTRALCLUSTERING:
				// Specification is not fixed yet.
				// the following code is temporary
				if (valueOutputDataFile.length() == 0n) {
					throw new ApiException.OptionRequiredException(NAME_OUTPUT_DATA_FILE);
				}
				if (valueSCNumCluster < 2n) {
					throw new ApiException.InvalidOptionValueException(NAME_SC_NUM_CLUSTER);
				}
				if (valueSCTolerance <= 0.0) {
					throw new ApiException.InvalidOptionValueException(NAME_SC_TOLERANCE);
				}
				if (valueSCMaxIter <= 0) {
					throw new ApiException.InvalidOptionValueException(NAME_SC_MAXITER);
				}
				if (valueSCThreshold <= 0.0) {
					throw new ApiException.InvalidOptionValueException(NAME_SC_THRESHOLD);
				}
				break;
			case API_XPREGEL:
				break;
			default:
				break;
		}
	}

	private def makeGraph() :Graph {
		switch (optInputData) {
			case OPT_INPUT_DATA_RMAT:
				return makeGraphFromRmat();
			case OPT_INPUT_DATA_FILE:
			case OPT_INPUT_DATA_FILE_RENUMBERING:
				return makeGraphFromFile();
			default:
				assert(false);
				break;
		}
		return makeGraphFromRmat();
	}

	private def makeGraphFromRmat() {
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

	private def getFilePathOutput1() {
		val filePath :FilePath;
		assert(valueOutput1DataFile.length() > 0);
		switch (optOutput1Fs) {
			case OPT_OUTPUT1_FS_OS:
				filePath = new FilePath(FilePath.FILEPATH_FS_OS, valueOutput1DataFile);
				break;
			case OPT_OUTPUT1_FS_HDFS:
				filePath = new FilePath(FilePath.FILEPATH_FS_HDFS, valueOutput1DataFile);
				break;
			default:
				assert(false);
				filePath = new FilePath(FilePath.FILEPATH_FS_OS, valueOutput1DataFile);
		}
		return filePath;
	}

	private def getFilePathOutput2() {
		val filePath :FilePath;
		assert(valueOutput2DataFile.length() > 0);
		switch (optOutput2Fs) {
			case OPT_OUTPUT2_FS_OS:
				filePath = new FilePath(FilePath.FILEPATH_FS_OS, valueOutput2DataFile);
				break;
			case OPT_OUTPUT2_FS_HDFS:
				filePath = new FilePath(FilePath.FILEPATH_FS_HDFS, valueOutput2DataFile);
				break;
			default:
				assert(false);
				filePath = new FilePath(FilePath.FILEPATH_FS_OS, valueOutput2DataFile);
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

	private def makeGraphFromFile() {
		val colTypes :Rail[Int];
		if (optInputDataFileWeight == OPT_INPUT_DATA_FILE_WEIGHT_CSV) {
			colTypes = [Type.Long as Int, Type.Long, Type.Long, Type.Double];
		} else {
			colTypes = [Type.Long as Int, Type.Long, Type.Long];
		}
		val edgeCSV = CSV.read(getFilePathInput(), colTypes, true);
		val g = Graph.make(edgeCSV, optInputDataFileRenumbering, 
						   valueInputDataFileHeaderSource, valueInputDataFileHeaderTarget);
		val srcList = g.source();
		val getSize = ()=>srcList().size();
		val edgeWeight :DistMemoryChunk[Double];
		switch (optInputDataFileWeight) {
			case OPT_INPUT_DATA_FILE_WEIGHT_CSV:
				Logger.recordLog("header: " + valueInputDataFileHeaderWeight);
				val weightIdx = edgeCSV.nameToIndex(valueInputDataFileHeaderWeight);
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

	public def callPassThrough(graph :Graph) {
		CSV.write(getFilePathOutput(),
				  new NamedDistData([valueOutputDataFileHeaderSource as String,
									 valueOutputDataFileHeaderTarget,
									 valueOutputDataFileHeaderWeight],
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

	public def callMinimumSpanningTree(graph :Graph) {
    	val matrix = graph.createDistSparseMatrix[Double](
    		Config.get().distXPregel(), "weight", false, false);
    	// delete the graph object in order to reduce the memory consumption
    	graph.del();
    	Config.get().stopWatch().lap("Graph construction: ");
    	val result = MinimumSpanningTree.run(matrix);
		CSV.write(getFilePathOutput(), new NamedDistData(["source" as String, "target"], [result.source() as Any, result.target()]), false);
	}

	public def callDegreeDistribution(graph :Graph) {
		var inOutDegResult :DistMemoryChunk[Long];
	    val sw = Config.get().stopWatch();
	    val team = graph.team();
	    val transpose = false;
	    val directed = false;
	    //val distColumn = Dist2D.make1D(team, !transpose ? Dist2D.DISTRIBUTE_COLUMNS : Dist2D.DISTRIBUTE_ROWS);
	    val distRow = Dist2D.make1D(team, Dist2D.DISTRIBUTE_ROWS);
	    val rowDistGraph = graph.createDistEdgeIndexMatrix(distRow, directed, transpose);
	    sw.lap("Graph construction");
	    graph.del();
	    inOutDegResult = DegreeDistribution.run[Long](rowDistGraph);
	    sw.lap("Degree distribution calculation");
	    CSV.write(getFilePathOutput(), new NamedDistData(["inoutdeg" as String], [inOutDegResult as Any]), true);
	}

	public def callBetweennessCentrality(graph :Graph) {
		val bc = new BetweennessCentrality();
		bc.weighted = valueBCWeighted;
		bc.directed = valueBCDirected;
		bc.source = [valueBCSource];
		bc.delta = valueBCDelta;
		bc.normalize = valueBCNormalize;
		bc.linearScale = valueBCLinearScale;
		bc.exactBc = valueBCExactBC;
		var result: DistMemoryChunk[Double];
		if (valueBCWeighted) {
	        val matrix = graph.createDistSparseMatrix[Double](
	            Config.get().distXPregel(),
	            bc.weightAttrName, bc.directed, true); 
			val N = graph.numberOfVertices();
			graph.del();
			val sw = Config.get().stopWatch();
			sw.start();
			result = bc.execute(matrix, N);
			sw.lap("BC elapsed time");
		} else {
	        val matrix = graph.createDistEdgeIndexMatrix(
	            Config.get().distXPregel(),
	            bc.directed,
	            false); 
			val N = graph.numberOfVertices();
			graph.del();
			val sw = Config.get().stopWatch();
			sw.start();
			result = bc.execute(matrix, N);
			sw.lap("BC elapsed time");
		}
	    CSV.write(getFilePathOutput(), new NamedDistData(["bc" as String], [result as Any]), true);
	}

	public def callHyperANF(graph :Graph) {
		val hyperANF = new HyperANF();
		val result :MemoryChunk[Double];

		hyperANF.niter = valueHANFNiter;
		hyperANF.B = valueHANFB;

		val matrix = graph.createDistSparseMatrix[Double](
			Config.get().distXPregel(), "weight", true, false);
		// delete the graph object in order to reduce the memory consumption
		graph.del();
		result = hyperANF.execute(matrix);
		
		val sb = new SStringBuilder();
		for(i in result.range()) {
			sb.add(result(i)).add("\n");
		}
		val fw = new FileWriter(getFilePathOutput(), FileMode.Create);
		fw.write(sb.result().bytes());
		fw.close();
	}

	public def callStronglyConnectedComponent(graph :Graph) {
		val scc = new StronglyConnectedComponent2();
		scc.directed = valueSCCDirected;
		scc.niter = valueSCCNiter;

		// val result = org.scalegraph.api.StronglyConnectedComponent.run(g);
		val result :StronglyConnectedComponent2.Result;
		val matrix = graph.createDistSparseMatrix[Double](Config.get().distXPregel(), "weight", true, false);
		// val matrix = g.createDistEdgeIndexMatrix(Config.get().dist1d(), true, false);

		// delete the graph object in order to reduce the memory consumption
		graph.del();
		result = scc.execute(matrix);
		val dmc1 = result.dmc1;
		val dmc2 = result.dmc2;

		CSV.write(getFilePathOutput1(),
				  new NamedDistData(["sccA" as String], [dmc1 as Any]), true);
		CSV.write(getFilePathOutput2(),
				  new NamedDistData(["sccB" as String], [dmc2 as Any]), true);
	}

	public def callMaxFlow(graph :Graph) {
		val mf = new MaxFlow();
		val result :MaxFlow.Result;

		mf.eps = valueMFEPS;
		mf.recursionLimit = valueMFRecursionLimit;

		val matrix = graph.createDistEdgeIndexMatrix(Config.get().dist1d(), true, true);
		val edgeValue = graph.createDistAttribute[Double](matrix, false, "weight");
		graph.del();
		result = mf.execute(matrix, edgeValue, valueMFSourceId, valueMFSinkId);

		addResult("\"MaxFlow\"", result.maxFlow.toString());
	}

	public def callSpectralClustering(graph :Graph) {
		val sc = new SpectralClustering(valueSCNumCluster,
										valueSCTolerance,
										valueSCMaxIter,
										valueSCThreshold);

		val matrix = graph.createDistSparseMatrix[Double](
			Config.get().distXPregel(), "weight", false, false);
		graph.del();
		val result = sc.execute(matrix);
		CSV.write(getFilePathOutput(), new NamedDistData(["sc_result" as String], [result as Any]), true);
	}

	public def callXpregel(graph :Graph) {
		val pyXPregel = new PyXPregel();

		pyXpregel.test();
	}

}
