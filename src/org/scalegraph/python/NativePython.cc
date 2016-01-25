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

#include <Python.h>

#include <x10aux/config.h>
#include <x10/lang/String.h>
#include <x10/lang/Rail.h>
#include <x10/lang/Byte.h>
#include <org/scalegraph/util/MemoryChunk.h>
#include <org/scalegraph/python/NativePython.h>
#include <org/scalegraph/python/NativePyObject.h>
#include <org/scalegraph/python/NativePyException.h>

namespace org { namespace scalegraph { namespace python {

void NativePython::initialize() {
    Py_Initialize();
}

void NativePython::finalize() {
    Py_Finalize();
}

void NativePython::osAfterFork() {
    PyOS_AfterFork();
}

void NativePython::sysPathAppend(::x10::lang::String* path) {
    const char* spath = path->c_str();
    const char* sformat = "import sys\nsys.path.append('%s')\n";
    int len_spath = strlen(spath);
    int len_sformat = strlen(sformat);
    int len_sbuff = len_spath + len_sformat;
    char* sbuff = new char[len_sbuff +  1];
    snprintf(sbuff, len_sbuff, sformat, spath);
    PyRun_SimpleString(sbuff);
    delete sbuff;
}

// Return value: New reference.
NativePyObject NativePython::importImport(::x10::lang::String* name) {
    PyObject *pName;
    PyObject *pModule;

    pName = PyUnicode_FromString(name->c_str());
    /* Error checking of pName left out */

    pModule = PyImport_Import(pName);
    Py_XDECREF(pName);

    if (pModule == NULL) {
        //PyErr_Print();
        //fprintf(stderr, "Failed to load \"%s\"\n", name->c_str());
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }

    return NativePyObject::_make(pModule);
}

// Return value: Borrowed reference.
NativePyObject NativePython::importAddModule(::x10::lang::String* name) {
    PyObject *pModule;

    pModule = PyImport_AddModule(name->c_str());
    if (pModule == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }

    return NativePyObject::_make(pModule);
}

// Return value: Borrowed reference.
NativePyObject NativePython::moduleGetDict(NativePyObject module) {
    PyObject *pObj;
    PyObject *pDict;

    if (module == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::moduleGetDict, bad NativePyObject")));
        return NULL;
    }

    pObj = module->getPyObject();
    if (pObj == NULL || !PyModule_Check(pObj)) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::moduleGetDict, bad PyObject")));
        return NULL;
    }

    pDict = PyModule_GetDict(pObj);

    return NativePyObject::_make(pDict);
}

// Return value: New reference.
NativePyObject NativePython::dictNew() {
    PyObject *pObj;
    pObj = PyDict_New();
    if (pObj == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }
    return NativePyObject::_make(pObj);
}

x10_int NativePython::dictSetItemString(NativePyObject dict, ::x10::lang::String* key, NativePyObject value) {
    int ret;
    PyObject *pDict;
    PyObject *pValue;

    if (dict == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::dictSetItemString, bad NativePyObject for dict")));
        return -1;
    }

    pDict = dict->getPyObject();
    if (pDict == NULL || !PyDict_Check(pDict)) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::dictSetItemString, bad PyObject for dict")));
        return -1;
    }

    if (value == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::dictSetItemString, bad NativePyObject for value")));
        return -1;
    }

    pValue = value->getPyObject();
    if (pValue == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::dictSetItemString, bad PyObject for value")));
        return -1;
    }

    ret = PyDict_SetItemString(pDict, key->c_str(), pValue);
    if (ret != 0) {
        // This function does not raise an exception
        // ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return ret;
    }
    return ret; // return 0 on success, -1 on failure
}

// Return value: Borrowed reference.
NativePyObject NativePython::dictGetItemString(NativePyObject dict, ::x10::lang::String* key) {
    PyObject *pObj;
    PyObject *pDict;

    if (dict == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::dictGetItemString, bad NativePyObject")));
        return NULL;
    }

    pDict = dict->getPyObject();
    if (pDict == NULL || !PyDict_Check(pDict)) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::dictGetItemString, bad PyObject")));
        return NULL;
    }

