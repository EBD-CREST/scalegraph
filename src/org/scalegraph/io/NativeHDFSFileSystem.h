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

#ifndef __ORG_SCALEGRAPH_IO_NATIVEHDFSFILESYSTEM_H
#define __ORG_SCALEGRAPH_IO_NATIVEHDFSFILESYSTEM_H

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

struct NativeHDFSFileSystem {
protected:
    hdfsBuilder*    FMGL(builder);
    hdfsFS          FMGL(fs);
    hdfsFile        FMGL(file);
    bool            fileInfoIsFile;
    bool            fileInfoIsDirectory;
    bool            fileInfoExists;
    x10_long        fileInfoFileSize;
    
public:
	RTT_H_DECLS_CLASS;

    //	explicit NativeHDFSFile(int fd_) : FMGL(fd)(fd_) { }
    //	NativeHDFSFile() : FMGL(fd)(-1) { }
    NativeHDFSFileSystem() {}
        
    static  NativeHDFSFileSystem _make( ::x10::lang::String* name);
    void _constructor( ::x10::lang::String* name);

	NativeHDFSFileSystem* operator->() { return this; }

    x10_boolean isFile();
    x10_boolean isDirectory();
    x10_boolean exists();
    void _kwd__delete();
    void mkdirs();
    x10_long size();
     ::x10::lang::Rail<  ::x10::lang::String* >* list();

    /*
     ::x10::lang::String* typeName();
     ::x10::lang::String* toString();
    x10_int hashCode();
    x10_boolean equals( ::x10::lang::Any* other);
    x10_boolean equals( ::org::scalegraph::io::NativeOSFileSystem other) {
        return (::x10aux::struct_equals((*this)->FMGL(file), other->FMGL(file)));
        
    }
    x10_boolean _struct_equals( ::x10::lang::Any* other);
    x10_boolean _struct_equals( ::org::scalegraph::io::NativeOSFileSystem other) {
        return (::x10aux::struct_equals((*this)->FMGL(file), other->FMGL(file)));
        
    }
    */

	// Serialization
	static void _serialize(NativeHDFSFileSystem this_, x10aux::serialization_buffer& buf) {
		assert (false);
	}
	static NativeHDFSFileSystem _deserializer(x10aux::deserialization_buffer& buf) {
		assert (false);
	}
};

}}} // namespace org { namespace scalegraph { namespace io {

#endif // __ORG_SCALEGRAPH_IO_NATIVEHDFSFILESYSTEM_H

