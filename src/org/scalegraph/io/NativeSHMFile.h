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

#ifndef __ORG_SCALEGRAPH_IO_NATIVESHMFILE_H
#define __ORG_SCALEGRAPH_IO_NATIVESHMFILE_H

#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <x10rt.h>

#define X10_LANG_STRING_H_NODEPS
#include <x10/lang/String.h>
#undef X10_LANG_STRING_H_NODEPS

#define X10_IO_IOEXCEPTION_H_NODEPS
#include <x10/io/IOException.h>
#undef X10_IO_IOEXCEPTION_H_NODEPS

#define ORG_SCALEGRAPH_UTIL_SSTRING_H_NODEPS
#include <org/scalegraph/util/SString.h>
#undef ORG_SCALEGRAPH_UTIL_SSTRING_H_NODEPS

#define ORG_SCALEGRAPH_UTIL_MEMORYCHUNK_H_NODEPS
#include <org/scalegraph/util/MemoryChunk.h>
#undef ORG_SCALEGRAPH_UTIL_MEMORYCHUNK_H_NODEPS


namespace org { namespace scalegraph { namespace io {

struct NativeSHMFile {
protected:
	int FMGL(fd);

public:
	RTT_H_DECLS_CLASS;

	NativeSHMFile() : FMGL(fd)(-1) { }

	static NativeSHMFile _make(org::scalegraph::util::SString name, int  fileMode, int fileAccess);
	void _constructor (org::scalegraph::util::SString name, int  fileMode, int fileAccess);

	NativeSHMFile* operator->() { return this; }

	void close();
    void flush();
	template<class TPMGL(T)> void copyToShmem(TPMGL(T) buffer);
	template<class TPMGL(T)> void copyToShmem(TPMGL(T) buffer, x10_long size_to_write);
	template<class TPMGL(T)> void copyFromShmem(TPMGL(T) buffer);
	template<class TPMGL(T)> void copyFromShmem(TPMGL(T) buffer, x10_long size_to_read);
    static void unlink(::x10::lang::String* name);

    
	// Serialization
	static void _serialize(NativeSHMFile this_, x10aux::serialization_buffer& buf) {
		assert (false);
	}
	static NativeSHMFile _deserializer(x10aux::deserialization_buffer& buf) {
		assert (false);
	}
};


template<class TPMGL(T)>
void NativeSHMFile::copyToShmem(TPMGL(T) b) {
    size_t len = b.size();
    void* copy_from = b.pointer();
    ftruncate(FMGL(fd), len);
    void* shared_memory = ::mmap(NULL, len, PROT_READ|PROT_WRITE, MAP_SHARED, FMGL(fd), 0);
    memcpy(shared_memory, copy_from, len);
    //msync(shared_memory, len, MS_SYNC);
    //munmap(shared_memory, len);
}


template<class TPMGL(T)>
void NativeSHMFile::copyToShmem(TPMGL(T) b, x10_long size_to_write) {
    size_t len = size_to_write;
    void* copy_from = b.pointer();
    ftruncate(FMGL(fd), len);
    void* shared_memory = ::mmap(NULL, len, PROT_READ|PROT_WRITE, MAP_SHARED, FMGL(fd), 0);
    memcpy(shared_memory, copy_from, len);
    //msync(shared_memory, len, MS_SYNC);
    //munmap(shared_memory, len);
}


template<class TPMGL(T)>
void NativeSHMFile::copyFromShmem(TPMGL(T) b) {
    size_t len = b.size();
    void* copy_to = b.pointer();
    //ftruncate(FMGL(fd), len);
    void* shared_memory = ::mmap(NULL, len, PROT_READ|PROT_WRITE, MAP_SHARED, FMGL(fd), 0);
    memcpy(copy_to, shared_memory, len);
    //msync(shared_memory, len, MS_SYNC);
    //munmap(shared_memory, len);
}


template<class TPMGL(T)>
void NativeSHMFile::copyFromShmem(TPMGL(T) b, x10_long size_to_write) {
    size_t len = size_to_write;
    void* copy_to = b.pointer();
    //ftruncate(FMGL(fd), len);
    void* shared_memory = ::mmap(NULL, len, PROT_READ|PROT_WRITE, MAP_SHARED, FMGL(fd), 0);
    memcpy(copy_to, shared_memory, len);
    //msync(shared_memory, len, MS_SYNC);
    //munmap(shared_memory, len);
}


}}} // namespace org { namespace scalegraph { namespace io {

#endif // __ORG_SCALEGRAPH_IO_NATIVESHMFILE_H

