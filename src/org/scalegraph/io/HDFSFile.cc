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

#include <org/scalegraph/io/HDFSFile.h>

#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

namespace org { namespace scalegraph { namespace io {

using namespace ::x10::lang;
using ::x10::io::FileNotFoundException;
using ::x10::io::IOException;
using ::x10::lang::IllegalArgumentException;

HDFSFile HDFSFile::_make(org::scalegraph::util::SString name, int  fileMode, int fileAccess) {
	HDFSFile ret;
	ret._constructor(name, fileMode, fileAccess);
	return ret;
}

void HDFSFile::_constructor (org::scalegraph::util::SString name, int  fileMode, int fileAccess) {
    FMGL(builder) = hdfsNewBuilder();
    assert(FMGL(builder) != NULL);
    hdfsBuilderSetNameNode(FMGL(builder), "default");
    FMGL(fs) = hdfsBuilderConnect(FMGL(builder));
    assert(FMGL(fs) != NULL);
    
    FMGL(flags) = 0;
	switch(fileAccess) {
	case 0: // Read
		FMGL(flags) |= O_RDONLY;
		break;
	case 1: // Write
		FMGL(flags) |= O_WRONLY;
		break;
	case 2: // ReadWrite
		FMGL(flags) |= O_RDWR;
		break;;
	default:
		x10aux::throwException(IllegalArgumentException::_make(String::Lit("FileAccess is out of range.")));
	}
	switch(fileMode) {
	case 0: // Append
		FMGL(flags) |= O_APPEND | O_CREAT;
		break;
	case 1: // Create
		FMGL(flags) |= O_CREAT | O_TRUNC;
		break;
	case 2: // CreateNew
		FMGL(flags) |= O_CREAT | O_EXCL;
		break;
	case 3: // Open
		FMGL(flags) |= 0;
		break;
	case 4: // OpenOrCreate
		FMGL(flags) |= O_CREAT;
		break;
	case 5: // Truncate
		FMGL(flags) |= O_TRUNC;
		break;
	default:
		x10aux::throwException(IllegalArgumentException::_make(String::Lit("FileMode is out of range.")));
	}

#if 0
    /** 
     * hdfsOpenFile - Open a hdfs file in given mode.
     * @param fs The configured filesystem handle.
     * @param path The full path to the file.
     * @param flags - an | of bits/fcntl.h file flags - supported flags are O_RDONLY, O_WRONLY (meaning create or overwrite i.e., implies O_TRUNCAT), 
     * O_WRONLY|O_APPEND. Other flags are generally ignored other than (O_RDWR || (O_EXCL & O_CREAT)) which return NULL and set errno equal ENOTSUP.
     * @param bufferSize Size of buffer for read/write - pass 0 if you want
     * to use the default configured values.
     * @param replication Block replication - pass 0 if you want to use
     * the default configured values.
     * @param blocksize Size of block - pass 0 if you want to use the
     * default configured values.
     * @return Returns the handle to the open file or NULL on error.
     */
    LIBHDFS_EXTERNAL
    hdfsFile hdfsOpenFile(hdfsFS fs, const char* path, int flags,
                          int bufferSize, short replication, tSize blocksize);
#endif    

    FMGL(file) = hdfsOpenFile(FMGL(fs), 
                              (char*)name->c_str(), FMGL(flags),
                              0, 0, 0);
    if (FMGL(file) == NULL) {
		x10aux::throwException(FileNotFoundException::_make(String::__plus(name->toString(), x10aux::makeStringLit(" couldn't be opened"))));
    }
    
#if 0
    FMGL(fd) = ::open((char*)name->c_str(), flags, 0666);
	if (FMGL(fd) == -1)
		x10aux::throwException(FileNotFoundException::_make(String::__plus(
				String::__plus(name->toString(), x10aux::makeStringLit(" -> ERRNO: ")), (x10_int)errno)));
#endif
}

void HDFSFile::close() {
    int ret;
    ret = hdfsCloseFile(FMGL(fs), FMGL(file));
    assert(ret == 0);
}

x10_long HDFSFile::read(org::scalegraph::util::MemoryChunk<x10_byte> b) {
    tSize bytes;
    bytes = hdfsRead(FMGL(fs), FMGL(file), b.pointer(), b.size());
    assert(bytes >= 0);

    return (x10_long)bytes;
    
    /*
    int readBytes = ::read(FMGL(fd), b.pointer(), b.size());
	if(readBytes == -1)
		x10aux::throwException(IOException::_make(String::Lit("read error")));
	return readBytes;
    */
}

void HDFSFile::write(org::scalegraph::util::MemoryChunk<x10_byte> b) {
    tSize bytes;
    bytes = hdfsWrite(FMGL(fs), FMGL(file), b.pointer(), b.size());
    assert(bytes >= 0);
    assert(bytes == b.size());
    
    /*
    int writeBytes = ::write(FMGL(fd), b.pointer(), b.size());
	if(writeBytes != b.size())
		x10aux::throwException(IOException::_make(String::Lit("write error")));
    */
}

void HDFSFile::seek(x10_long offset, int origin) {
	if(origin < 0 || origin > 2)
		x10aux::throwException(FileNotFoundException::_make());
	int map[] = {SEEK_SET, SEEK_CUR, SEEK_END};

    assert(FMGL(flags) & O_RDONLY);
    tOffset offsetFromBegin;
    switch (map[origin]) {
        case SEEK_SET:
            offsetFromBegin = offset;
            break;
        case SEEK_CUR:
            offsetFromBegin = hdfsTell(FMGL(fs), FMGL(file));
            assert(offsetFromBegin >= 0);
            offsetFromBegin += offset;
            break;
        default:
            // SEEK_END is not supported now
            assert(false);
    }
    int ret;
    ret = hdfsSeek(FMGL(fs), FMGL(file), offsetFromBegin);
    if (ret != 0) {
		x10aux::throwException(IOException::_make(String::Lit("hdfsSeek error")));
    }
    
    /*
    if(::lseek(FMGL(fd), offset, map[origin]) == -1)
		x10aux::throwException(IOException::_make(String::Lit("seek error")));
    */
        
}

x10_long HDFSFile::getpos() {
    tOffset offset;
    offset = hdfsTell(FMGL(fs), FMGL(file));
    if (offset == -1) {
		x10aux::throwException(IOException::_make(String::Lit("hdfsTell error")));
    }
    return offset;
    
    /*
    x10_long pos = ::lseek(FMGL(fd), 0, SEEK_CUR);
	if(pos == -1)
		x10aux::throwException(IOException::_make(String::Lit("seek error")));
    */
}

RTT_CC_DECLS0(HDFSFile, "org.scalegraph.io.HDFSFile", x10aux::RuntimeType::class_kind)

}}} // namespace org { namespace scalegraph { namespace io {