    pObj = PyDict_GetItemString(pDict, key->c_str());
    if (pObj == NULL) {
        // This function does not raise an exception
        // ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }
    return NativePyObject::_make(pObj);
}

NativePyObject NativePython::dictFromHashMap(NativePyObject dict, ::x10::util::HashMap< ::x10::lang::String*, NativePyObject >* hashmap) {
    assert(false);
    return NULL;
}

::x10::util::HashMap< ::x10::lang::String*, NativePyObject >* NativePython::dictAsHashMap(NativePyObject dict) {
    assert(false);
    return NULL;
}

NativePyObject NativePython::dictImportHashMap(NativePyObject dict, ::x10::util::HashMap< ::x10::lang::String*, NativePyObject >* hashmap) {
    assert(false);
    return NULL;
}

// Return value: New reference.
NativePyObject NativePython::listNew(x10_long size) {
    PyObject* pLongSize;
    pLongSize = PyLong_FromLong((long) size);
    if (pLongSize == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }
    Py_ssize_t sSizeSize;
    sSizeSize = PyLong_AsSsize_t(pLongSize);
    Py_DECREF(pLongSize);
    if (PyErr_Occurred()) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }
    PyObject* ret;
    ret = PyList_New(sSizeSize);
    if (PyErr_Occurred()) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }
    return ret;
}

// Return value: New reference.
// Reference of each element of the return List is stealed.
NativePyObject NativePython::listFromRail(::x10::lang::Rail<NativePyObject >* rail) {
    PyObject* ret;
    x10_long size = (x10_long)(::x10aux::nullCheck(rail)->FMGL(size));
    ret = PyList_New((Py_ssize_t)size);
    if (PyErr_Occurred()) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }
    for (x10_long i = 0; i < size; i++) {
        NativePyObject nitem;
        nitem = ::x10aux::nullCheck(rail)->x10::lang::Rail<NativePyObject>::__apply(i);
        if (nitem == NULL) {
            ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::listFromRail, bad PyObject on the Rail")));
            return NULL;
        }
        PyList_SetItem(ret, (Py_ssize_t)i, nitem.getPyObject());
        if (PyErr_Occurred()) {
            ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
            return NULL;
        }
    }
    return ret;
}

// Each element of the return rail: Borrowed reference
::x10::lang::Rail<NativePyObject >* NativePython::listAsRail(NativePyObject list) {
    if (list == NULL ||
        !PyList_Check(list.getPyObject())) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::listAsRail, bad PyObject argument")));
        return NULL;
    }

    PyObject* pList = list.getPyObject();
    Py_ssize_t size = PyList_Size(pList);
    ::x10::lang::Rail<NativePyObject>* ret =  ::x10::lang::Rail<NativePyObject>::_make((x10_long)size);

    for (x10_long i = 0; i < (x10_long)size; i++) {
        PyObject* item = PyList_GetItem(pList, (Py_ssize_t)i);
        NativePyObject nitem = item;
        ::x10aux::nullCheck(ret)->x10::lang::Rail<NativePyObject>::__set(i, nitem);
    }
    
    return ret;
}

// Return value: New reference.
NativePyObject NativePython::tupleNew(x10_long size) {
    PyObject* pLongSize;
    pLongSize = PyLong_FromLong((long) size);
    if (pLongSize == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }
    Py_ssize_t sSizeSize;
    sSizeSize = PyLong_AsSsize_t(pLongSize);
    Py_DECREF(pLongSize);
    if (PyErr_Occurred()) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }
    PyObject* ret;
    ret = PyTuple_New(sSizeSize);
    if (PyErr_Occurred()) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }
    return ret;
}

