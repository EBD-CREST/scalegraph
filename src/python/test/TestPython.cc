/*************************************************/
/* START of TestPython */
#include <TestPython.h>

#include <x10/lang/Rail.h>
#include <x10/lang/String.h>
#include <x10/io/Printer.h>
#include <x10/io/Console.h>
#include <x10/lang/Any.h>
#include <NativePythonIntegrate.h>
#include <x10/compiler/Synthetic.h>
#include <x10/lang/String.h>

//#line 6 "/Users/tosiyuki/Development/toshi-github/EBD/scalegraph-dev/src/python/test/TestPython.x10"
void TestPython::main( ::x10::lang::Rail<  ::x10::lang::String* >* args) {
    
    //#line 7 "/Users/tosiyuki/Development/toshi-github/EBD/scalegraph-dev/src/python/test/TestPython.x10"
     ::x10::io::Console::FMGL(OUT__get)() -> x10::io::Printer::println(reinterpret_cast< ::x10::lang::Any*>((&::TestPython_Strings::sl__33)));
    
    //#line 9 "/Users/tosiyuki/Development/toshi-github/EBD/scalegraph-dev/src/python/test/TestPython.x10"
    NativePythonIntegrate python = NativePythonIntegrate::_make();
    
    //#line 10 "/Users/tosiyuki/Development/toshi-github/EBD/scalegraph-dev/src/python/test/TestPython.x10"
    python -> NativePythonIntegrate::test();
}

//#line 5 "/Users/tosiyuki/Development/toshi-github/EBD/scalegraph-dev/src/python/test/TestPython.x10"
 ::TestPython* TestPython::TestPython____this__TestPython() {
    return this;
    
}
void TestPython::_constructor() {
    this -> TestPython::__fieldInitializers_TestPython();
}
 ::TestPython* TestPython::_make() {
     ::TestPython* this_ = new (::x10aux::alloc_z< ::TestPython>())  ::TestPython();
    this_->_constructor();
    return this_;
}


void TestPython::__fieldInitializers_TestPython() {
 
}
const ::x10aux::serialization_id_t TestPython::_serialization_id = 
    ::x10aux::DeserializationDispatcher::addDeserializer( ::TestPython::_deserializer);

void TestPython::_serialize_body(::x10aux::serialization_buffer& buf) {
    
}

::x10::lang::Reference*  ::TestPython::_deserializer(::x10aux::deserialization_buffer& buf) {
     ::TestPython* this_ = new (::x10aux::alloc_z< ::TestPython>())  ::TestPython();
    buf.record_reference(this_);
    this_->_deserialize_body(buf);
    return this_;
}

void TestPython::_deserialize_body(::x10aux::deserialization_buffer& buf) {
    
}

::x10aux::RuntimeType TestPython::rtt;
void TestPython::_initRTT() {
    if (rtt.initStageOne(&rtt)) return;
    const ::x10aux::RuntimeType** parents = NULL; 
    rtt.initStageTwo("TestPython",::x10aux::RuntimeType::class_kind, 0, parents, 0, NULL, NULL);
    rtt.containsPtrs = false;
}

::x10::lang::String TestPython_Strings::sl__33("Hello, world");

/* END of TestPython */
/*************************************************/
