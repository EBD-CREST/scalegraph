#ifndef __ORG_SCALEGRAPH_GRAPH_ID_TWOD__STOV_H
#define __ORG_SCALEGRAPH_GRAPH_ID_TWOD__STOV_H

#include <x10rt.h>


#define X10_LANG_ANY_H_NODEPS
#include <x10/lang/Any.h>
#undef X10_LANG_ANY_H_NODEPS
#define X10_LANG_ANY_H_NODEPS
#include <x10/lang/Any.h>
#undef X10_LANG_ANY_H_NODEPS
#define X10_LANG_INT_H_NODEPS
#include <x10/lang/Int.h>
#undef X10_LANG_INT_H_NODEPS
#define X10_LANG_INT_H_NODEPS
#include <x10/lang/Int.h>
#undef X10_LANG_INT_H_NODEPS
#define X10_LANG_LONG_H_NODEPS
#include <x10/lang/Long.h>
#undef X10_LANG_LONG_H_NODEPS
#define X10_LANG_LONG_H_NODEPS
#include <x10/lang/Long.h>
#undef X10_LANG_LONG_H_NODEPS
namespace org { namespace scalegraph { namespace graph { namespace id { 
class IdStruct;
} } } } 
namespace x10 { namespace lang { 
class String;
} } 
namespace x10 { namespace compiler { 
class Native;
} } 
namespace x10 { namespace compiler { 
class NonEscaping;
} } 
namespace x10 { namespace lang { 
class Boolean;
} } 
namespace org { namespace scalegraph { namespace graph { namespace id { 

class Twod__StoV   {
    public:
    RTT_H_DECLS_STRUCT
    
    org::scalegraph::graph::id::Twod__StoV* operator->() { return this; }
    
    static x10aux::itable_entry _itables[2];
    
    x10aux::itable_entry* _getITables() { return _itables; }
    
    static x10::lang::Any::itable<org::scalegraph::graph::id::Twod__StoV > _itable_0;
    
    static x10aux::itable_entry _iboxitables[2];
    
    x10aux::itable_entry* _getIBoxITables() { return _iboxitables; }
    
    static org::scalegraph::graph::id::Twod__StoV _alloc(){org::scalegraph::graph::id::Twod__StoV t; return t; }
    
    x10_int FMGL(r);
    
    x10_int FMGL(lgr);
    
    x10_int FMGL(lgl);
    
    x10_int FMGL(lgsize);
    
    x10_long FMGL(lmask);
    
    void _constructor(org::scalegraph::graph::id::IdStruct ids, x10_int r);
    
    static org::scalegraph::graph::id::Twod__StoV _make(org::scalegraph::graph::id::IdStruct ids,
                                                        x10_int r);
    
    x10_long __apply(x10_long id) {
        
        //#line 115 "/nfs/home/vinodmadaan/ScaleGraph_Stable_Version/scalegraph/src/org/scalegraph/graph/id/Twod.x10": x10.ast.X10Return_c
        return ((x10_long) ((((x10_long) ((((x10_long) ((((x10_long) ((id) & ((*this)->
                                                                                FMGL(lmask))))) << (0x3f & ((*this)->
                                                                                                              FMGL(lgsize)))))) | (((x10_long) ((((x10_long) ((id) >> (0x3f & ((*this)->
                                                                                                                                                                                 FMGL(lgl)))))) << (0x3f & ((*this)->
                                                                                                                                                                                                              FMGL(lgr))))))))) | (((x10_long) ((*this)->
                                                                                                                                                                                                                                                  FMGL(r))))));
        
    }
    x10::lang::String* typeName();
    x10::lang::String* toString();
    x10_int hashCode();
    x10_boolean equals(x10::lang::Any* other);
    x10_boolean equals(org::scalegraph::graph::id::Twod__StoV other) {
        
        //#line 98 "/nfs/home/vinodmadaan/ScaleGraph_Stable_Version/scalegraph/src/org/scalegraph/graph/id/Twod.x10": x10.ast.X10Return_c
        return (x10aux::struct_equals((*this)->FMGL(r), other->
                                                          FMGL(r))) &&
        (x10aux::struct_equals((*this)->FMGL(lgr), other->
                                                     FMGL(lgr))) &&
        (x10aux::struct_equals((*this)->FMGL(lgl), other->
                                                     FMGL(lgl))) &&
        (x10aux::struct_equals((*this)->FMGL(lgsize), other->
                                                        FMGL(lgsize))) &&
        (x10aux::struct_equals((*this)->FMGL(lmask), other->
                                                       FMGL(lmask)));
        
    }
    x10_boolean _struct_equals(x10::lang::Any* other);
    x10_boolean _struct_equals(org::scalegraph::graph::id::Twod__StoV other) {
        
        //#line 98 "/nfs/home/vinodmadaan/ScaleGraph_Stable_Version/scalegraph/src/org/scalegraph/graph/id/Twod.x10": x10.ast.X10Return_c
        return (x10aux::struct_equals((*this)->FMGL(r), other->
                                                          FMGL(r))) &&
        (x10aux::struct_equals((*this)->FMGL(lgr), other->
                                                     FMGL(lgr))) &&
        (x10aux::struct_equals((*this)->FMGL(lgl), other->
                                                     FMGL(lgl))) &&
        (x10aux::struct_equals((*this)->FMGL(lgsize), other->
                                                        FMGL(lgsize))) &&
        (x10aux::struct_equals((*this)->FMGL(lmask), other->
                                                       FMGL(lmask)));
        
    }
    org::scalegraph::graph::id::Twod__StoV org__scalegraph__graph__id__Twod__StoV____this__org__scalegraph__graph__id__Twod__StoV(
      ) {
        
        //#line 98 "/nfs/home/vinodmadaan/ScaleGraph_Stable_Version/scalegraph/src/org/scalegraph/graph/id/Twod.x10": x10.ast.X10Return_c
        return (*this);
        
    }
    
    static void _serialize(org::scalegraph::graph::id::Twod__StoV this_, x10aux::serialization_buffer& buf);
    
    static org::scalegraph::graph::id::Twod__StoV _deserialize(x10aux::deserialization_buffer& buf) {
        org::scalegraph::graph::id::Twod__StoV this_;
        this_->_deserialize_body(buf);
        return this_;
    }
    
    void _deserialize_body(x10aux::deserialization_buffer& buf);
    
};


} } } } 
#endif // ORG_SCALEGRAPH_GRAPH_ID_TWOD__STOV_H

namespace org { namespace scalegraph { namespace graph { namespace id { 
class Twod__StoV;
} } } } 

#ifndef ORG_SCALEGRAPH_GRAPH_ID_TWOD__STOV_H_NODEPS
#define ORG_SCALEGRAPH_GRAPH_ID_TWOD__STOV_H_NODEPS
#ifndef ORG_SCALEGRAPH_GRAPH_ID_TWOD__STOV_H_GENERICS
#define ORG_SCALEGRAPH_GRAPH_ID_TWOD__STOV_H_GENERICS
#endif // ORG_SCALEGRAPH_GRAPH_ID_TWOD__STOV_H_GENERICS
#endif // __ORG_SCALEGRAPH_GRAPH_ID_TWOD__STOV_H_NODEPS