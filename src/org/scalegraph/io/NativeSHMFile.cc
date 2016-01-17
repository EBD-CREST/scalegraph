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
#include <x10aux/config.h>

#include <x10/lang/String.h>
#include <x10/io/FileNotFoundException.h>
#include <x10/io/IOException.h>
#include <x10/lang/IllegalArgumentException.h>

#include <org/scalegraph/util/SString.h>
#include <org/scalegraph/util/MemoryChunk.h>

#include <org/scalegraph/io/NativeSHMFile.h>

#include <unistd.h>
//#include <sys/types.h>
//#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <errno.h>

namespace org { namespace scalegraph { namespace io {

using namespace ::x10::lang;
using ::x10::io::FileNotFoundException;
using ::x10::io::IOException;
using ::x10::lang::IllegalArgumentException;


NativeSHMFile NativeSHMFile::_make(org::scalegraph::util::SString name, int  fileMode, int fileAccess) {
	NativeSHMFile ret;
	ret._constructor(name, fileMode, fileAccess);
	return ret;
}

void NativeSHMFile::_constructor (org::scalegraph::util::SString name, int  fileMode, int fileAccess) {
	int flags = 0;
	switch(fileAccess) {
	case 0: // Read
		flags |= O_RDONLY;
		break;
	case 1: // Write
		flags |= O_RDWR;
		break;
	case 2: // ReadWrite
		flags |= O_RDWR;
		break;;
	default:
		x10aux::throwException(IllegalArgumentException::_make(String::Lit("FileAccess is out of range.")));
	}
	switch(fileMode) {
	case 0: // Append
		flags |= O_CREAT;
		break;
	case 1: // Create
		flags |= O_CREAT;
		break;
	case 2: // CreateNew
		flags |= O_CREAT | O_TRUNC;
		break;
	case 3: // Open
		flags |= 0;
		break;
	case 4: // OpenOrCreate
		flags |= O_CREAT;
		break;
	case 5: // Truncate
		flags |= O_TRUNC;
		break;
	default:
		x10aux::throwException(IllegalArgumentException::_make(String::Lit("FileMode is out of range.")));
	}
	FMGL(fd) = ::shm_open((char*)name->c_str(), flags, 0666);
	if (FMGL(fd) == -1)
		x10aux::throwException(FileNotFoundException::_make(String::__plus(
				String::__plus(name->toString(), x10aux::makeStringLit(" -> ERRNO: ")), (x10_int)errno)));
}

void NativeSHMFile::close() {
	if(FMGL(fd) != -1) {
		::close(FMGL(fd));
		FMGL(fd) = -1;
	}
}

void NativeSHMFile::flush() {
}

void NativeSHMFile::unlink(::x10::lang::String* name) {
    ::shm_unlink(name->c_str());
}

RTT_CC_DECLS0(NativeSHMFile, "org.scalegraph.io.NativeSHMFile", x10aux::RuntimeType::class_kind)

}}} // namespace org { namespace scalegraph { namespace io {