// Return value: New reference.
// Reference of each element of the return List is stealed.
NativePyObject NativePython::tupleFromRail(::x10::lang::Rail<NativePyObject >* rail) {
    PyObject* ret;
    x10_long size = (x10_long)(::x10aux::nullCheck(rail)->FMGL(size));
    ret = PyTuple_New((Py_ssize_t)size);
    if (PyErr_Occurred()) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }
    for (x10_long i = 0; i < size; i++) {
        NativePyObject nitem;
        nitem = ::x10aux::nullCheck(rail)->x10::lang::Rail<NativePyObject>::__apply(i);
        if (nitem == NULL) {
            ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::tupleFromRail, bad PyObject on the Rail")));
            return NULL;
        }
        PyTuple_SetItem(ret, (Py_ssize_t)i, nitem.getPyObject());
        if (PyErr_Occurred()) {
            ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
            return NULL;
        }
    }
    return ret;
}

// Each element of the return rail: Borrowed reference
::x10::lang::Rail<NativePyObject >* NativePython::tupleAsRail(NativePyObject tuple) {
    if (tuple == NULL ||
        !PyTuple_Check(tuple.getPyObject())) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::tupleAsRail, bad PyObject argument")));
        return NULL;
    }

    PyObject* pTuple = tuple.getPyObject();
    Py_ssize_t size = PyTuple_Size(pTuple);
    ::x10::lang::Rail<NativePyObject>* ret =  ::x10::lang::Rail<NativePyObject>::_make((x10_long)size);

    for (x10_long i = 0; i < (x10_long)size; i++) {
        PyObject* item = PyTuple_GetItem(pTuple, (Py_ssize_t)i);
        NativePyObject nitem = item;
        ::x10aux::nullCheck(ret)->x10::lang::Rail<NativePyObject>::__set(i, nitem);
    }
    
    return ret;
}

NativePyObject NativePython::unicodeFromString(::x10::lang::String* str) {
    PyObject* ret;
    ret = PyUnicode_FromString(str->c_str());
    return NativePyObject::_make(ret);
}

::x10::lang::String* NativePython::unicodeAsASCIIString(NativePyObject obj) {
    ::x10::lang::String* ret;
    if (obj != NULL) {
        PyObject* pystr = obj->getPyObject();
        if (pystr && PyUnicode_Check(pystr)) {
            PyObject* tmp = PyUnicode_AsEncodedString(pystr, "ASCII", "strict");
            if (tmp != NULL) {
                char* str = PyBytes_AS_STRING(tmp);
                ret = ::x10::lang::String::_make(::x10aux::alloc_utils::strdup(str), true);
                Py_DECREF(tmp);
                //                Py_DECREF(pystr);
                return ret;
            } else {
                ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
                //                Py_DECREF(pystr);
                return NULL;
            }
        } else {
            ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::unicodeAsASCIIString, bad PyObject")));
            return NULL;
        }
    } else {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::unicodeAsASCIIString, bad NativePyObject")));
        return NULL;
    }
}

// Return value: New reference.
NativePyObject NativePython::longFromLong(x10_long value) {
    PyObject* ret;
    ret = PyLong_FromLong(value);
    if (ret == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }
    return NativePyObject::_make(ret);
}

x10_long NativePython::longAsLong(NativePyObject obj) {
    x10_long ret;
    if (obj != NULL) {
        ret = PyLong_AsLong(obj->getPyObject());
        if (PyErr_Occurred()) {
            ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
            return 0;
        }
        return ret;
    }
    return 0;
}

x10_int NativePython::runSimpleString(::x10::lang::String* command) {
    int ret;

    ret = PyRun_SimpleString(command->c_str());
    return ret; // return 0 on success, -1 on failure
}

