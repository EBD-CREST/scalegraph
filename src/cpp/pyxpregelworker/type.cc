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

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include <x10aux/config.h>

#include "type.h"

size_t
Type::SizeOf(int tid) {

    switch (tid) {
        case Boolean:
            return sizeof(x10_boolean);
        case Byte:
            return sizeof(x10_byte);
        case Short:
            return sizeof(x10_short);
        case Int:
            return sizeof(x10_int);
        case Long:
            return sizeof(x10_long);
        case Float:
            return sizeof(x10_float);
        case Double:
            return sizeof(x10_double);
        case UByte:
            return sizeof(x10_ubyte);
        case UShort:
            return sizeof(x10_ushort);
        case UInt:
            return sizeof(x10_uint);
        case ULong:
            return sizeof(x10_ulong);
        case Char:
            return sizeof(x10_char);
        default:
            assert(false);
    }

    return 0;
}


PyObject*
Type::PyFormat(int tid) {

    const char* format_str = NULL;
    switch (tid) {
        case Int:
            format_str = "i";
            break;
        case Long:
            format_str = "q";
            break;
        case Float:
            format_str = "f";
            break;
        case Double:
            format_str = "d";
            break;
        case UInt:
            format_str = "I";
            break;
        case ULong:
            format_str = "Q";
            break;
        default:
            assert(false);
    }

    PyObject* obj = PyUnicode_FromString(format_str);
    return obj;
}
