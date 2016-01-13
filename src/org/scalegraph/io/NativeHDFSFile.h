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
	template<class TPMGL(T)> x10_long read(TPMGL(T) buffer);
	template<class TPMGL(T)> void write(TPMGL(T) buffer);
	template<class TPMGL(T)> void write(TPMGL(T) buffer, x10_long size_to_write);
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


template<class TPMGL(T)>
x10_long NativeHDFSFile::read(TPMGL(T) b) {
    tSize bytes;
    bytes = hdfsRead(FMGL(fs), FMGL(file), b.pointer(), b.size());
    assert(bytes >= 0);

    return (x10_long)bytes;
}


template<class TPMGL(T)>
void NativeHDFSFile::write(TPMGL(T) b) {
    tSize bytes;
    bytes = hdfsWrite(FMGL(fs), FMGL(file), b.pointer(), b.size());
    assert(bytes >= 0);
    assert((x10_long) bytes == (x10_long) b.size());
}


template<class TPMGL(T)>
void NativeHDFSFile::write(TPMGL(T) b, x10_long size_to_write) {
    tSize bytes;
    bytes = hdfsWrite(FMGL(fs), FMGL(file), b.pointer(), size_to_write);
    assert(bytes >= 0);
    assert((x10_long) bytes == size_to_write);
}


}}} // namespace org { namespace scalegraph { namespace io {

#endif // __ORG_SCALEGRAPH_IO_NATIVEHDFSFILE_H