// Return value: New reference
NativePyObject NativePython::runString(::x10::lang::String* command, NativePyObject globals, NativePyObject locals) {
    PyObject* pObj;
    PyObject* pGlobals;
    PyObject* pLocals;

    if (globals == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::runString, bad NativePyObject for globals")));
        return NULL;
    }
    pGlobals = globals->getPyObject();
    if (pGlobals == NULL || !PyDict_Check(pGlobals)) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::runString, bad PyObject for globals")));
        return NULL;
    }

    if (locals == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::runString, bad NativePyObject for locals")));
        return NULL;
    }
    pLocals = locals ->getPyObject();
    if (pLocals == NULL || !PyDict_Check(pLocals)) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::runString, bad PyObject for localls")));
        return NULL;
    }
    
    pObj = PyRun_String(command->c_str(), Py_file_input, pGlobals, pLocals);
    if (pObj == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }
    
    return NativePyObject::_make(pObj);
}

// Return value: New reference.
NativePyObject NativePython::objectCallObject(NativePyObject callable, ::x10::lang::Rail<NativePyObject > *args) {

    if (callable == NULL ||
        !PyCallable_Check(callable.getPyObject())) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::objectCallObject, bad NativePyObject for callable")));
        return NULL;
    }
    PyObject* pArgs = NULL;
    if (args != NULL) {
        pArgs = tupleFromRail(args).getPyObject();
    }

    PyObject* ret;
    ret = PyObject_CallObject(callable.getPyObject(), pArgs);
    if (PyErr_Occurred()) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        Py_XDECREF(pArgs);
        return NULL;
    }

    Py_XDECREF(pArgs);
    return ret;
}

::x10::lang::String* NativePython::objectStr(NativePyObject obj) {
    PyObject* pystr;
    ::x10::lang::String* ret;
    if (obj != NULL) {
        pystr = PyObject_Str(obj->getPyObject());
        if (pystr && PyUnicode_Check(pystr)) {
            PyObject* tmp = PyUnicode_AsEncodedString(pystr, "ASCII", "strict");
            if (tmp != NULL) {
                char* str = PyBytes_AS_STRING(tmp);
                ret = ::x10::lang::String::_make(::x10aux::alloc_utils::strdup(str), true);
                Py_DECREF(tmp);
                Py_DECREF(pystr);
                return ret;
            } else {
                Py_DECREF(pystr);
                return NULL;
            }
        } else {
            return NULL;
        }
    }
    return NULL;
}


// Return value: New MemoryChunk (memory is allocated)
::org::scalegraph::util::MemoryChunk<x10_byte> NativePython::bytesAsMemoryChunk(NativePyObject obj) {
    if (obj == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::bytesAsMemoryChunk, bad NativePyObject")));
        return ::org::scalegraph::util::MemoryChunk<x10_byte>::_make();
    }

    PyObject* pObj = obj->getPyObject();
    Py_buffer pBuff;
    int ret = PyObject_GetBuffer(pObj, &pBuff, PyBUF_SIMPLE);
    if (ret != 0) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return ::org::scalegraph::util::MemoryChunk<x10_byte>::_make();
    }

    ::org::scalegraph::util::MemoryChunk<x10_byte> mc = ::org::scalegraph::util::MemoryChunk<x10_byte>::_make(::org::scalegraph::util::MakeStruct<x10_byte >::make(pBuff.len, 0, false, (char*)(void*)__FILE__, __LINE__));
    void* mcptr = mc.pointer();

    if (mcptr != NULL) {
        memcpy(mcptr, pBuff.buf, pBuff.len);
    }
    PyBuffer_Release(&pBuff);
    
    return mc;
}


#if 0  // changed to template declaration

// Return value: New reference of memoryview object (pointed to memorychunk argument)
NativePyObject NativePython::memoryViewFromMemoryChunk(::org::scalegraph::util::MemoryChunk<x10_byte> mc) {
    void* mcptr = mc.pointer();
    long size = mc.size();
    if (mcptr == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::bytesFromMemoryChunk, bad MemoryChunk")));
        return NULL;
    }

    PyObject* pObj = PyMemoryView_FromMemory(static_cast<char*>(mcptr), size, PyBUF_READ);
    if (PyErr_Occurred()) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }
    return pObj;
}


