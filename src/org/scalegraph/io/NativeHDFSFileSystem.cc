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

#include <org/scalegraph/io/NativeHDFSFileSystem.h>

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

NativeHDFSFileSystem NativeHDFSFileSystem::_make(::x10::lang::String* name) {
	NativeHDFSFileSystem ret;
	ret._constructor(name);
	return ret;
}

void NativeHDFSFileSystem::_constructor(::x10::lang::String* name) {
    FMGL(builder) = hdfsNewBuilder();
    assert(FMGL(builder) != NULL);
    hdfsBuilderSetNameNode(FMGL(builder), "default");
    FMGL(fs) = hdfsBuilderConnect(FMGL(builder));
    assert(FMGL(fs) != NULL);
    
    hdfsFileInfo* fileInfo;
    fileInfo = hdfsGetPathInfo(FMGL(fs), name->c_str());
    if (fileInfo == NULL) {
        fileInfoIsFile = false;
        fileInfoIsDirectory = false;
        fileInfoExists = false;
        fileInfoFileSize = (x10_long) -1;
    } else {
        if (fileInfo->mKind == kObjectKindFile) {
            fileInfoIsFile = true;
            fileInfoIsDirectory = false;
        } else {
            fileInfoIsFile = false;
            fileInfoIsDirectory = true;
        }
        fileInfoExists = true;
        fileInfoFileSize = (x10_long) fileInfo->mSize;
        hdfsFreeFileInfo(fileInfo, 1);
    }
}

x10_boolean isFile() {
    return fileInfoIsFile;
}

x10_boolean isDirectory() {
    return fileInfoIsDirectory;
}

x10_boolean exists() {
    return fileInfoExists;
}

void _kwd__delete() {
    // do nothing
}

void mkdirs() {
    // do nothing
}

x10_long size() {
    return fileInfoSize;
}

::x10::lang::Rail<::x10::lang::String* >* list() {
    return ::x10::lang::Rail<::x10::lang::String* >::_make();
}


RTT_CC_DECLS0(NativeHDFSFile, "org.scalegraph.io.NativeHDFSFileSystem", x10aux::RuntimeType::class_kind)

}}} // namespace org { namespace scalegraph { namespace io {
