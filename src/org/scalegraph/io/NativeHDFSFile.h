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

#ifndef __ORG_SCALEGRAPH_IO_NATIVEHDFSFILE_H
#define __ORG_SCALEGRAPH_IO_NATIVEHDFSFILE_H

#include <hdfs.h>
#include <x10rt.h>


#define X10_LANG_STRING_H_NODEPS
#include <x10/lang/String.h>
#undef X10_LANG_STRING_H_NODEPS
#define ORG_SCALEGRAPH_UTIL_SSTRING_H_NODEPS
#include <org/scalegraph/util/SString.h>
#undef ORG_SCALEGRAPH_UTIL_SSTRING_H_NODEPS
#define ORG_SCALEGRAPH_UTIL_MEMORYCHUNK_H_NODEPS
#include <org/scalegraph/util/MemoryChunk.h>
#undef ORG_SCALEGRAPH_UTIL_MEMORYCHUNK_H_NODEPS


namespace org { namespace scalegraph { namespace io {

struct NativeHDFSFile {
protected:
    hdfsBuilder*    FMGL(builder);
    hdfsFS          FMGL(fs);
    hdfsFile        FMGL(file);
    int             FMGL(flags);
    
public:
	RTT_H_DECLS_CLASS;

    //	explicit NativeHDFSFile(int fd_) : FMGL(fd)(fd_) { }
    //	NativeHDFSFile() : FMGL(fd)(-1) { }
    NativeHDFSFile() {}
        
	static NativeHDFSFile _make(org::scalegraph::util::SString name, int  fileMode, int fileAccess);
	void _constructor (org::scalegraph::util::SString name, int  fileMode, int fileAccess);

	NativeHDFSFile* operator->() { return this; }

	void close();
	x10_long read(org::scalegraph::util::MemoryChunk<x10_byte> b);
	void write(org::scalegraph::util::MemoryChunk<x10_byte> b);
	void seek(x10_long offset, int origin);
	x10_long getpos();
    void flush();
    
	// Serialization
	static void _serialize(NativeHDFSFile this_, x10aux::serialization_buffer& buf) {
		assert (false);
	}
	static NativeHDFSFile _deserializer(x10aux::deserialization_buffer& buf) {
		assert (false);
	}
};

}}} // namespace org { namespace scalegraph { namespace io {

#endif // __ORG_SCALEGRAPH_IO_NATIVEHDFSFILE_H