// Return value: New reference of memoryview object (pointed to memorychunk argument)
NativePyObject NativePython::memoryViewFromMemoryChunk(::org::scalegraph::util::MemoryChunk<x10_long> mc) {
    void* mcptr = mc.pointer();
    long size = mc.size() * sizeof(x10_long);
    if (mcptr == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::bytesFromMemoryChunk, bad MemoryChunk")));
        return NULL;
    }

    PyObject* pObj = PyMemoryView_FromMemory(static_cast<char*>(mcptr), size, PyBUF_READ);
    if (PyErr_Occurred()) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }
    return pObj;
}


// Return value: New reference of memoryview object (pointed to memorychunk argument)
NativePyObject NativePython::memoryViewFromMemoryChunk(::org::scalegraph::util::MemoryChunk<x10_double> mc) {
    void* mcptr = mc.pointer();
    long size = mc.size() * sizeof(x10_double);
    if (mcptr == NULL) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make("Error in NativePython::bytesFromMemoryChunk, bad MemoryChunk")));
        return NULL;
    }

    PyObject* pObj = PyMemoryView_FromMemory(static_cast<char*>(mcptr), size, PyBUF_READ);
    if (PyErr_Occurred()) {
        ::x10aux::throwException(::x10aux::nullCheck(NativePyException::_make()));
        return NULL;
    }
    return pObj;
}

#endif // changed to template declaration


void NativePython::test() {
    PyRun_SimpleString("from time import time,ctime\n"
                       "print('Today is', ctime(time()))\n"
                       "sys.stdout.flush()\n");
}

void NativePython::calltest(NativePyObject module) {
    PyObject *pValue;
    PyObject *pArgs;
    PyObject *pFunc;

    pArgs = Py_BuildValue("ii", 123L, 456L);
    pFunc = PyObject_GetAttrString(module->getPyObject(), "multiply");
    pValue = PyObject_CallObject(pFunc, pArgs);

    fprintf(stderr, "result = %ld\n", PyLong_AsLong(pValue));
}

NativePython* NativePython::NativePython____this__NativePython() {
    return this;
}

void NativePython::_constructor() {
    this->NativePython::__fieldInitializers_NativePython();
}

NativePython* NativePython::_make() {
    NativePython* this_ = new (::x10aux::alloc_z< NativePython>())  NativePython();
    this_->_constructor();
    return this_;
}

void NativePython::__fieldInitializers_NativePython() {
    //    this->FMGL(strtmp) = (::x10aux::class_cast_unchecked< ::x10::lang::String*>(reinterpret_cast< ::x10::lang::NullType*>(X10_NULL)));
}
const ::x10aux::serialization_id_t NativePython::_serialization_id = 
    ::x10aux::DeserializationDispatcher::addDeserializer( NativePython::_deserializer);

void NativePython::_serialize_body(::x10aux::serialization_buffer& buf) {
    //    buf.write(this->FMGL(strtmp));
    
}

::x10::lang::Reference*  NativePython::_deserializer(::x10aux::deserialization_buffer& buf) {
     NativePython* this_ = new (::x10aux::alloc_z< NativePython>())  NativePython();
    buf.record_reference(this_);
    this_->_deserialize_body(buf);
    return this_;
}

void NativePython::_deserialize_body(::x10aux::deserialization_buffer& buf) {
    //    FMGL(strtmp) = buf.read< ::x10::lang::String*>();
}

::x10aux::RuntimeType NativePython::rtt;
void NativePython::_initRTT() {
    if (rtt.initStageOne(&rtt)) return;
    const ::x10aux::RuntimeType** parents = NULL; 
    rtt.initStageTwo("NativePython",::x10aux::RuntimeType::class_kind, 0, parents, 0, NULL, NULL);
}


}}} // namespace org { namespace scalegraph { namespace python {
