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

#ifndef __ORG_SCALEGRAPH_IO_NATIVEOSFILE_H
#define __ORG_SCALEGRAPH_IO_NATIVEOSFILE_H

#include <unistd.h>
#include <stdio.h>
#include <string.h>
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

struct NativeOSFile {
protected:
	int FMGL(fd);

public:
	RTT_H_DECLS_CLASS;

	explicit NativeOSFile(int fd_) : FMGL(fd)(fd_) { }
	NativeOSFile() : FMGL(fd)(-1) { }

	static NativeOSFile _make(int fd);
	static NativeOSFile _make(org::scalegraph::util::SString name, int  fileMode, int fileAccess);
	void _constructor (org::scalegraph::util::SString name, int  fileMode, int fileAccess);

	NativeOSFile* operator->() { return this; }

	int handle() { return FMGL(fd); }

	void close();
	template<class TPMGL(T)> x10_long read(TPMGL(T) buffer);
	template<class TPMGL(T)> void write(TPMGL(T) buffer);
	template<class TPMGL(T)> void write(TPMGL(T) buffer, x10_long size_to_write);
	void seek(x10_long offset, int origin);
	x10_long getpos();
    void flush();
    x10_int getFd() { return (x10_int) FMGL(fd); }
    
	// Serialization
	static void _serialize(NativeOSFile this_, x10aux::serialization_buffer& buf) {
		assert (false);
	}
	static NativeOSFile _deserializer(x10aux::deserialization_buffer& buf) {
		assert (false);
	}
};


template<class TPMGL(T)>
x10_long NativeOSFile::read(TPMGL(T) b) {
	int readBytes = ::read(FMGL(fd), b.pointer(), b.size());
	if((x10_long) readBytes < 0)
		x10aux::throwException(::x10::io::IOException::_make(::x10::lang::String::Lit("read error")));
	return readBytes;
}


template<class TPMGL(T)>
void NativeOSFile::write(TPMGL(T) b) {

    /* char* msgbuf = new char[128]; */
    /* if (FMGL(fd) > 2) { */
    /*     snprintf(msgbuf, sizeof(msgbuf), ">>> try to write %lld bytes\n", (long long)b.size()); */
    /*     ::write(2, msgbuf, strlen(msgbuf)); */
    /* } */
        
    int writeBytes = ::write(FMGL(fd), b.pointer(), b.size());
	if((x10_long) writeBytes != (x10_long) b.size())
		x10aux::throwException(::x10::io::IOException::_make(::x10::lang::String::Lit("write error")));

    /* if (FMGL(fd) > 2) { */
    /*     snprintf(msgbuf, sizeof(msgbuf), ">>> write ok %lld bytes\n", (long long)b.size()); */
    /*     ::write(2, msgbuf, strlen(msgbuf)); */
    /* } */
}


template<class TPMGL(T)>
void NativeOSFile::write(TPMGL(T) b, x10_long size_to_write) {
	int writeBytes = ::write(FMGL(fd), b.pointer(), (size_t) size_to_write);
	if((x10_long) writeBytes != size_to_write)
		x10aux::throwException(::x10::io::IOException::_make(::x10::lang::String::Lit("write error")));
}


}}} // namespace org { namespace scalegraph { namespace io {

#endif // __ORG_SCALEGRAPH_IO_NATIVEOSFILE_H

