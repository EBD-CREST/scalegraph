#ifndef __TESTPYTHON_H
#define __TESTPYTHON_H

#include <x10rt.h>


namespace x10 { namespace lang { 
template<class TPMGL(T)> class Rail;
} } 
namespace x10 { namespace lang { 
class String;
} } 
namespace x10 { namespace io { 
class Printer;
} } 
namespace x10 { namespace io { 
class Console;
} } 
namespace x10 { namespace lang { 
class Any;
} } 
class NativePythonIntegrate;
namespace x10 { namespace compiler { 
class Synthetic;
} } 

class TestPython_Strings {
  public:
    static ::x10::lang::String sl__33;
};

class TestPython : public ::x10::lang::X10Class   {
    public:
    RTT_H_DECLS_CLASS
    
    static void main( ::x10::lang::Rail<  ::x10::lang::String* >* args);
    virtual  ::TestPython* TestPython____this__TestPython();
    void _constructor();
    
    static  ::TestPython* _make();
    
    virtual void __fieldInitializers_TestPython();
    
    // Serialization
    public: static const ::x10aux::serialization_id_t _serialization_id;
    
    public: virtual ::x10aux::serialization_id_t _get_serialization_id() {
         return _serialization_id;
    }
    
    public: virtual void _serialize_body(::x10aux::serialization_buffer& buf);
    
    public: static ::x10::lang::Reference* _deserializer(::x10aux::deserialization_buffer& buf);
    
    public: void _deserialize_body(::x10aux::deserialization_buffer& buf);
    
};

#endif // TESTPYTHON_H

class TestPython;

#ifndef TESTPYTHON_H_NODEPS
#define TESTPYTHON_H_NODEPS
#ifndef TESTPYTHON_H_GENERICS
#define TESTPYTHON_H_GENERICS
#endif // TESTPYTHON_H_GENERICS
#endif // __TESTPYTHON_H_NODEPS
