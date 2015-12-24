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

#ifndef __ORG_SCALEGRAPH_PYTHON_NATIVEPYTHON_H
#define __ORG_SCALEGRAPH_PYTHON_NATIVEPYTHON_H

#include <x10rt.h>

#define X10_LANG_STRING_H_NODEPS
#include <x10/lang/String.h>
#undef X10_LANG_STRING_H_NODEPS

#define X10_LANG_RAIL_H_NODEPS
#include <x10/lang/Rail.h>
#undef X10_LANG_RAIL_H_NODEPS

#define X10_UTIL_HASHMAP_H_NODEPS
#include <x10/util/HashMap.h>
#undef X10_UTIL_HASHMAP_H_NODEPS

#define ORG_SCALEGRAPH_PYTHON_NATIVEPYOBJECT_H_NODEPS
#include <org/scalegraph/python/NativePyObject.h>
#undef ORG_SCALEGRAPH_PYTHON_NATIVEPYOBJECT_H_NODEPS


namespace org { namespace scalegraph { namespace python {

class NativePython : public ::x10::lang::X10Class {
  public:
    RTT_H_DECLS_CLASS;

    static NativePython* _make();
    void _constructor();

    void finalize();
    void osAfterFork();
    NativePyObject* importImport(::x10::lang::String* name);
    NativePyObject* importAddModule(::x10::lang::String* name);
    NativePyObject* moduleGetDict(NativePyObject* module);
    NativePyObject* dictNew();
    x10_int dictSetItemString(NativePyObject* dict, ::x10::lang::String* key, NativePyObject* value);
    NativePyObject* dictGetItemString(NativePyObject* dict, ::x10::lang::String* key);
    NativePyObject* dictFromHashMap(NativePyObject* dict, ::x10::util::HashMap< ::x10::lang::String*, NativePyObject* >* hashmap);
    ::x10::util::HashMap< ::x10::lang::String*, NativePyObject* >* dictAsHashMap(NativePyObject* dict);
    NativePyObject* dictImportHashMap(NativePyObject* dict, ::x10::util::HashMap< ::x10::lang::String*, NativePyObject* >* hashmap);
    NativePyObject* listNew();
    NativePyObject* listFromRail(::x10::lang::Rail<NativePyObject* >* rail);
    ::x10::lang::Rail<NativePyObject* >* listAsRail(NativePyObject* list);
    NativePyObject* tupleNew();
    NativePyObject* tupleFromRail(::x10::lang::Rail<NativePyObject* >* rail);
    ::x10::lang::Rail<NativePyObject* >* tupleAsRail(NativePyObject* tuple);
    NativePyObject* unicodeFromString(::x10::lang::String* str);
    ::x10::lang::String* unicodeAsASCIIString(NativePyObject* obj);
    NativePyObject* longFromLong(x10_long value);
    x10_long longAsLong(NativePyObject* obj);
    x10_int runSimpleString(::x10::lang::String* command);
    NativePyObject* runString(::x10::lang::String* command, NativePyObject* global, NativePyObject* local);
    NativePyObject* callObject(NativePyObject* callable, ::x10::lang::Rail<NativePyObject* > *args);
    ::x10::lang::String* objectStr(NativePyObject* obj);

    void test();
    void calltest(::org::scalegraph::python::NativePyObject* module);
    
	// Serialization
    /*

    static void _serialize(NativePython* this_, x10aux::serialization_buffer& buf) {
		assert (false);
	}
	static NativePython* _deserializer(x10aux::deserialization_buffer& buf) {
		assert (false);
	}
    */

    virtual void __fieldInitializers_NativePython();
    
    // Serialization
    public: static const ::x10aux::serialization_id_t _serialization_id;
    
    public: virtual ::x10aux::serialization_id_t _get_serialization_id() {
         return _serialization_id;
    }
    
    public: virtual void _serialize_body(::x10aux::serialization_buffer& buf);
    
    public: static ::x10::lang::Reference* _deserializer(::x10aux::deserialization_buffer& buf);
    
    public: void _deserialize_body(::x10aux::deserialization_buffer& buf);
};
            
}}} // namespace org { namespace scalegraph { namespace python {

#endif // __ORG_SCALEGRAPH_PYTHON_NATIVEPYTHON_H
